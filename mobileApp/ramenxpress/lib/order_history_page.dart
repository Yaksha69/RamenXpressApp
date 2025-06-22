import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/order_history_provider.dart';
import 'providers/auth_provider.dart';
import 'invoice_page.dart';
import 'models/payment_method.dart';
import 'models/delivery_address.dart';
import 'services/order_service.dart';
import 'services/api_service.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  @override
  void initState() {
    super.initState();
    // Load orders when page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  Future<void> _loadOrders() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isLoggedIn && authProvider.customer != null) {
      await context.read<OrderHistoryProvider>().loadCustomerOrders(
        authProvider.customer!.id,
      );
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.withOpacity(0.2);
      case 'preparing':
        return Colors.blue.withOpacity(0.2);
      case 'ready':
        return Colors.green.withOpacity(0.2);
      case 'delivered':
        return Colors.green.withOpacity(0.2);
      case 'cancelled':
        return Colors.red.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade800;
      case 'preparing':
        return Colors.blue.shade800;
      case 'ready':
        return Colors.green.shade800;
      case 'delivered':
        return Colors.green.shade800;
      case 'cancelled':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final orders = context.watch<OrderHistoryProvider>().orders;
    final currencyFormat = NumberFormat.currency(symbol: '₱');
    final dateFormat = DateFormat('MMM d, yyyy h:mm a');

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: CustomScrollView(
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
                        'Order History',
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
              child: orders.isEmpty
                  ? Center(
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
                            'No orders yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your order history will appear here',
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                            child: Text(
                              'Latest Orders',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          ...orders.map((order) {
                            // Format order ID to be 5 digits
                            return _OrderCard(order: order, getStatusBackgroundColor: _getStatusBackgroundColor, getStatusTextColor: _getStatusTextColor,);
                          }).toList(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 2,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/home');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/payment');
                break;
              case 2:
                // Already on order history page
                break;
              case 3:
                Navigator.pushReplacementNamed(context, '/profile');
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: 'Cart'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurface,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          backgroundColor: colorScheme.surface,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.getStatusBackgroundColor,
    required this.getStatusTextColor,
  });

  final dynamic order;
  final Color Function(String) getStatusBackgroundColor;
  final Color Function(String) getStatusTextColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormat = NumberFormat.currency(symbol: '₱');
    final dateFormat = DateFormat('MMM d, yyyy h:mm a');
    final orderId = order.orderId.toString().padLeft(4, '0');

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 0,
        vertical: 8,
      ),
      child: InkWell(
        highlightColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
        splashColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
        onTap: () async {
          try {
            // Get token
            final token = await ApiService.getToken();
            if (token == null) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Authentication token not found'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            // Fetch invoice data from backend
            final result = await OrderService.getOrderInvoice(
              orderId: order.orderId,
              token: token,
            );

            if (!context.mounted) return;

            if (result['success']) {
              final invoiceData = result['data'];

              // Navigate to invoice page with backend data
              final orderData = {
                'orderId': invoiceData['orderId'] ?? orderId,
                'date': invoiceData['orderDate'] != null
                    ? DateTime.parse(invoiceData['orderDate'])
                    : order.orderDate,
                'status': invoiceData['status'] ?? order.status,
                'total': (invoiceData['total'] ?? order.total).toDouble(),
                'items': (invoiceData['items'] as List?)
                    ?.map<Map<String, dynamic>>((item) => {
                  'name': item['name'] ?? 'Unknown Item',
                  'price': (item['price'] ?? 0.0).toDouble(),
                  'quantity': item['quantity'] ?? 0,
                  'addons':
                  item['addOns']?.map((addon) => addon['name']).toList() ??
                      [],
                })
                    .toList() ??
                    order.items
                        .map((item) => {
                      'name': item.name,
                      'price': item.price,
                      'quantity': item.quantity,
                      'addons':
                      item.addOns.map((addon) => addon.name).toList(),
                    })
                        .toList(),
                'deliveryMethod':
                invoiceData['orderType'] ?? order.orderType,
                'deliveryAddress': invoiceData['deliveryAddress'] != null
                    ? DeliveryAddress.fromJson(invoiceData['deliveryAddress'])
                    : order.deliveryAddress,
                'paymentMethod': PaymentMethod(
                  id: '1',
                  type: (invoiceData['paymentMethod'] == 'gcash' ||
                      invoiceData['paymentMethod'] == null)
                      ? PaymentType.gcash
                      : PaymentType.paymaya,
                  title: invoiceData['paymentMethod'] == 'cash'
                      ? 'Cash on Delivery'
                      : (invoiceData['paymentMethod']?.toUpperCase() ?? 'GCASH'),
                  accountName: invoiceData['paymentMethod'] == 'cash'
                      ? 'N/A'
                      : 'Customer',
                  accountNumber: invoiceData['paymentMethod'] == 'cash'
                      ? 'N/A'
                      : '****',
                  isDefault: false,
                ),
                'notes': invoiceData['notes'] ?? order.notes,
              };

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InvoicePage(order: orderData),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message'] ?? 'Failed to fetch invoice'),
                  backgroundColor: colorScheme.primary,
                ),
              );
            }
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.toString()}'),
                backgroundColor: colorScheme.primary,
              ),
            );
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      'Order #$orderId',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusBackgroundColor(order.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(
                        color: getStatusTextColor(order.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                dateFormat.format(order.orderDate),
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery: ${order.orderType}',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Payment: ${order.paymentMethod == 'cash' ? 'Cash on Delivery' : order.paymentMethod.toUpperCase()}',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: Text(
                      currencyFormat.format(order.total),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 