import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/delivery_addresses_provider.dart';
import 'providers/payment_methods_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/order_history_provider.dart';
import 'models/payment_method.dart';
import 'models/delivery_address.dart';
import 'services/api_service.dart';
import 'services/order_service.dart';
import 'edit_payment_method_page.dart';
import 'edit_address_page.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _notesController = TextEditingController();

  void updateQuantity(String name, int change) {
    context.read<CartProvider>().updateQuantity(name, change);
  }

  void removeItem(String name) {
    context.read<CartProvider>().removeItem(name);
  }

  double get subtotal => context.read<CartProvider>().subtotal;
  double get shippingFee => context.read<CartProvider>().selectedDeliveryMethod == 'Delivery' ? 50.0 : 0.0;
  double get total => subtotal + shippingFee;

  @override
  void initState() {
    super.initState();
    // Load saved addresses and payment methods from backend
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final cartProvider = context.read<CartProvider>();
      
      // Load addresses and payment methods from backend
      await context.read<DeliveryAddressesProvider>().loadAddresses();
      if (!mounted) return;
      
      await context.read<PaymentMethodsProvider>().loadPaymentMethods();
      if (!mounted) return;
      
      // Set default payment method if available and none is selected
      if (cartProvider.selectedPaymentMethod == null) {
        final defaultMethod = context.read<PaymentMethodsProvider>().defaultPaymentMethod;
        if (defaultMethod != null) {
          cartProvider.setPaymentMethod(defaultMethod);
        }
      }
      
      // Set default address if delivery is selected and no address is chosen
      if (cartProvider.selectedDeliveryMethod == 'Delivery' && cartProvider.selectedAddress == null) {
        final defaultAddress = context.read<DeliveryAddressesProvider>().defaultAddress;
        if (defaultAddress != null) {
          cartProvider.setDeliveryAddress(defaultAddress);
        }
      }
      
      // Set notes controller text
      _notesController.text = cartProvider.notes;
      
      // Add listener to save notes to cart provider
      _notesController.addListener(() {
        cartProvider.setNotes(_notesController.text);
      });
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cartItems = context.watch<CartProvider>().items;
    final deliveryAddresses = context.watch<DeliveryAddressesProvider>().addresses;
    final paymentMethods = context.watch<PaymentMethodsProvider>().paymentMethods;

    // Filter payment methods based on delivery method
    List<PaymentMethod> filteredPaymentMethods = paymentMethods.where((method) {
      // Only GCash and PayMaya for Pick Up
      if (context.read<CartProvider>().selectedDeliveryMethod == 'Pick Up') {
        return method.type == PaymentType.gcash || method.type == PaymentType.paymaya;
      }
      // For Delivery, only GCash and PayMaya (COD handled separately)
      return method.type == PaymentType.gcash || method.type == PaymentType.paymaya;
    }).toList();

    if (cartItems.isEmpty) {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              expandedHeight: 120,
              backgroundColor: colorScheme.surface,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: colorScheme.surface,
                  padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
                  child: Row(
                    children: [
                      Text(
                        'Your Cart',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const CircleAvatar(
                        backgroundImage: AssetImage('assets/adminPIC.png'),
                        radius: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverFillRemaining(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 100,
                    opacity: const AlwaysStoppedAnimation(0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Looks like you haven\'t added anything to your cart yet',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_bag_outlined, color: colorScheme.onPrimary),
                          const SizedBox(width: 8),
                          Text(
                            'Start Shopping',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: colorScheme.onSurface.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: 1,
            onTap: (index) {
              switch (index) {
                case 0:
                  Navigator.pushReplacementNamed(context, '/home');
                  break;
                case 1:
                  // Already on payment page
                  break;
                case 2:
                  Navigator.pushReplacementNamed(context, '/order-history');
                  break;
                case 3:
                  Navigator.pushReplacementNamed(context, '/profile');
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.history), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
            ],
            selectedItemColor: colorScheme.primary,
            unselectedItemColor: colorScheme.onSurface,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            backgroundColor: colorScheme.surface,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120,
            backgroundColor: colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: colorScheme.surface,
                padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
                child: Row(
                  children: [
                    Text(
                      'Your Cart',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const CircleAvatar(
                      backgroundImage: AssetImage('assets/adminPIC.png'),
                      radius: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...cartItems.map((item) {
                    return _cartItem(
                      item['name'],
                      item['price'],
                      item['image'],
                      item['quantity'].toString(),
                      () => context.read<CartProvider>().updateQuantity(item['name'], -1),
                      () => context.read<CartProvider>().updateQuantity(item['name'], 1),
                      () => context.read<CartProvider>().removeItem(item['name']),
                    );
                  }).toList(),
                  const SizedBox(height: 24),
                  const Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _summaryRow('Subtotal', 'PHP ${subtotal.toStringAsFixed(2)}'),
                  _summaryRow('Shipping Fee', 'PHP ${shippingFee.toStringAsFixed(2)}'),
                  const Divider(height: 32),
                  _summaryRow('Total', 'PHP ${total.toStringAsFixed(2)}', isTotal: true),
                  const SizedBox(height: 24),
                  
                  // Payment and Delivery Information Display
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.onSurface.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.delivery_dining, size: 16, color: colorScheme.onSurface.withOpacity(0.6)),
                            const SizedBox(width: 8),
                            Text(
                              'Delivery Method: ${context.read<CartProvider>().selectedDeliveryMethod}',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurface.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (context.read<CartProvider>().selectedDeliveryMethod == 'Delivery' && context.read<CartProvider>().selectedAddress != null) ...[
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: colorScheme.onSurface.withOpacity(0.6)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Address: ${context.read<CartProvider>().selectedAddress!.fullAddress}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.onSurface.withOpacity(0.8),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        Row(
                          children: [
                            Icon(Icons.payment, size: 16, color: colorScheme.onSurface.withOpacity(0.6)),
                            const SizedBox(width: 8),
                            Text(
                              'Payment: ${context.read<CartProvider>().selectedPaymentMethod?.displayName ?? 'Not selected'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurface.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Delivery Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _deliveryOption(
                          'Pick Up',
                          Icons.store,
                          context.read<CartProvider>().selectedDeliveryMethod == 'Pick Up',
                          () {
                            context.read<CartProvider>().setDeliveryMethod('Pick Up');
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _deliveryOption(
                          'Delivery',
                          Icons.delivery_dining,
                          context.read<CartProvider>().selectedDeliveryMethod == 'Delivery',
                          () {
                            context.read<CartProvider>().setDeliveryMethod('Delivery');
                          },
                        ),
                      ),
                    ],
                  ),
                  if (context.read<CartProvider>().selectedDeliveryMethod == 'Delivery') ...[
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Delivery Address',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditAddressPage(),
                              ),
                            );
                          },
                          icon: Icon(Icons.add, color: colorScheme.primary),
                          label: Text('Add New', style: TextStyle(color: colorScheme.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (deliveryAddresses.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.onSurface.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorScheme.onSurface.withOpacity(0.1)),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.location_off_outlined,
                              size: 48,
                              color: colorScheme.onSurface.withOpacity(0.4),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No delivery addresses found',
                              style: TextStyle(
                                fontSize: 16,
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Please add a delivery address to continue',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      ...deliveryAddresses.map((address) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () {
                              context.read<CartProvider>().setDeliveryAddress(address);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: context.read<CartProvider>().selectedAddress?.id == address.id
                                    ? colorScheme.primary.withOpacity(0.1)
                                    : colorScheme.onSurface.withOpacity(0.02),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: context.read<CartProvider>().selectedAddress?.id == address.id
                                      ? colorScheme.primary
                                      : colorScheme.onSurface.withOpacity(0.1),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          address.fullAddress,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (address.isDefault)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: colorScheme.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'Default',
                                            style: TextStyle(
                                              color: colorScheme.primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'Payment Methods',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (filteredPaymentMethods.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.onSurface.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.payment_outlined,
                            size: 48,
                            color: colorScheme.onSurface.withOpacity(0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No payment methods found',
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please add a payment method to continue',
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EditPaymentMethodPage(),
                                ),
                              );
                            },
                            icon: Icon(Icons.add, color: colorScheme.onPrimary),
                            label: Text('Add Payment Method', style: TextStyle(color: colorScheme.onPrimary)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...filteredPaymentMethods.map((method) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            context.read<CartProvider>().setPaymentMethod(method);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: context.read<CartProvider>().selectedPaymentMethod?.id == method.id
                                  ? colorScheme.primary.withOpacity(0.1)
                                  : colorScheme.onSurface.withOpacity(0.02),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: context.read<CartProvider>().selectedPaymentMethod?.id == method.id
                                    ? colorScheme.primary
                                    : colorScheme.onSurface.withOpacity(0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        method.title,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        method.accountNumber,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: colorScheme.onSurface.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (method.isDefault)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Default',
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  const SizedBox(height: 24),
                  const Text(
                    'Delivery Notes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add delivery notes...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final cartProvider = context.read<CartProvider>();
                        if (cartProvider.selectedDeliveryMethod == 'Delivery' && cartProvider.selectedAddress == null) return;
                        if (cartProvider.selectedPaymentMethod == null) return;
                        _showConfirmationDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Proceed to Checkout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 1,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/home');
                break;
              case 1:
                // Already on payment page
                break;
              case 2:
                Navigator.pushReplacementNamed(context, '/order-history');
                break;
              case 3:
                Navigator.pushReplacementNamed(context, '/profile');
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          ],
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurface,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          backgroundColor: colorScheme.surface,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }

  Widget _cartItem(
    String name,
    double price,
    String imagePath,
    String quantity,
    VoidCallback onDecrease,
    VoidCallback onIncrease,
    VoidCallback onRemove,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _getImageWidget(imagePath),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₱${price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: onDecrease,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: colorScheme.onSurface,
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      quantity,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onIncrease,
                      icon: const Icon(Icons.add_circle_outline),
                      color: colorScheme.primary,
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline),
            color: colorScheme.onSurface,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _getImageWidget(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(imagePath, fit: BoxFit.cover);
    }
    
    // Get base URL based on platform
    final baseUrl = ApiService.baseUrl;
    
    if (imagePath.startsWith('/uploads/')) {
      return Image.network('$baseUrl$imagePath', fit: BoxFit.cover);
    }
    if (imagePath.contains('/') || imagePath.contains('\\')) {
      String filename = imagePath.split('/').last;
      if (filename.contains('\\')) {
        filename = filename.split('\\').last;
      }
      return Image.network('$baseUrl/uploads/$filename', fit: BoxFit.cover);
    }
    return Image.network('$baseUrl/uploads/$imagePath', fit: BoxFit.cover);
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _deliveryOption(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary.withOpacity(0.1) : colorScheme.onSurface.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Order', style: TextStyle(color: colorScheme.onSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Method: ${context.read<CartProvider>().selectedDeliveryMethod == 'Delivery' ? 'Delivery' : 'Pick Up'}',
              style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
            if (context.read<CartProvider>().selectedDeliveryMethod == 'Delivery') ...[
              const SizedBox(height: 8),
              Text(
                'Delivery Address:',
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
              ),
              Text(context.read<CartProvider>().selectedAddress!.fullAddress, style: TextStyle(color: colorScheme.onSurface)),
            ],
            const SizedBox(height: 16),
            Text(
              'Payment Method: ${context.read<CartProvider>().selectedPaymentMethod!.displayName}',
              style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            Text(
              'Order Summary:',
              style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text('Subtotal: ₱${subtotal.toStringAsFixed(2)}', style: TextStyle(color: colorScheme.onSurface)),
            Text('Shipping Fee: ₱${shippingFee.toStringAsFixed(2)}', style: TextStyle(color: colorScheme.onSurface)),
            Divider(color: colorScheme.onSurface.withOpacity(0.1)),
            Text(
              'Total: ₱${total.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: colorScheme.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processOrder(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: Text('Confirm Order', style: TextStyle(color: colorScheme.onPrimary)),
          ),
        ],
      ),
    );
  }

  void _processOrder(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        ),
      ),
    );

    try {
      final authProvider = context.read<AuthProvider>();
      final cartProvider = context.read<CartProvider>();
      
      if (!authProvider.isLoggedIn) {
        if (!mounted) return;
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please login to place an order'),
            backgroundColor: colorScheme.primary,
          ),
        );
        return;
      }

      // Get token from API service
      final token = await ApiService.getToken();
      if (!mounted) return;
      if (token == null) {
        if (!mounted) return;
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Authentication token not found'),
            backgroundColor: colorScheme.primary,
          ),
        );
        return;
      }

      // Prepare order data
      final orderItems = cartProvider.getOrderItems();
      final orderType = cartProvider.selectedDeliveryMethod == 'Delivery' ? 'delivery' : 'takeout';
      String paymentMethod;
      paymentMethod = cartProvider.selectedPaymentMethod?.type == PaymentType.gcash
          ? 'gcash'
          : 'paymaya';
      
      Map<String, dynamic>? deliveryAddressData;
      if (cartProvider.selectedDeliveryMethod == 'Delivery' && cartProvider.selectedAddress != null) {
        deliveryAddressData = cartProvider.selectedAddress!.toJson();
      }

      // Place order with backend
      final result = await OrderService.placeOrder(
        items: orderItems,
        orderType: orderType,
        paymentMethod: paymentMethod,
        total: total,
        deliveryFee: shippingFee,
        deliveryAddress: deliveryAddressData,
        notes: cartProvider.notes.isNotEmpty ? cartProvider.notes : null,
        token: token,
      );
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      if (result['success']) {
        // Clear cart
        cartProvider.clearCart();

        // Add order to history
        final orderDetails = result['orderDetails'];
        
        context.read<OrderHistoryProvider>().addOrder(
          orderId: orderDetails['orderId'],
          date: DateTime.parse(orderDetails['orderDate']),
          status: orderDetails['status'],
          total: orderDetails['total'].toDouble(),
          items: orderDetails['items'].map<Map<String, dynamic>>((item) => {
            'name': item['name'],
            'quantity': item['quantity'],
            'price': item['price'],
            'addons': item['addOns'] ?? [],
          }).toList(),
          deliveryMethod: orderDetails['orderType'],
          deliveryAddress: orderDetails['deliveryAddress'] != null 
              ? DeliveryAddress.fromJson(orderDetails['deliveryAddress'])
              : null,
          paymentMethod: PaymentMethod(
            id: '1',
            type: orderDetails['paymentMethod'] == 'gcash' 
                ? PaymentType.gcash 
                : PaymentType.paymaya,
            title: orderDetails['paymentMethod'] == 'cash' 
                ? 'Cash on Delivery' 
                : orderDetails['paymentMethod'].toUpperCase(),
            accountName: orderDetails['paymentMethod'] == 'cash' ? 'N/A' : 'Customer',
            accountNumber: orderDetails['paymentMethod'] == 'cash' ? 'N/A' : '****',
            isDefault: false,
          ),
          notes: orderDetails['notes'],
        );

        // Show success message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order #${orderDetails['orderId']} placed successfully! Tap on the order in Order History to view your invoice.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );

        // Navigate to order history page
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/order-history');
      } else {
        // Show error message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to place order'),
            backgroundColor: colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: colorScheme.primary,
        ),
      );
    }
  }
} 