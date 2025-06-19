class DeliveryAddress {
  final String id;
  final String label;
  final String recipientName;
  final String phoneNumber;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final bool isDefault;
  final bool isActive;

  DeliveryAddress({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phoneNumber,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    this.country = 'Philippines',
    this.isDefault = false,
    this.isActive = true,
  });

  String get fullAddress => '$street, $city, $state $zipCode, $country';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'recipientName': recipientName,
      'phoneNumber': phoneNumber,
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'isDefault': isDefault,
      'isActive': isActive,
    };
  }

  factory DeliveryAddress.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DeliveryAddress(
        id: '',
        label: '',
        recipientName: '',
        phoneNumber: '',
        street: '',
        city: '',
        state: '',
        zipCode: '',
        country: 'Philippines',
        isDefault: false,
        isActive: true,
      );
    }
    return DeliveryAddress(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      recipientName: json['recipientName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      country: json['country'] ?? 'Philippines',
      isDefault: json['isDefault'] ?? false,
      isActive: json['isActive'] ?? true,
    );
  }
} 