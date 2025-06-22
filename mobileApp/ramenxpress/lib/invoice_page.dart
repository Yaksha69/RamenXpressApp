import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'models/payment_method.dart';
import 'models/delivery_address.dart';
import 'services/websocket_service.dart';
import 'providers/notifications_provider.dart';

class InvoicePage extends StatefulWidget {
  final Map<String, dynamic> order;

  const InvoicePage({Key? key, required this.order}) : super(key: key);

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  late WebSocketService _webSocketService;
  String _currentStatus = '';
  bool _isStatusUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order['status']?.toString() ?? 'Unknown';
    _initializeWebSocket();
  }

  void _initializeWebSocket() {
    _webSocketService = WebSocketService();
    _webSocketService.initialize('');
    
    // Listen for order status updates
    _webSocketService.onOrderStatusUpdated = (statusData) {
      if (mounted && statusData['orderId'].toString() == widget.order['orderId'].toString()) {
        setState(() {
          _currentStatus = statusData['status'];
          _isStatusUpdating = true;
        });
        
        // Show notification
        final notificationsProvider = Provider.of<NotificationsProvider>(context, listen: false);
        notificationsProvider.addNotification(
          NotificationItem(
            id: 'order-${statusData['orderId']}',
            title: 'Order Status Updated',
            message: 'Your order #${statusData['orderId']} status has been updated to ${statusData['status']}',
            timestamp: DateTime.now(),
          ),
        );
        
        // Reset updating flag after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isStatusUpdating = false;
            });
          }
        });
      }
    };
    
    _webSocketService.onConnected = () {
      if (mounted) {
        // WebSocket connected successfully
      }
    };
    
    _webSocketService.onError = (error) {
      if (mounted) {
        // Handle WebSocket errors silently
      }
    };
    
    _webSocketService.connect();
  }

  @override
  void dispose() {
    _webSocketService.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFA726); // Orange
      case 'confirmed':
        return const Color(0xFF42A5F5); // Blue
      case 'preparing':
        return const Color(0xFF7B1FA2); // Purple
      case 'ready':
        return const Color(0xFF66BB6A); // Green
      case 'delivered':
        return const Color(0xFF26A69A); // Teal
      case 'cancelled':
        return const Color(0xFFEF5350); // Red
      default:
        return const Color(0xFF1A1A1A); // Black
    }
  }

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return '⏳';
      case 'confirmed':
        return '✅';
      case 'preparing':
        return '👨‍🍳';
      case 'ready':
        return '🚀';
      case 'delivered':
        return '📦';
      case 'cancelled':
        return '❌';
      default:
        return '📋';
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderId = widget.order['orderId']?.toString() ?? 'N/A';
    final date = widget.order['date'] as DateTime?;
    final total = (widget.order['total'] as num?)?.toDouble() ?? 0.0;
    final items = widget.order['items'] as List<dynamic>? ?? [];
    final deliveryMethod = widget.order['deliveryMethod']?.toString() ?? 'Unknown';
    final deliveryAddress = widget.order['deliveryAddress'] != null 
        ? (widget.order['deliveryAddress'] is DeliveryAddress 
            ? widget.order['deliveryAddress'] as DeliveryAddress
            : DeliveryAddress.fromJson(widget.order['deliveryAddress']))
        : null;
    final paymentMethod = widget.order['paymentMethod'] as PaymentMethod?;
    final notes = widget.order['notes']?.toString() ?? '';

    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Invoice'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        actions: [
          // Real-time status indicator
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share, color: Color(0xFF1A1A1A)),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.print, color: Color(0xFF1A1A1A)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status with Real-time Updates
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(_currentStatus).withAlpha((0.08 * 255).toInt()),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(_currentStatus),
                ),
              ),
              child: Row(
                children: [
                  if (_isStatusUpdating)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD32D43)),
                      ),
                    )
                  else
                    Text(
                      _getStatusIcon(_currentStatus),
                      style: const TextStyle(fontSize: 20),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Order Status',
                              style: TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontSize: 14,
                              ),
                            ),
                            if (_isStatusUpdating) ...[
                              const SizedBox(width: 8),
                              const Text(
                                'Updating...',
                                style: TextStyle(
                                  color: Color(0xFFD32D43),
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentStatus.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(_currentStatus),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Order Status Timeline
            const Text(
              'Order Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusTimeline(),

            const SizedBox(height: 24),

            // Order Details
            const Text(
              'Order Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Order ID', orderId),
            _buildInfoRow('Date', () {
              try {
                return dateFormat.format(date!);
              } catch (e) {
                return 'N/A';
              }
            }()),
            _buildInfoRow('Delivery Method', deliveryMethod),
            if (deliveryMethod == 'delivery' && deliveryAddress != null)
              _buildInfoRow(
                'Delivery Address',
                deliveryAddress.fullAddress,
              ),
            const SizedBox(height: 24),

            // Payment Details
            const Text(
              'Payment Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Payment Method',
              paymentMethod != null ? paymentMethod.displayName : 'N/A',
            ),
            const SizedBox(height: 24),

            // Order Items
            const Text(
              'Order Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...items.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD32D43), width: 1),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] ?? 'Unknown Item',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₱${(item['price'] ?? 0.0).toStringAsFixed(2)} × ${item['quantity'] ?? 0}',
                            style: const TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 14,
                            ),
                          ),
                          if (item['addons'] != null && (item['addons'] as List).isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Add-ons: ${(item['addons'] as List).join(", ")}',
                                style: const TextStyle(
                                  color: Color(0xFFD32D43),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '₱${((item['price'] ?? 0.0) * (item['quantity'] ?? 0)).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 24),

            // Order Summary
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Subtotal', total - (deliveryMethod == 'delivery' ? 50.0 : 0.0)),
            if (deliveryMethod == 'delivery')
              _buildSummaryRow('Delivery Fee', 50.0),
            const Divider(height: 32, color: Color(0xFF1A1A1A)),
            _buildSummaryRow('Total', total, isTotal: true),
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Delivery Notes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD32D43)),
                ),
                child: Text(
                  notes,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/order-history');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32D43),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back to Order History',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isStatusUpdating = true;
          });
          
          // Simulate a refresh (in a real app, you might want to fetch from API)
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              setState(() {
                _isStatusUpdating = false;
              });
            }
          });
        },
        backgroundColor: const Color(0xFFD32D43),
        foregroundColor: Colors.white,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? const Color(0xFF1A1A1A) : const Color(0xFF1A1A1A),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
            ),
          ),
          Text(
            NumberFormat.currency(symbol: '₱', decimalDigits: 2).format(value),
            style: TextStyle(
              color: isTotal ? const Color(0xFF1A1A1A) : const Color(0xFF1A1A1A),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline() {
    final statuses = [
      {'status': 'pending', 'title': 'Order Placed', 'description': 'Your order has been received'},
      {'status': 'confirmed', 'title': 'Order Confirmed', 'description': 'We\'ve confirmed your order'},
      {'status': 'preparing', 'title': 'Preparing', 'description': 'Your food is being prepared'},
      {'status': 'ready', 'title': 'Ready', 'description': 'Your order is ready for pickup/delivery'},
      {'status': 'delivered', 'title': 'Delivered', 'description': 'Order completed successfully'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD32D43), width: 1),
      ),
      child: Column(
        children: statuses.asMap().entries.map((entry) {
          final index = entry.key;
          final status = entry.value;
          final isCompleted = _isStatusCompleted(status['status']!);
          final isCurrent = _currentStatus.toLowerCase() == status['status']!.toLowerCase();
          
          return Row(
            children: [
              // Status indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted 
                      ? const Color(0xFF66BB6A)
                      : isCurrent 
                          ? const Color(0xFFD32D43)
                          : Colors.grey[300],
                ),
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : isCurrent
                        ? const Icon(Icons.radio_button_checked, color: Colors.white, size: 16)
                        : null,
              ),
              
              // Connecting line
              if (index < statuses.length - 1)
                Container(
                  width: 2,
                  height: 40,
                  color: isCompleted ? const Color(0xFF66BB6A) : Colors.grey[300],
                  margin: const EdgeInsets.symmetric(horizontal: 11),
                ),
              
              const SizedBox(width: 16),
              
              // Status content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status['title']!,
                      style: TextStyle(
                        fontWeight: isCompleted || isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCompleted 
                            ? const Color(0xFF66BB6A)
                            : isCurrent 
                                ? const Color(0xFFD32D43)
                                : const Color(0xFF1A1A1A),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status['description']!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD32D43).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Current Status',
                          style: TextStyle(
                            color: Color(0xFFD32D43),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  bool _isStatusCompleted(String status) {
    final statusOrder = ['pending', 'confirmed', 'preparing', 'ready', 'delivered'];
    final currentIndex = statusOrder.indexOf(_currentStatus.toLowerCase());
    final statusIndex = statusOrder.indexOf(status.toLowerCase());
    
    if (currentIndex == -1 || statusIndex == -1) return false;
    return statusIndex < currentIndex;
  }
} 