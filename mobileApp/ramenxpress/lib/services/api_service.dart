import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000'; // For web browser
    } else {
      return 'http://10.0.2.2:3000'; // For Android emulator
    }
  }

  // Shared Preferences keys
  static const String tokenKey = 'customer_token';
  static const String customerDataKey = 'customer_data';

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Store token
  static Future<void> storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  // Remove token (logout)
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(customerDataKey);
  }

  // Store customer data
  static Future<void> storeCustomerData(Customer customer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(customerDataKey, jsonEncode(customer.toJson()));
  }

  // Get stored customer data
  static Future<Customer?> getCustomerData() async {
    final prefs = await SharedPreferences.getInstance();
    final customerJson = prefs.getString(customerDataKey);
    if (customerJson != null) {
      return Customer.fromJson(jsonDecode(customerJson));
    }
    return null;
  }

  // Customer Registration
  static Future<Map<String, dynamic>> registerCustomer({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/customer/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Store token and customer data
        await storeToken(data['token']);
        await storeCustomerData(Customer.fromJson(data['customer']));
        
        return {
          'success': true,
          'message': 'Registration successful',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
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

  // Customer Login
  static Future<Map<String, dynamic>> loginCustomer({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/customer/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Store token and customer data
        await storeToken(data['token']);
        await storeCustomerData(Customer.fromJson(data['customer']));
        
        return {
          'success': true,
          'message': 'Login successful',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
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

  // Get Customer Profile
  static Future<Map<String, dynamic>> getCustomerProfile() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/customer/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get profile',
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

  // Update Customer Profile
  static Future<Map<String, dynamic>> updateCustomerProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/v1/customer/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Update stored customer data
        await storeCustomerData(Customer.fromJson(data['customer']));
        
        return {
          'success': true,
          'message': 'Profile updated successfully',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update profile',
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

  // Change Password
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/v1/customer/change-password'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password changed successfully',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to change password',
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

  // Logout
  static Future<Map<String, dynamic>> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        final response = await http.post(
          Uri.parse('$baseUrl/api/v1/customer/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        // Always remove local data regardless of server response
        await removeToken();
        
        if (response.statusCode == 200) {
          return {
            'success': true,
            'message': 'Logged out successfully',
          };
        }
      }

      // If no token or server error, still remove local data
      await removeToken();
      return {
        'success': true,
        'message': 'Logged out successfully',
      };
    } catch (e) {
      // Even if network error, remove local data
      await removeToken();
      return {
        'success': true,
        'message': 'Logged out successfully',
      };
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
} 