import 'package:flutter/material.dart';
import '../models/payment_method.dart';
import '../models/delivery_address.dart' as delivery;
import '../models/order.dart';
import '../services/order_service.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';

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
    _ws!.initialize('', customerId: null); // URL will be determined by the service
    
    // Set up event listeners
    _ws!.onOrderPlaced = (orderData) {
      _addOrderFromEvent(orderData);
    };
    
    _ws!.onOrderStatusUpdated = (statusData) {
      _updateOrderStatus(statusData['orderId'], statusData['status']);
    };
    
    _ws!.connect();
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
      // Handle error silently for now
    }
  }

  // Subscribe to order updates for a specific user
  void subscribeToOrders(String userId) {
    _ws?.joinCustomerRoom(userId);
  }

  // Dispose WebSocket connection
  @override
  void dispose() {
    _ws?.dispose();
    super.dispose();
  }

  // Load customer orders from backend
  Future<void> loadCustomerOrders(String customerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await ApiService.getToken();
      if (token == null) {
        _error = 'Authentication token not found';
        return;
      }

      final result = await OrderService.getCustomerOrders(
        customerId: customerId,
        token: token,
      );

      if (result['success']) {
        // Use the already converted Order objects from the service
        _orders = result['data'] as List<Order>;
        // Sort by order date (most recent first)
        _orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      } else {
        _error = result['message'];
      }
    } catch (e) {
      _error = e.toString();
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
    final order = Order(
      orderId: orderId,
      orderDate: date,
      status: status,
      total: total,
      items: items.map((item) => OrderItem(
        name: item['name'],
        quantity: item['quantity'],
        price: item['price'].toDouble(),
        total: (item['price'] * item['quantity']).toDouble(),
        addOns: (item['addons'] as List<dynamic>?)?.map((addon) => AddOn(
          name: addon,
          price: 0.0,
        )).toList() ?? [],
      )).toList(),
      orderType: deliveryMethod,
      deliveryAddress: deliveryAddress != null ? DeliveryAddress(
        street: deliveryAddress.street,
        city: deliveryAddress.city,
        state: deliveryAddress.state,
        zipCode: deliveryAddress.zipCode,
        country: deliveryAddress.country,
        isDefault: deliveryAddress.isDefault,
      ) : null,
      paymentMethod: paymentMethod.title.toLowerCase(),
      deliveryFee: deliveryMethod == 'delivery' ? 50.0 : 0.0,
      notes: notes ?? '',
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