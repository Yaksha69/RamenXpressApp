import 'package:flutter/foundation.dart';

class CartProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  double get subtotal {
    return _items.fold(0, (sum, item) {
      return sum + (item['price'] * item['quantity']);
    });
  }

  void addItem(Map<String, dynamic> item) {
    final existingItemIndex =
        _items.indexWhere((i) => i['name'] == item['name']);

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

  void removeItem(String name) {
    _items.removeWhere((item) => item['name'] == name);
    notifyListeners();
  }

  void updateQuantity(String name, int change) {
    final index = _items.indexWhere((item) => item['name'] == name);
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
    notifyListeners();
  }
}
