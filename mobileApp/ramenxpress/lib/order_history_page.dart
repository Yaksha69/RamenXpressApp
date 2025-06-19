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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFD32D43); // Red
      case 'preparing':
        return const Color(0xFF1A1A1A); // Black
      case 'ready':
        return const Color(0xFFD32D43); // Red
      case 'delivered':
        return const Color(0xFF1A1A1A); // Black
      case 'cancelled':
        return const Color(0xFFD32D43); // Red
      default:
        return const Color(0xFF1A1A1A); // Black
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderHistoryProvider>().orders;
    final currencyFormat = NumberFormat.currency(symbol: '₱');
    final dateFormat = DateFormat('MMM d, yyyy h:mm a');

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: CustomScrollView(
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
                        'Order History',
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
                          const Text(
                            'No orders yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your order history will appear here',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1A1A1A),
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
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                          ...orders.map((order) {
                            // Format order ID to be 5 digits
                            final orderId = (order.orderId ?? 0).toString().padLeft(4, '0');
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 8,
                              ),
                              child: InkWell(
                                onTap: () async {
                                  print('🔍 DEBUG: Starting invoice fetch for order ${order.orderId}');
                                  try {
                                    // Get token
                                    final token = await ApiService.getToken();
                                    if (token == null) {
                                      print('❌ DEBUG: No authentication token found');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Authentication token not found'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }
                                    print('✅ DEBUG: Token obtained successfully');

                                    // Fetch invoice data from backend
                                    print('🔍 DEBUG: Calling OrderService.getOrderInvoice with orderId: ${order.orderId}');
                                    final result = await OrderService.getOrderInvoice(
                                      orderId: order.orderId,
                                      token: token,
                                    );
                                    print('🔍 DEBUG: OrderService result: $result');

                                    if (result['success']) {
                                      final invoiceData = result['data'];
                                      print('🔍 DEBUG: Invoice data received: $invoiceData');
                                      print('🔍 DEBUG: orderId from API: ${invoiceData['orderId']}');
                                      print('🔍 DEBUG: orderDate from API: ${invoiceData['orderDate']}');
                                      print('🔍 DEBUG: status from API: ${invoiceData['status']}');
                                      print('🔍 DEBUG: paymentMethod from API: ${invoiceData['paymentMethod']}');
                                      
                                      // Navigate to invoice page with backend data
                                      final orderData = {
                                        'orderId': invoiceData['orderId'] ?? orderId,
                                        'date': invoiceData['orderDate'] != null 
                                            ? DateTime.parse(invoiceData['orderDate'])
                                            : order.orderDate,
                                        'status': invoiceData['status'] ?? order.status,
                                        'total': (invoiceData['total'] ?? order.total).toDouble(),
                                        'items': (invoiceData['items'] as List?)?.map<Map<String, dynamic>>((item) => {
                                          'name': item['name'] ?? 'Unknown Item',
                                          'price': (item['price'] ?? 0.0).toDouble(),
                                          'quantity': item['quantity'] ?? 0,
                                          'addons': item['addOns']?.map((addon) => addon['name']).toList() ?? [],
                                        }).toList() ?? order.items.map((item) => {
                                          'name': item.name,
                                          'price': item.price,
                                          'quantity': item.quantity,
                                          'addons': item.addOns.map((addon) => addon.name).toList(),
                                        }).toList(),
                                        'deliveryMethod': invoiceData['orderType'] ?? order.orderType,
                                        'deliveryAddress': invoiceData['deliveryAddress'] != null 
                                            ? DeliveryAddress.fromJson(invoiceData['deliveryAddress'])
                                            : order.deliveryAddress,
                                        'paymentMethod': PaymentMethod(
                                          id: '1',
                                          type: (invoiceData['paymentMethod'] == 'gcash' || invoiceData['paymentMethod'] == null)
                                              ? PaymentType.gcash 
                                              : PaymentType.paymaya,
                                          title: invoiceData['paymentMethod'] == 'cash' 
                                              ? 'Cash on Delivery' 
                                              : (invoiceData['paymentMethod']?.toUpperCase() ?? 'GCASH'),
                                          accountName: invoiceData['paymentMethod'] == 'cash' ? 'N/A' : 'Customer',
                                          accountNumber: invoiceData['paymentMethod'] == 'cash' ? 'N/A' : '****',
                                          isDefault: false,
                                        ),
                                        'notes': invoiceData['notes'] ?? order.notes,
                                      };
                                      
                                      print('🔍 DEBUG: Final order data for invoice: $orderData');
                                      print('🔍 DEBUG: Navigating to InvoicePage...');
                                      
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => InvoicePage(order: orderData),
                                        ),
                                      );
                                    } else {
                                      print('❌ DEBUG: API call failed: ${result['message']}');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(result['message'] ?? 'Failed to fetch invoice'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } catch (e, stackTrace) {
                                    print('❌ DEBUG: Exception occurred: $e');
                                    print('❌ DEBUG: Stack trace: $stackTrace');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: ${e.toString()}'),
                                        backgroundColor: Colors.red,
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
                                              'Order #${orderId ?? 'N/A'}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Color(0xFF1A1A1A),
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
                                              color: _getStatusColor(order.status).withAlpha((0.08 * 255).toInt()),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              order.status,
                                              style: TextStyle(
                                                color: _getStatusColor(order.status),
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
                                          color: Color(0xFF1A1A1A),
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
                                                    color: Color(0xFF1A1A1A),
                                                    fontSize: 12,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Payment: ${order.paymentMethod == 'cash' ? 'Cash on Delivery' : order.paymentMethod.toUpperCase()}',
                                                  style: TextStyle(
                                                    color: Color(0xFF1A1A1A),
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
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Color(0xFF1A1A1A),
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
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
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
} 