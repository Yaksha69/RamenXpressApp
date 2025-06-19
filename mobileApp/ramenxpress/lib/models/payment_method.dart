import 'package:flutter/material.dart';

enum PaymentType {
  gcash,
  paymaya,
}

class PaymentMethod {
  final String id;
  final PaymentType type;
  final String title;
  final String accountNumber; // This will store the phone number
  final String accountName; // This will store the full name
  final bool isDefault;
  final bool isActive;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.title,
    required this.accountNumber,
    required this.accountName,
    this.isDefault = false,
    this.isActive = true,
  });

  String get displayName {
    switch (type) {
      case PaymentType.gcash:
        return 'GCash •••• ${accountNumber.substring(accountNumber.length - 4)}';
      case PaymentType.paymaya:
        return 'PayMaya •••• ${accountNumber.substring(accountNumber.length - 4)}';
    }
  }

  String get fullDisplayName {
    return '$displayName - $accountName';
  }

  IconData get icon {
    switch (type) {
      case PaymentType.gcash:
        return Icons.account_balance_wallet;
      case PaymentType.paymaya:
        return Icons.account_balance;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'title': title,
      'accountNumber': accountNumber,
      'accountName': accountName,
      'isDefault': isDefault,
      'isActive': isActive,
    };
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      type: PaymentType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => PaymentType.gcash,
      ),
      title: json['title'],
      accountNumber: json['accountNumber'],
      accountName: json['accountName'],
      isDefault: json['isDefault'] ?? false,
      isActive: json['isActive'] ?? true,
    );
  }
} 