import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/menu_service.dart';

class MenuProvider extends ChangeNotifier {
  List<MenuItem> _menuItems = [];
  List<MenuItem> _filteredMenuItems = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  List<MenuItem> get menuItems => _menuItems;
  List<MenuItem> get filteredMenuItems => _filteredMenuItems;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get unique categories from menu items
  List<String> get availableCategories {
    final categories = _menuItems
        .map((item) => item.category)
        .where((category) => category.isNotEmpty && category != 'unknown')
        .toSet()
        .toList();
    categories.insert(0, 'All');
    return categories;
  }

  // Initialize and load menu items
  Future<void> loadMenuItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await MenuService.getAllMenuItems();
      
      if (result['success']) {
        _menuItems = result['data'];
        _applyFilters();
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

  // Load menu items by category
  Future<void> loadMenuItemsByCategory(String category) async {
    if (category == 'All') {
      await loadMenuItems();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await MenuService.getMenusByCategory(category);
      
      if (result['success']) {
        _menuItems = result['data'];
        _applyFilters();
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

  // Set selected category
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Apply filters (category and search)
  void _applyFilters() {
    List<MenuItem> filtered = _menuItems;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((item) => 
        item.category == _selectedCategory && 
        item.category.isNotEmpty && 
        item.category != 'unknown'
      ).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) => 
        item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (item.category.isNotEmpty && 
         item.category != 'unknown' && 
         item.category.toLowerCase().contains(_searchQuery.toLowerCase()))
      ).toList();
    }

    _filteredMenuItems = filtered;
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh menu items
  Future<void> refresh() async {
    await loadMenuItems();
  }

  // Get add-ons for a specific category
  List<Map<String, dynamic>> getAddOnsForCategory(String category) {
    final addOns = MenuService.getAddOns();
    return addOns[category] ?? [];
  }

  // Get menu item by ID
  MenuItem? getMenuItemById(String id) {
    try {
      return _menuItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get menu items by category (local filter)
  List<MenuItem> getMenuItemsByCategory(String category) {
    if (category == 'All') {
      return _menuItems;
    }
    return _menuItems.where((item) => item.category == category).toList();
  }
} 