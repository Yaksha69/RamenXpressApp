class MenuItem {
  final String id;
  final String name;
  final double price;
  final String category;
  final String image;
  final List<Ingredient> ingredients;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.image,
    required this.ingredients,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? 'Unknown Item',
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : (json['price'] ?? 0.0).toDouble(),
      category: json['category'] ?? 'unknown',
      image: json['image'] ?? '',
      ingredients: (json['ingredients'] as List<dynamic>?)
          ?.map((ingredient) => Ingredient.fromJson(ingredient))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'image': image,
      'ingredients': ingredients.map((ingredient) => ingredient.toJson()).toList(),
    };
  }
}

class Ingredient {
  final String inventoryItem;
  final int quantity;

  Ingredient({
    required this.inventoryItem,
    required this.quantity,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      inventoryItem: json['inventoryItem'] ?? 'Unknown Ingredient',
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inventoryItem': inventoryItem,
      'quantity': quantity,
    };
  }
} 