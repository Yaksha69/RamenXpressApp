const express = require('express');
const router = express.Router();
const { 
  getCustomerPaymentMethods,
  getPaymentMethodById,
  createPaymentMethod,
  updatePaymentMethod,
  deletePaymentMethod,
  setDefaultPaymentMethod
} = require('../controllers/PaymentMethodController');
const { verifyCustomerToken } = require('../middleware/AuthMiddleware');

// Apply customer authentication middleware to all routes
router.use(verifyCustomerToken);

// Get all payment methods for the authenticated customer
router.get('/', getCustomerPaymentMethods);

// Create new payment method
router.post('/', createPaymentMethod);

// Get single payment method
router.get('/:paymentMethodId', getPaymentMethodById);

// Update payment method
router.put('/:paymentMethodId', updatePaymentMethod);

// Delete payment method (soft delete)
router.delete('/:paymentMethodId', deletePaymentMethod);

// Set default payment method
router.patch('/:paymentMethodId/default', setDefaultPaymentMethod);

module.exports = router; 