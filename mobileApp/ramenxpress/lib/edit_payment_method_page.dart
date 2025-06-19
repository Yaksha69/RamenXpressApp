import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/payment_methods_provider.dart';
import 'models/payment_method.dart';

class EditPaymentMethodPage extends StatefulWidget {
  final PaymentMethod? paymentMethod;

  const EditPaymentMethodPage({super.key, this.paymentMethod});

  @override
  State<EditPaymentMethodPage> createState() => _EditPaymentMethodPageState();
}

class _EditPaymentMethodPageState extends State<EditPaymentMethodPage> {
  final _formKey = GlobalKey<FormState>();
  PaymentType _selectedType = PaymentType.gcash;
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.paymentMethod != null) {
      _selectedType = widget.paymentMethod!.type;
      _nameController.text = widget.paymentMethod!.accountName;
      _phoneNumberController.text = widget.paymentMethod!.accountNumber;
      _isDefault = widget.paymentMethod!.isDefault;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void _savePaymentMethod() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final provider = context.read<PaymentMethodsProvider>();
      bool success = false;
      
      // Generate title based on payment type
      final title = _selectedType == PaymentType.gcash ? 'My GCash' : 'My PayMaya';
      
      if (widget.paymentMethod != null) {
        success = await provider.updatePaymentMethod(
          paymentMethodId: widget.paymentMethod!.id,
          type: _selectedType,
          title: title,
          accountName: _nameController.text,
          accountNumber: _phoneNumberController.text,
          isDefault: _isDefault,
        );
      } else {
        success = await provider.createPaymentMethod(
          type: _selectedType,
          title: title,
          accountName: _nameController.text,
          accountNumber: _phoneNumberController.text,
          isDefault: _isDefault,
        );
      }

      setState(() {
        _isLoading = false;
      });

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.paymentMethod == null
                  ? 'Payment method added successfully'
                  : 'Payment method updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to save payment method'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.paymentMethod == null ? 'Add Payment Method' : 'Edit Payment Method'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Payment Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<PaymentType>(
                segments: const [
                  ButtonSegment<PaymentType>(
                    value: PaymentType.gcash,
                    label: Text('GCash'),
                    icon: Icon(Icons.account_balance_wallet),
                  ),
                  ButtonSegment<PaymentType>(
                    value: PaymentType.paymaya,
                    label: Text('PayMaya'),
                    icon: Icon(Icons.account_balance),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<PaymentType> selected) {
                  setState(() {
                    _selectedType = selected.first;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors.deepOrange.withAlpha((0.08 * 255).toInt());
                      }
                      return Colors.grey[50]!;
                    },
                  ),
                  foregroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors.deepOrange;
                      }
                      return Colors.grey;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (!RegExp(r'^\d{11}$').hasMatch(value)) {
                    return 'Please enter a valid 11-digit phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: const Text('Set as default payment method'),
                value: _isDefault,
                onChanged: (value) {
                  setState(() {
                    _isDefault = value;
                  });
                },
                activeColor: Colors.deepOrange,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePaymentMethod,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          widget.paymentMethod == null ? 'Add Payment Method' : 'Save Changes',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 