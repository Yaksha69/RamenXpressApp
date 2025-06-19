import 'package:flutter/material.dart';
import '../models/payment_method.dart';
import '../models/delivery_address.dart' as delivery;
import '../models/order.dart';
import '../services/order_service.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';
import 'dart:convert';

class OrderHistoryProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  WebSocketService? _ws;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void initWebSocket() {
    _ws = WebSocketService();
    _ws!.connect('http://localhost:3000'); // Socket.IO server URL
    _ws!.messageStream.listen((event) {
      final data = _parseEvent(event);
      if (data != null) {
        if (data['type'] == 'orderStatusUpdated') {
          _updateOrderStatus(data['orderId'], data['status']);
        } else if (data['type'] == 'orderPlaced') {
          _addOrderFromEvent(data);
        }
      }
    });
  }

  Map<String, dynamic>? _parseEvent(Map<String, dynamic> event) {
    try {
      if (event.containsKey('orderId') && event.containsKey('status')) {
        return {
          'type': 'orderStatusUpdated',
          'orderId': event['orderId'],
          'status': event['status'],
        };
      } else if (event.containsKey('orderId') && event.containsKey('items')) {
        return {
          'type': 'orderPlaced',
          ...event,
        };
      } else if (event['type'] == 'order_update') {
        return {
          'type': 'orderStatusUpdated',
          'orderId': event['orderId'],
          'status': event['status'],
        };
      }
    } catch (e) {
      print('Error parsing order event: $e');
    }
    return null;
  }

  void _updateOrderStatus(int orderId, String status) {
    final index = _orders.indexWhere((order) => order.orderId == orderId);
    if (index != -1) {
      final order = _orders[index];
      _orders[index] = Order(
        orderId: order.orderId,
        customerId: order.customerId,
        items: order.items,
        total: order.total,
        orderType: order.orderType,
        paymentMethod: order.paymentMethod,
        deliveryAddress: order.deliveryAddress,
        deliveryFee: order.deliveryFee,
        status: status,
        notes: order.notes,
        orderDate: order.orderDate,
      );
      notifyListeners();
    }
  }

  void _addOrderFromEvent(Map<String, dynamic> data) {
    try {
      final order = Order.fromJson(data);
      _orders.insert(0, order);
      notifyListeners();
    } catch (e) {
      print('Error creating order from event: $e');
    }
  }

  // Subscribe to order updates for a specific user
  void subscribeToOrders(String userId) {
    _ws?.subscribeToOrders(userId);
  }

  // Dispose WebSocket connection
  @override
  void dispose() {
    _ws?.dispose();
    super.dispose();
  }

  // Load customer orders from backend
  Future<void> loadCustomerOrders(String customerId) async {
    print('🔍 Loading orders for customer: $customerId');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await ApiService.getToken();
      if (token == null) {
        _error = 'Authentication token not found';
        print('❌ No authentication token found');
        return;
      }

      print('🔍 Calling OrderService.getCustomerOrders...');
      final result = await OrderService.getCustomerOrders(
        customerId: customerId,
        token: token,
      );

      print('🔍 OrderService result: $result');

      if (result['success']) {
        // Use the already converted Order objects from the service
        _orders = result['data'] as List<Order>;
        // Sort by order date (most recent first)
        _orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
        print('✅ Loaded ${_orders.length} orders');
      } else {
        _error = result['message'];
        print('❌ Failed to load orders: ${result['message']}');
      }
    } catch (e) {
      _error = e.toString();
      print('❌ Error loading orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add order to local history (for immediate display after checkout)
  void addOrder({
    required int orderId,
    required DateTime date,
    required String status,
    required double total,
    required List<Map<String, dynamic>> items,
    required String deliveryMethod,
    delivery.DeliveryAddress? deliveryAddress,
    required PaymentMethod paymentMethod,
    String? notes,
  }) {
    // Create a temporary order for local display
    final order = Order(
      orderId: orderId,
      items: items.map((item) => OrderItem(
        name: item['name'],
        price: item['price'].toDouble(),
        quantity: item['quantity'],
        total: (item['price'] * item['quantity']).toDouble(),
        addOns: (item['addons'] as List<dynamic>?)
            ?.map((addon) => AddOn(
                  name: addon['name'],
                  price: addon['price'].toDouble(),
                ))
            .toList() ?? [],
      )).toList(),
      total: total,
      orderType: deliveryMethod,
      paymentMethod: paymentMethod.type.toString().split('.').last,
      deliveryAddress: deliveryAddress != null ? DeliveryAddress(
        street: deliveryAddress.street,
        city: deliveryAddress.city,
        state: deliveryAddress.state,
        zipCode: deliveryAddress.zipCode,
        country: deliveryAddress.country,
        isDefault: deliveryAddress.isDefault,
      ) : null,
      deliveryFee: deliveryMethod == 'delivery' ? 50.0 : 0.0,
      status: status,
      notes: notes ?? '',
      orderDate: date,
    );

    _orders.insert(0, order);
    notifyListeners();
  }

  // Get order by ID
  Order? getOrderById(int orderId) {
    try {
      return _orders.firstWhere((order) => order.orderId == orderId);
    } catch (e) {
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh orders
  Future<void> refreshOrders(String customerId) async {
    await loadCustomerOrders(customerId);
  }
} 