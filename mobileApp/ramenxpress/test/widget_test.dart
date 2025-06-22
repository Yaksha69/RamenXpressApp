// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ramenxpress/providers/auth_provider.dart';
import 'package:ramenxpress/providers/menu_provider.dart';
import 'package:ramenxpress/providers/cart_provider.dart';
import 'package:ramenxpress/providers/notifications_provider.dart';
import 'package:ramenxpress/providers/profile_provider.dart';
import 'package:ramenxpress/providers/delivery_addresses_provider.dart';
import 'package:ramenxpress/providers/payment_methods_provider.dart';
import 'package:ramenxpress/providers/order_history_provider.dart';

void main() {
  testWidgets('Providers can be created and accessed', (WidgetTester tester) async {
    // Build a simple widget tree with providers
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => AuthProvider()),
            ChangeNotifierProvider(create: (context) => MenuProvider()),
            ChangeNotifierProvider(create: (context) => CartProvider()),
            ChangeNotifierProvider(create: (context) => NotificationsProvider()),
            ChangeNotifierProvider(create: (context) => ProfileProvider()),
            ChangeNotifierProvider(create: (context) => DeliveryAddressesProvider()),
            ChangeNotifierProvider(create: (context) => PaymentMethodsProvider()),
            ChangeNotifierProvider(create: (context) => OrderHistoryProvider()),
          ],
          child: Builder(
            builder: (context) {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final menuProvider = Provider.of<MenuProvider>(context, listen: false);
              final cartProvider = Provider.of<CartProvider>(context, listen: false);
              
              return Scaffold(
                body: Column(
                  children: [
                    Text('AuthProvider: ${authProvider != null}'),
                    Text('MenuProvider: ${menuProvider != null}'),
                    Text('CartProvider: ${cartProvider != null}'),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    // Verify that providers are available
    expect(find.text('AuthProvider: true'), findsOneWidget);
    expect(find.text('MenuProvider: true'), findsOneWidget);
    expect(find.text('CartProvider: true'), findsOneWidget);
  });

  testWidgets('AuthProvider initial state is correct', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (context) => AuthProvider(),
          child: Builder(
            builder: (context) {
              final authProvider = Provider.of<AuthProvider>(context);
              return Scaffold(
                body: Text('IsLoggedIn: ${authProvider.isLoggedIn}'),
              );
            },
          ),
        ),
      ),
    );

    // Verify initial state
    expect(find.text('IsLoggedIn: false'), findsOneWidget);
  });

  testWidgets('CartProvider initial state is correct', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (context) => CartProvider(),
          child: Builder(
            builder: (context) {
              final cartProvider = Provider.of<CartProvider>(context);
              return Scaffold(
                body: Text('CartItems: ${cartProvider.items.length}'),
              );
            },
          ),
        ),
      ),
    );

    // Verify initial state
    expect(find.text('CartItems: 0'), findsOneWidget);
  });
}
