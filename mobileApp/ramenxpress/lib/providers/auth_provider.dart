import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  Customer? _customer;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;

  Customer? get customer => _customer;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;

  // Initialize auth state
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await ApiService.isLoggedIn();
      if (isLoggedIn) {
        final customerData = await ApiService.getCustomerData();
        if (customerData != null) {
          _customer = customerData;
          _isLoggedIn = true;
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register customer
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.registerCustomer(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      if (result['success']) {
        _customer = Customer.fromJson(result['data']['customer']);
        _isLoggedIn = true;
        _error = null;
        return true;
      } else {
        _error = result['message'];
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login customer
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.loginCustomer(
        email: email,
        password: password,
      );

      if (result['success']) {
        _customer = Customer.fromJson(result['data']['customer']);
        _isLoggedIn = true;
        _error = null;
        return true;
      } else {
        _error = result['message'];
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    if (_customer == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.updateCustomerProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      if (result['success']) {
        _customer = Customer.fromJson(result['data']['customer']);
        _error = null;
        return true;
      } else {
        _error = result['message'];
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (result['success']) {
        _error = null;
        return true;
      } else {
        _error = result['message'];
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.logout();
    } catch (e) {
      // Even if logout fails, clear local state
    } finally {
      _customer = null;
      _isLoggedIn = false;
      _error = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh profile
  Future<void> refreshProfile() async {
    if (_customer == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.getCustomerProfile();
      if (result['success']) {
        _customer = Customer.fromJson(result['data']['customer']);
        // Update stored data
        await ApiService.storeCustomerData(_customer!);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 