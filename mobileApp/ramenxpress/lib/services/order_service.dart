import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import 'api_service.dart';

class OrderService {
  static const String baseUrl = ApiService.baseUrl;

  // Place a new order
  static Future<Map<String, dynamic>> placeOrder({
    required List<Map<String, dynamic>> items,
    required String orderType,
    required String paymentMethod,
    String? customerId,
    Map<String, dynamic>? deliveryAddress,
    String? notes,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/customer-orders/place-order'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'items': items,
          'orderType': orderType,
          'paymentMethod': paymentMethod,
          'customerId': customerId,
          'deliveryAddress': deliveryAddress,
          'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
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
    required String customerId, // Keep for compatibility but not used in URL
    required String token,
  }) async {
    print('🔍 OrderService: Getting customer orders');
    print('🔍 OrderService: URL: $baseUrl/api/v1/customer-orders/orders');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/customer-orders/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🔍 OrderService: Response status: ${response.statusCode}');
      print('🔍 OrderService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Order> orders = data.map((json) => Order.fromJson(json)).toList();
        
        print('🔍 OrderService: Successfully converted ${orders.length} orders');
        
        return {
          'success': true,
          'data': orders,
        };
      } else {
        final data = jsonDecode(response.body);
        print('🔍 OrderService: Error response: $data');
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch orders',
          'error': data['error'],
        };
      }
    } catch (e) {
      print('🔍 OrderService: Exception: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'error': e.toString(),
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
        Uri.parse('$baseUrl/api/v1/customer-orders/order/$orderId'),
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
        Uri.parse('$baseUrl/api/v1/customer-orders/order/$orderId/status'),
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
    print('🔍 DEBUG: OrderService.getOrderInvoice called with orderId: $orderId');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/customer-orders/invoice/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('🔍 DEBUG: API Response status: ${response.statusCode}');
      print('🔍 DEBUG: API Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🔍 DEBUG: Parsed response data: $data');
        return {
          'success': true,
          'data': data,
        };
      } else {
        print('❌ DEBUG: API call failed with status: ${response.statusCode}');
        final errorData = jsonDecode(response.body);
        print('❌ DEBUG: Error response: $errorData');
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to fetch invoice',
        };
      }
    } catch (e, stackTrace) {
      print('❌ DEBUG: Exception in getOrderInvoice: $e');
      print('❌ DEBUG: Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
} 