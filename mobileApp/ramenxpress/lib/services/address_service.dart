import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/delivery_address.dart';
import 'api_service.dart';

class AddressService {
  // Get all addresses for the authenticated customer
  static Future<Map<String, dynamic>> getCustomerAddresses({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/v1/addresses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<DeliveryAddress> addresses = (data['data'] as List)
            .map((json) => DeliveryAddress.fromJson(json))
            .toList();
        
        return {
          'success': true,
          'data': addresses,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch addresses',
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

  // Get a specific address by ID
  static Future<Map<String, dynamic>> getAddressById({
    required String addressId,
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/v1/addresses/$addressId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = DeliveryAddress.fromJson(data['data']);
        
        return {
          'success': true,
          'data': address,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch address',
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

  // Create a new address
  static Future<Map<String, dynamic>> createAddress({
    required String label,
    required String recipientName,
    required String phoneNumber,
    required String street,
    required String city,
    required String state,
    required String zipCode,
    String country = 'Philippines',
    bool isDefault = false,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/v1/addresses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'label': label,
          'recipientName': recipientName,
          'phoneNumber': phoneNumber,
          'street': street,
          'city': city,
          'state': state,
          'zipCode': zipCode,
          'country': country,
          'isDefault': isDefault,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final address = DeliveryAddress.fromJson(data['data']);
        
        return {
          'success': true,
          'message': data['message'],
          'data': address,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create address',
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

  // Update an address
  static Future<Map<String, dynamic>> updateAddress({
    required String addressId,
    String? label,
    String? recipientName,
    String? phoneNumber,
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    bool? isDefault,
    required String token,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (label != null) updateData['label'] = label;
      if (recipientName != null) updateData['recipientName'] = recipientName;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (street != null) updateData['street'] = street;
      if (city != null) updateData['city'] = city;
      if (state != null) updateData['state'] = state;
      if (zipCode != null) updateData['zipCode'] = zipCode;
      if (country != null) updateData['country'] = country;
      if (isDefault != null) updateData['isDefault'] = isDefault;

      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/api/v1/addresses/$addressId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = DeliveryAddress.fromJson(data['data']);
        
        return {
          'success': true,
          'message': data['message'],
          'data': address,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update address',
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

  // Delete an address
  static Future<Map<String, dynamic>> deleteAddress({
    required String addressId,
    required String token,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/api/v1/addresses/$addressId'),
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
          'message': data['message'] ?? 'Failed to delete address',
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

  // Set default address
  static Future<Map<String, dynamic>> setDefaultAddress({
    required String addressId,
    required String token,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiService.baseUrl}/api/v1/addresses/$addressId/default'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = DeliveryAddress.fromJson(data['data']);
        
        return {
          'success': true,
          'message': data['message'],
          'data': address,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to set default address',
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