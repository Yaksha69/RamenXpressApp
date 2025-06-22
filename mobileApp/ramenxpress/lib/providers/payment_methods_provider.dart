import 'package:flutter/material.dart';
import '../models/payment_method.dart';
import '../services/payment_method_service.dart';
import '../services/api_service.dart';

class PaymentMethodsProvider extends ChangeNotifier {
  List<PaymentMethod> _paymentMethods = [];
  bool _isLoading = false;
  String? _error;

  List<PaymentMethod> get paymentMethods => List.unmodifiable(_paymentMethods);
  bool get isLoading => _isLoading;
  String? get error => _error;

  PaymentMethod? get defaultPaymentMethod {
    try {
      return _paymentMethods.firstWhere((method) => method.isDefault);
    } catch (e) {
      return null;
    }
  }

  // Load payment methods from backend
  Future<void> loadPaymentMethods() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await ApiService.getToken();
      if (token == null) {
        _error = 'Authentication token not found';
        return;
      }

      final result = await PaymentMethodService.getAllPaymentMethods();

      if (result['success']) {
        _paymentMethods = result['data'] as List<PaymentMethod>;
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

  // Create a new payment method
  Future<bool> createPaymentMethod({
    required PaymentType type,
    required String title,
    required String accountNumber,
    required String accountName,
    bool isDefault = false,
  }) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        _error = 'Authentication token not found';
        notifyListeners();
        return false;
      }

      final result = await PaymentMethodService.createPaymentMethod(
        type: type,
        title: title,
        accountNumber: accountNumber,
        accountName: accountName,
        isDefault: isDefault,
        token: token,
      );

      if (result['success']) {
        await loadPaymentMethods(); // Reload payment methods to get the updated list
        return true;
      } else {
        _error = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update a payment method
  Future<bool> updatePaymentMethod({
    required String paymentMethodId,
    PaymentType? type,
    String? title,
    String? accountNumber,
    String? accountName,
    bool? isDefault,
  }) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        _error = 'Authentication token not found';
        notifyListeners();
        return false;
      }

      final result = await PaymentMethodService.updatePaymentMethod(
        paymentMethodId: paymentMethodId,
        type: type,
        title: title,
        accountNumber: accountNumber,
        accountName: accountName,
        isDefault: isDefault,
        token: token,
      );

      if (result['success']) {
        await loadPaymentMethods(); // Reload payment methods to get the updated list
        return true;
      } else {
        _error = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete a payment method
  Future<bool> deletePaymentMethod(String paymentMethodId) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        _error = 'Authentication token not found';
        notifyListeners();
        return false;
      }

      final result = await PaymentMethodService.deletePaymentMethod(
        paymentMethodId: paymentMethodId,
        token: token,
      );

      if (result['success']) {
        await loadPaymentMethods(); // Reload payment methods to get the updated list
        return true;
      } else {
        _error = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Set default payment method
  Future<bool> setDefaultPaymentMethod(String paymentMethodId) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        _error = 'Authentication token not found';
        notifyListeners();
        return false;
      }

      final result = await PaymentMethodService.setDefaultPaymentMethod(
        paymentMethodId: paymentMethodId,
        token: token,
      );

      if (result['success']) {
        await loadPaymentMethods(); // Reload payment methods to get the updated list
        return true;
      } else {
        _error = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh payment methods
  Future<void> refreshPaymentMethods() async {
    await loadPaymentMethods();
  }
} 