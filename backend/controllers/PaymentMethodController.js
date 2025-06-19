const PaymentMethod = require('../models/PaymentMethod');

// Get all payment methods for the authenticated customer
const getCustomerPaymentMethods = async (req, res) => {
  try {
    const customerId = req.customerId;
    
    const paymentMethods = await PaymentMethod.find({ 
      customerId, 
      isActive: true 
    }).sort({ isDefault: -1, createdAt: -1 });

    const formattedPaymentMethods = paymentMethods.map(pm => pm.getPublicProfile());

    res.status(200).json({
      success: true,
      data: formattedPaymentMethods
    });
  } catch (error) {
    console.error('Error getting customer payment methods:', error);
    res.status(500).json({ 
      success: false,
      message: 'Server error', 
      error: error.message 
    });
  }
};

// Get a specific payment method by ID
const getPaymentMethodById = async (req, res) => {
  try {
    const { paymentMethodId } = req.params;
    const customerId = req.customerId;

    const paymentMethod = await PaymentMethod.findOne({ 
      _id: paymentMethodId, 
      customerId, 
      isActive: true 
    });

    if (!paymentMethod) {
      return res.status(404).json({ 
        success: false,
        message: 'Payment method not found' 
      });
    }

    res.status(200).json({
      success: true,
      data: paymentMethod.getPublicProfile()
    });
  } catch (error) {
    console.error('Error getting payment method:', error);
    res.status(500).json({ 
      success: false,
      message: 'Server error', 
      error: error.message 
    });
  }
};

// Create a new payment method
const createPaymentMethod = async (req, res) => {
  try {
    const customerId = req.customerId;
    const {
      type,
      title,
      accountNumber,
      accountName,
      isDefault = false
    } = req.body;

    // Validate required fields
    if (!type || !title || !accountNumber || !accountName) {
      return res.status(400).json({
        success: false,
        message: 'Type, title, account number, and account name are required'
      });
    }

    // Validate type enum
    const validTypes = ['gcash', 'paymaya'];
    if (!validTypes.includes(type)) {
      return res.status(400).json({
        success: false,
        message: 'Type must be one of: gcash, paymaya'
      });
    }

    const paymentMethod = new PaymentMethod({
      customerId,
      type,
      title,
      accountNumber,
      accountName,
      isDefault
    });

    await paymentMethod.save();

    res.status(201).json({
      success: true,
      message: 'Payment method created successfully',
      data: paymentMethod.getPublicProfile()
    });
  } catch (error) {
    console.error('Error creating payment method:', error);
    res.status(500).json({ 
      success: false,
      message: 'Server error', 
      error: error.message 
    });
  }
};

// Update a payment method
const updatePaymentMethod = async (req, res) => {
  try {
    const { paymentMethodId } = req.params;
    const customerId = req.customerId;
    const {
      type,
      title,
      accountNumber,
      accountName,
      isDefault
    } = req.body;

    const paymentMethod = await PaymentMethod.findOne({ 
      _id: paymentMethodId, 
      customerId, 
      isActive: true 
    });

    if (!paymentMethod) {
      return res.status(404).json({ 
        success: false,
        message: 'Payment method not found' 
      });
    }

    // Update fields if provided
    if (type) {
      const validTypes = ['gcash', 'paymaya'];
      if (!validTypes.includes(type)) {
        return res.status(400).json({
          success: false,
          message: 'Type must be one of: gcash, paymaya'
        });
      }
      paymentMethod.type = type;
    }
    if (title) paymentMethod.title = title;
    if (accountNumber) paymentMethod.accountNumber = accountNumber;
    if (accountName) paymentMethod.accountName = accountName;
    if (isDefault !== undefined) paymentMethod.isDefault = isDefault;

    await paymentMethod.save();

    res.status(200).json({
      success: true,
      message: 'Payment method updated successfully',
      data: paymentMethod.getPublicProfile()
    });
  } catch (error) {
    console.error('Error updating payment method:', error);
    res.status(500).json({ 
      success: false,
      message: 'Server error', 
      error: error.message 
    });
  }
};

// Delete a payment method (soft delete)
const deletePaymentMethod = async (req, res) => {
  try {
    const { paymentMethodId } = req.params;
    const customerId = req.customerId;

    const paymentMethod = await PaymentMethod.findOne({ 
      _id: paymentMethodId, 
      customerId, 
      isActive: true 
    });

    if (!paymentMethod) {
      return res.status(404).json({ 
        success: false,
        message: 'Payment method not found' 
      });
    }

    // Soft delete by setting isActive to false
    paymentMethod.isActive = false;
    await paymentMethod.save();

    res.status(200).json({
      success: true,
      message: 'Payment method deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting payment method:', error);
    res.status(500).json({ 
      success: false,
      message: 'Server error', 
      error: error.message 
    });
  }
};

// Set default payment method
const setDefaultPaymentMethod = async (req, res) => {
  try {
    const { paymentMethodId } = req.params;
    const customerId = req.customerId;

    const paymentMethod = await PaymentMethod.findOne({ 
      _id: paymentMethodId, 
      customerId, 
      isActive: true 
    });

    if (!paymentMethod) {
      return res.status(404).json({ 
        success: false,
        message: 'Payment method not found' 
      });
    }

    // Set this payment method as default (the pre-save hook will handle the rest)
    paymentMethod.isDefault = true;
    await paymentMethod.save();

    res.status(200).json({
      success: true,
      message: 'Default payment method set successfully',
      data: paymentMethod.getPublicProfile()
    });
  } catch (error) {
    console.error('Error setting default payment method:', error);
    res.status(500).json({ 
      success: false,
      message: 'Server error', 
      error: error.message 
    });
  }
};

module.exports = {
  getCustomerPaymentMethods,
  getPaymentMethodById,
  createPaymentMethod,
  updatePaymentMethod,
  deletePaymentMethod,
  setDefaultPaymentMethod
}; 