import 'package:flutter/foundation.dart';
import '../models/payment_method.dart';
import '../models/delivery_address.dart';

class CartProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];
  String _selectedDeliveryMethod = 'Pick Up';
  PaymentMethod? _selectedPaymentMethod;
  DeliveryAddress? _selectedAddress;
  String _notes = '';

  List<Map<String, dynamic>> get items => _items;
  String get selectedDeliveryMethod => _selectedDeliveryMethod;
  PaymentMethod? get selectedPaymentMethod => _selectedPaymentMethod;
  DeliveryAddress? get selectedAddress => _selectedAddress;
  String get notes => _notes;

  double get subtotal {
    return _items.fold(0, (sum, item) {
      return sum + (item['price'] * item['quantity']);
    });
  }

  int get itemCount {
    return _items.fold(0, (sum, item) => sum + (item['quantity'] as int));
  }

  bool get isEmpty => _items.isEmpty;

  // Payment and delivery method setters
  void setDeliveryMethod(String method) {
    _selectedDeliveryMethod = method;
    notifyListeners();
  }

  void setPaymentMethod(PaymentMethod? method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  void setDeliveryAddress(DeliveryAddress? address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void setNotes(String notes) {
    _notes = notes;
    notifyListeners();
  }

  void addItem(Map<String, dynamic> item) {
    final existingItemIndex = _items.indexWhere((i) => i['id'] == item['id']);
    
    if (existingItemIndex >= 0) {
      _items[existingItemIndex]['quantity'] += 1;
    } else {
      _items.add({
        ...item,
        'quantity': 1,
      });
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item['id'] == id);
    notifyListeners();
  }

  void updateQuantity(String id, int change) {
    final index = _items.indexWhere((item) => item['id'] == id);
    if (index >= 0) {
      int newQuantity = _items[index]['quantity'] + change;
      if (newQuantity > 0) {
        _items[index]['quantity'] = newQuantity;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _selectedDeliveryMethod = 'Pick Up';
    _selectedPaymentMethod = null;
    _selectedAddress = null;
    _notes = '';
    notifyListeners();
  }

  // Get cart items formatted for order placement
  List<Map<String, dynamic>> getOrderItems() {
    return _items.map((item) => {
      'menuId': item['id'],
      'quantity': item['quantity'],
      'addOns': item['addOns'] ?? [],
    }).toList();
  }

  // Check if cart has items
  bool hasItems() {
    return _items.isNotEmpty;
  }

  // Get item by ID
  Map<String, dynamic>? getItemById(String id) {
    try {
      return _items.firstWhere((item) => item['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Update item add-ons
  void updateItemAddOns(String id, List<Map<String, dynamic>> addOns) {
    final index = _items.indexWhere((item) => item['id'] == id);
    if (index >= 0) {
      _items[index]['addOns'] = addOns;
      // Recalculate price with add-ons
      double basePrice = _items[index]['basePrice'] ?? _items[index]['price'];
      double addOnsTotal = addOns.fold(0, (sum, addon) => sum + addon['price']);
      _items[index]['price'] = basePrice + addOnsTotal;
      notifyListeners();
    }
  }
} 