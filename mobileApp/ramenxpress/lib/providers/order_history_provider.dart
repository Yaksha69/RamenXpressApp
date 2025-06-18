import 'package:flutter/foundation.dart';
import '../models/payment_method.dart';
import '../models/delivery_address.dart';

class OrderHistoryProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _orders = [];
  int _nextOrderId = 1;

  List<Map<String, dynamic>> get orders => List.unmodifiable(_orders);

  void addOrder({
    required DateTime date,
    required String status,
    required double total,
    required List<Map<String, dynamic>> items,
    required String deliveryMethod,
    DeliveryAddress? deliveryAddress,
    required PaymentMethod paymentMethod,
    String? notes,
  }) {
    final order = {
      'id': _nextOrderId++,
      'date': date,
      'status': status,
      'total': total,
      'items': items,
      'deliveryMethod': deliveryMethod,
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
      'notes': notes,
    };

    _orders.insert(0, order);
    notifyListeners();
  }

  void updateOrderStatus(int orderId, String newStatus) {
    final index = _orders.indexWhere((order) => order['id'] == orderId);
    if (index != -1) {
      _orders[index]['status'] = newStatus;
      notifyListeners();
    }
  }

  void cancelOrder(int orderId) {
    final index = _orders.indexWhere((order) => order['id'] == orderId);
    if (index != -1) {
      _orders[index]['status'] = 'Cancelled';
      notifyListeners();
    }
  }
}
