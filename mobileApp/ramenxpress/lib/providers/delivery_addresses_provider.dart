import 'package:flutter/material.dart';
import '../models/delivery_address.dart';
import '../services/address_service.dart';
import '../services/api_service.dart';

class DeliveryAddressesProvider extends ChangeNotifier {
  List<DeliveryAddress> _addresses = [];
  bool _isLoading = false;
  String? _error;

  List<DeliveryAddress> get addresses => List.unmodifiable(_addresses);
  bool get isLoading => _isLoading;
  String? get error => _error;

  DeliveryAddress? get defaultAddress {
    try {
      return _addresses.firstWhere((address) => address.isDefault);
    } catch (e) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  // Load addresses from backend
  Future<void> loadAddresses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await ApiService.getToken();
      if (token == null) {
        _error = 'Authentication token not found';
        return;
      }

      final result = await AddressService.getCustomerAddresses(token: token);

      if (result['success']) {
        _addresses = result['data'] as List<DeliveryAddress>;
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

  // Create a new address
  Future<bool> createAddress({
    required String label,
    required String recipientName,
    required String phoneNumber,
    required String street,
    required String city,
    required String state,
    required String zipCode,
    String country = 'Philippines',
    bool isDefault = false,
  }) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        _error = 'Authentication token not found';
        notifyListeners();
        return false;
      }

      final result = await AddressService.createAddress(
        label: label,
        recipientName: recipientName,
        phoneNumber: phoneNumber,
        street: street,
        city: city,
        state: state,
        zipCode: zipCode,
        country: country,
        isDefault: isDefault,
        token: token,
      );

      if (result['success']) {
        await loadAddresses(); // Reload addresses to get the updated list
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

  // Update an address
  Future<bool> updateAddress({
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
  }) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        _error = 'Authentication token not found';
        notifyListeners();
        return false;
      }

      final result = await AddressService.updateAddress(
        addressId: addressId,
        label: label,
        recipientName: recipientName,
        phoneNumber: phoneNumber,
        street: street,
        city: city,
        state: state,
        zipCode: zipCode,
        country: country,
        isDefault: isDefault,
        token: token,
      );

      if (result['success']) {
        await loadAddresses(); // Reload addresses to get the updated list
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

  // Delete an address
  Future<bool> deleteAddress(String addressId) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        _error = 'Authentication token not found';
        notifyListeners();
        return false;
      }

      final result = await AddressService.deleteAddress(
        addressId: addressId,
        token: token,
      );

      if (result['success']) {
        await loadAddresses(); // Reload addresses to get the updated list
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

  // Set default address
  Future<bool> setDefaultAddress(String addressId) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        _error = 'Authentication token not found';
        notifyListeners();
        return false;
      }

      final result = await AddressService.setDefaultAddress(
        addressId: addressId,
        token: token,
      );

      if (result['success']) {
        await loadAddresses(); // Reload addresses to get the updated list
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

  // Refresh addresses
  Future<void> refreshAddresses() async {
    await loadAddresses();
  }
} 