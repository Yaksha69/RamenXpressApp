import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/payment_method.dart';
import 'api_service.dart';

class PaymentMethodService {
  // Get all payment methods
  static Future<Map<String, dynamic>> getAllPaymentMethods() async {
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/v1/payment-methods'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<PaymentMethod> paymentMethods = (data['data'] as List)
            .map((json) => PaymentMethod.fromJson(json))
            .toList();
        
        return {
          'success': true,
          'data': paymentMethods,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch payment methods',
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

  // Get a specific payment method by ID
  static Future<Map<String, dynamic>> getPaymentMethodById({
    required String paymentMethodId,
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/v1/payment-methods/$paymentMethodId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final paymentMethod = PaymentMethod.fromJson(data['data']);
        
        return {
          'success': true,
          'data': paymentMethod,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch payment method',
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

  // Create a new payment method
  static Future<Map<String, dynamic>> createPaymentMethod({
    required PaymentType type,
    required String title,
    required String accountNumber,
    required String accountName,
    bool isDefault = false,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/v1/payment-methods'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'type': type.toString().split('.').last,
          'title': title,
          'accountNumber': accountNumber,
          'accountName': accountName,
          'isDefault': isDefault,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final paymentMethod = PaymentMethod.fromJson(data['data']);
        
        return {
          'success': true,
          'message': data['message'],
          'data': paymentMethod,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create payment method',
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

  // Update a payment method
  static Future<Map<String, dynamic>> updatePaymentMethod({
    required String paymentMethodId,
    PaymentType? type,
    String? title,
    String? accountNumber,
    String? accountName,
    bool? isDefault,
    required String token,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (type != null) updateData['type'] = type.toString().split('.').last;
      if (title != null) updateData['title'] = title;
      if (accountNumber != null) updateData['accountNumber'] = accountNumber;
      if (accountName != null) updateData['accountName'] = accountName;
      if (isDefault != null) updateData['isDefault'] = isDefault;

      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/api/v1/payment-methods/$paymentMethodId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final paymentMethod = PaymentMethod.fromJson(data['data']);
        
        return {
          'success': true,
          'message': data['message'],
          'data': paymentMethod,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update payment method',
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

  // Delete a payment method
  static Future<Map<String, dynamic>> deletePaymentMethod({
    required String paymentMethodId,
    required String token,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/api/v1/payment-methods/$paymentMethodId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete payment method',
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

  // Set default payment method
  static Future<Map<String, dynamic>> setDefaultPaymentMethod({
    required String paymentMethodId,
    required String token,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiService.baseUrl}/api/v1/payment-methods/$paymentMethodId/default'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final paymentMethod = PaymentMethod.fromJson(data['data']);
        
        return {
          'success': true,
          'message': data['message'],
          'data': paymentMethod,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to set default payment method',
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
} 