import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/payment_method.dart';
import 'models/delivery_address.dart';

class InvoicePage extends StatefulWidget {
  final Map<String, dynamic> order;

  const InvoicePage({Key? key, required this.order}) : super(key: key);

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  @override
  void initState() {
    super.initState();
    print('🔍 DEBUG: InvoicePage initialized with order data: ${widget.order}');
    print('🔍 DEBUG: orderId: ${widget.order['orderId']}');
    print('🔍 DEBUG: date: ${widget.order['date']}');
    print('🔍 DEBUG: status: ${widget.order['status']}');
    print('🔍 DEBUG: total: ${widget.order['total']}');
    print('🔍 DEBUG: items: ${widget.order['items']}');
    print('🔍 DEBUG: paymentMethod: ${widget.order['paymentMethod']}');
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
    print('🔍 DEBUG: InvoicePage build method called');
    print('🔍 DEBUG: Current order data in build: ${widget.order}');
    
    final orderId = widget.order['orderId']?.toString() ?? 'N/A';
    final date = widget.order['date'] as DateTime?;
    final status = widget.order['status']?.toString() ?? 'Unknown';
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
    
    print('🔍 DEBUG: Parsed values - orderId: $orderId, date: $date, status: $status, total: $total');
    print('🔍 DEBUG: Items count: ${items.length}');
    print('🔍 DEBUG: Payment method: $paymentMethod');

    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Invoice'),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        actions: [
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
            // Order Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withAlpha((0.08 * 255).toInt()),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(status),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: _getStatusColor(status),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Status',
                          style: TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          status,
                          style: TextStyle(
                            color: _getStatusColor(status),
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
                  border: Border.all(color: Color(0xFFD32D43), width: 1),
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
                            style: TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 14,
                            ),
                          ),
                          if (item['addons'] != null && (item['addons'] as List).isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Add-ons: ${(item['addons'] as List).join(", ")}',
                                style: TextStyle(
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
                  border: Border.all(color: Color(0xFFD32D43)),
                ),
                child: Text(
                  notes,
                  style: TextStyle(
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
                  backgroundColor: Color(0xFFD32D43),
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
              style: TextStyle(
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
              color: isTotal ? Color(0xFF1A1A1A) : Color(0xFF1A1A1A),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
            ),
          ),
          Text(
            NumberFormat.currency(symbol: '₱', decimalDigits: 2).format(value),
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
} 