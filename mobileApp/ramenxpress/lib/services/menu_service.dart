import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menu_item.dart';
import 'api_service.dart';

class MenuService {
  // Get all menu items
  static Future<Map<String, dynamic>> getAllMenuItems() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/v1/menu-public/allmenu'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        try {
          final List<MenuItem> menuItems = data.map((json) => MenuItem.fromJson(json)).toList();
          
          return {
            'success': true,
            'data': menuItems,
          };
        } catch (parseError) {
          return {
            'success': false,
            'message': 'Error parsing menu data: ${parseError.toString()}',
            'error': parseError.toString(),
          };
        }
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch menu items',
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

  // Get menu items by category
  static Future<Map<String, dynamic>> getMenusByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/v1/menu-public/category/$category'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        try {
          final List<MenuItem> menuItems = data.map((json) {
            return MenuItem.fromJson(json);
          }).toList();
          
          return {
            'success': true,
            'data': menuItems,
          };
        } catch (parseError) {
          return {
            'success': false,
            'message': 'Error parsing menu data: ${parseError.toString()}',
            'error': parseError.toString(),
          };
        }
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch menu items',
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

  // Get available categories
  static List<String> getAvailableCategories() {
    return [
      'All',
      'ramen',
      'rice bowls',
      'side dishes',
      'sushi',
      'party trays',
      'add-ons',
      'drinks',
    ];
  }

  // Get add-ons for different categories
  static Map<String, List<Map<String, dynamic>>> getAddOns() {
    return {
      'ramen': [
        {'name': 'Extra Noodles', 'price': 30.0},
        {'name': 'Extra Chashu', 'price': 50.0},
        {'name': 'Extra Egg', 'price': 20.0},
        {'name': 'Extra Vegetables', 'price': 25.0},
      ],
      'rice bowls': [
        {'name': 'Extra Rice', 'price': 15.0},
        {'name': 'Extra Meat', 'price': 40.0},
        {'name': 'Extra Egg', 'price': 20.0},
        {'name': 'Extra Sauce', 'price': 10.0},
      ],
      'side dishes': [
        {'name': 'Extra Sauce', 'price': 10.0},
        {'name': 'Extra Portion', 'price': 30.0},
      ],
      'drinks': [
        {'name': 'Extra Ice', 'price': 0.0},
        {'name': 'Extra Shot', 'price': 15.0},
      ],
    };
  }
} 