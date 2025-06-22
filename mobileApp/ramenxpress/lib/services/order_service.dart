import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import 'api_service.dart';

class OrderService {
  // Place a new order
  static Future<Map<String, dynamic>> placeOrder({
    required List<Map<String, dynamic>> items,
    required String orderType,
    required String paymentMethod,
    required double total,
    double deliveryFee = 0.0,
    String? notes,
    Map<String, dynamic>? deliveryAddress,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/v1/customer-orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'items': items,
          'orderType': orderType,
          'paymentMethod': paymentMethod,
          'total': total,
          'deliveryFee': deliveryFee,
          'notes': notes,
          'deliveryAddress': deliveryAddress,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'],
          'orderDetails': data['orderDetails'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to place order',
          'error': data['error'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  // Get customer orders
  static Future<Map<String, dynamic>> getCustomerOrders({
    required String customerId,
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/v1/customer-orders/customer/$customerId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final orders = (data['orders'] as List<dynamic>)
            .map((orderJson) => Order.fromJson(orderJson))
            .toList();
        
        return {
          'success': true,
          'data': orders,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch orders',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get order by ID
  static Future<Map<String, dynamic>> getOrderById({
    required int orderId,
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/v1/customer-orders/order/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final order = Order.fromJson(data);
        
        return {
          'success': true,
          'data': order,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch order',
          'error': data['error'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  // Update order status
  static Future<Map<String, dynamic>> updateOrderStatus({
    required int orderId,
    required String status,
    required String token,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/api/v1/customer-orders/order/$orderId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'],
          'order': data['order'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update order status',
          'error': data['error'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  // Get order invoice
  static Future<Map<String, dynamic>> getOrderInvoice({
    required int orderId,
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/v1/customer-orders/invoice/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to fetch invoice',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
} 