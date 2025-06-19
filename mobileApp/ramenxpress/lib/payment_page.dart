import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/delivery_addresses_provider.dart';
import 'providers/payment_methods_provider.dart';
import 'providers/order_history_provider.dart';
import 'providers/auth_provider.dart';
import 'services/order_service.dart';
import 'invoice_page.dart';
import 'models/delivery_address.dart';
import 'models/payment_method.dart';
import 'edit_address_page.dart';
import 'edit_payment_method_page.dart';
import 'services/api_service.dart';

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
      await context.read<PaymentMethodsProvider>().loadPaymentMethods();
      
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
              backgroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
                  child: Row(
                    children: [
                      const Text(
                        'Your Cart',
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      CircleAvatar(
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
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Looks like you haven\'t added anything to your cart yet',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1A1A1A),
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
                        backgroundColor: Color(0xFFD32D43),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_bag_outlined),
                          SizedBox(width: 8),
                          Text(
                            'Start Shopping',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
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
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
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
            selectedItemColor: Color(0xFFD32D43),
            unselectedItemColor: Color(0xFF1A1A1A),
            showSelectedLabels: false,
            showUnselectedLabels: false,
            backgroundColor: Colors.white,
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
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.white,
                padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
                child: Row(
                  children: [
                    const Text(
                      'Your Cart',
                      style: TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    CircleAvatar(
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
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.delivery_dining, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              'Delivery Method: ${context.read<CartProvider>().selectedDeliveryMethod}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (context.read<CartProvider>().selectedDeliveryMethod == 'Delivery' && context.read<CartProvider>().selectedAddress != null) ...[
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Address: ${context.read<CartProvider>().selectedAddress!.fullAddress}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
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
                            Icon(Icons.payment, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              'Payment: ${context.read<CartProvider>().selectedPaymentMethod?.displayName ?? 'Not selected'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Delivery Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
                        const Text(
                          'Delivery Address',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
                          icon: const Icon(Icons.add),
                          label: const Text('Add New'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (deliveryAddresses.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.location_off_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No delivery addresses found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Please add a delivery address to continue',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
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
                                    ? Colors.deepOrange.withOpacity(0.1)
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: context.read<CartProvider>().selectedAddress?.id == address.id
                                      ? Colors.deepOrange
                                      : Colors.grey[300]!,
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
                                            color: Colors.green[50],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'Default',
                                            style: TextStyle(
                                              color: Colors.green[700],
                                              fontSize: 12,
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
                  const Text(
                    'Payment Methods',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (filteredPaymentMethods.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.payment_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No payment methods found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please add a payment method to continue',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
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
                            icon: const Icon(Icons.add),
                            label: const Text('Add Payment Method'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
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
                                  ? Colors.deepOrange.withOpacity(0.1)
                                  : Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: context.read<CartProvider>().selectedPaymentMethod?.id == method.id
                                    ? Colors.deepOrange
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  method.icon,
                                  color: context.read<CartProvider>().selectedPaymentMethod?.id == method.id
                                      ? Colors.deepOrange
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        method.displayName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (method.isDefault)
                                        Container(
                                          margin: const EdgeInsets.only(top: 4),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green[50],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'Default',
                                            style: TextStyle(
                                              color: Colors.green[700],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditPaymentMethodPage(
                                          paymentMethod: method,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.edit_outlined),
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  if (filteredPaymentMethods.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditPaymentMethodPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add New Payment Method'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.deepOrange,
                        ),
                      ),
                    ),
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
                        backgroundColor: Color(0xFFD32D43),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Proceed to Checkout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
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
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
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
          selectedItemColor: Color(0xFFD32D43),
          unselectedItemColor: Color(0xFF1A1A1A),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          backgroundColor: Colors.white,
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
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
              child: _buildCartImage(imagePath),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₱${price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
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
                      color: Color(0xFF1A1A1A),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      quantity,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onIncrease,
                      icon: const Icon(Icons.add_circle_outline),
                      color: Color(0xFFD32D43),
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
            color: Color(0xFF1A1A1A),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildCartImage(String imagePath) {
    if (imagePath.isEmpty || imagePath.trim().isEmpty) {
      return const Image(
        image: AssetImage('assets/ramen1.jpg'),
        fit: BoxFit.cover,
      );
    }
    if (imagePath.startsWith('http')) {
      return Image.network(imagePath, fit: BoxFit.cover);
    }
    if (imagePath.startsWith('assets/')) {
      return Image.asset(imagePath, fit: BoxFit.cover);
    }
    if (imagePath.startsWith('/uploads/')) {
      return Image.network('http://localhost:3000$imagePath', fit: BoxFit.cover);
    }
    if (imagePath.contains('/') || imagePath.contains('\\')) {
      String filename = imagePath.split('/').last;
      if (filename.contains('\\')) {
        filename = filename.split('\\').last;
      }
      return Image.network('http://localhost:3000/uploads/$filename', fit: BoxFit.cover);
    }
    return Image.network('http://localhost:3000/uploads/$imagePath', fit: BoxFit.cover);
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Color(0xFF1A1A1A) : Color(0xFF1A1A1A),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? Color(0xFF1A1A1A) : Color(0xFF1A1A1A),
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
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepOrange.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.deepOrange : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.deepOrange : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.deepOrange : Color(0xFF1A1A1A),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Method: ${context.read<CartProvider>().selectedDeliveryMethod == 'Delivery' ? 'Delivery' : 'Pick Up'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (context.read<CartProvider>().selectedDeliveryMethod == 'Delivery') ...[
              const SizedBox(height: 8),
              Text(
                'Delivery Address:',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(context.read<CartProvider>().selectedAddress!.fullAddress),
            ],
            const SizedBox(height: 16),
            Text(
              'Payment Method: ${context.read<CartProvider>().selectedPaymentMethod!.displayName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Order Summary:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Subtotal: ₱${subtotal.toStringAsFixed(2)}'),
            Text('Shipping Fee: ₱${shippingFee.toStringAsFixed(2)}'),
            const Divider(),
            Text(
              'Total: ₱${total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processOrder(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFD32D43),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Order'),
          ),
        ],
      ),
    );
  }

  void _processOrder(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD32D43)),
        ),
      ),
    );

    try {
      final authProvider = context.read<AuthProvider>();
      final cartProvider = context.read<CartProvider>();
      
      if (!authProvider.isLoggedIn) {
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context); // Close loading dialog
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to place an order'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get token from API service
      final token = await ApiService.getToken();
      if (token == null) {
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context); // Close loading dialog
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication token not found'),
            backgroundColor: Colors.red,
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
        customerId: authProvider.customer?.id,
        deliveryAddress: deliveryAddressData,
        notes: cartProvider.notes.isNotEmpty ? cartProvider.notes : null,
        token: token,
      );

      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context); // Close loading dialog
      }

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order #${orderDetails['orderId']} placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to invoice page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InvoicePage(
              order: {
                'orderId': orderDetails['orderId'],
                'date': DateTime.parse(orderDetails['orderDate']),
                'status': orderDetails['status'],
                'total': orderDetails['total'],
                'items': orderDetails['items'],
                'orderType': orderDetails['orderType'],
                'deliveryAddress': orderDetails['deliveryAddress'],
                'paymentMethod': PaymentMethod(
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
                'notes': orderDetails['notes'],
              },
            ),
          ),
        );
      } else {
        // Show error message
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context); // Close loading dialog
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to place order'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context); // Close loading dialog
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 