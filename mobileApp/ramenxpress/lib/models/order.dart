class Order {
  final int orderId;
  final String? customerId;
  final List<OrderItem> items;
  final double total;
  final String orderType;
  final String paymentMethod;
  final DeliveryAddress? deliveryAddress;
  final double deliveryFee;
  final String status;
  final String notes;
  final DateTime orderDate;

  Order({
    required this.orderId,
    this.customerId,
    required this.items,
    required this.total,
    required this.orderType,
    required this.paymentMethod,
    this.deliveryAddress,
    required this.deliveryFee,
    required this.status,
    required this.notes,
    required this.orderDate,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // Handle customerId which can be either a string or a populated object
    String? customerId;
    if (json['customerId'] is String) {
      customerId = json['customerId'];
    } else if (json['customerId'] is Map<String, dynamic>) {
      customerId = json['customerId']['_id'];
    }

    return Order(
      orderId: json['orderId'],
      customerId: customerId,
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      total: (json['total'] is int) ? (json['total'] as int).toDouble() : json['total'].toDouble(),
      orderType: json['orderType'],
      paymentMethod: json['paymentMethod'],
      deliveryAddress: json['deliveryAddress'] != null 
          ? DeliveryAddress.fromJson(json['deliveryAddress'])
          : null,
      deliveryFee: (json['deliveryFee'] is int) ? (json['deliveryFee'] as int).toDouble() : json['deliveryFee'].toDouble(),
      status: json['status'],
      notes: json['notes'] ?? '',
      orderDate: DateTime.parse(json['orderDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'customerId': customerId,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'orderType': orderType,
      'paymentMethod': paymentMethod,
      'deliveryAddress': deliveryAddress?.toJson(),
      'deliveryFee': deliveryFee,
      'status': status,
      'notes': notes,
      'orderDate': orderDate.toIso8601String(),
    };
  }
}

class OrderItem {
  final String name;
  final double price;
  final int quantity;
  final double total;
  final List<AddOn> addOns;

  OrderItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.total,
    required this.addOns,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'],
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : json['price'].toDouble(),
      quantity: json['quantity'],
      total: (json['total'] is int) ? (json['total'] as int).toDouble() : json['total'].toDouble(),
      addOns: (json['addOns'] as List<dynamic>?)
          ?.map((addon) => AddOn.fromJson(addon))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
      'total': total,
      'addOns': addOns.map((addon) => addon.toJson()).toList(),
    };
  }
}

class AddOn {
  final String name;
  final double price;

  AddOn({
    required this.name,
    required this.price,
  });

  factory AddOn.fromJson(Map<String, dynamic> json) {
    return AddOn(
      name: json['name'],
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : json['price'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
    };
  }
}

class DeliveryAddress {
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final bool isDefault;

  DeliveryAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    required this.isDefault,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      country: json['country'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'isDefault': isDefault,
    };
  }

  String get fullAddress {
    return '$street, $city, $state $zipCode, $country';
  }
} 