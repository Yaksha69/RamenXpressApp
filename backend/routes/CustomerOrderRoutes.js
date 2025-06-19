const express = require('express');
const router = express.Router();
const { 
  placeCustomerOrder, 
  getCustomerOrders, 
  getOrderById, 
  updateOrderStatus, 
  getOrderInvoice 
} = require('../controllers/CustomerOrderController');
const { verifyCustomerToken } = require('../middleware/AuthMiddleware');

// Customer order routes (require customer authentication)
router.post('/place-order', verifyCustomerToken, placeCustomerOrder);
router.get('/orders', verifyCustomerToken, getCustomerOrders);
router.get('/order/:orderId', verifyCustomerToken, getOrderById);
router.put('/order/:orderId/status', verifyCustomerToken, updateOrderStatus);
router.get('/invoice/:orderId', verifyCustomerToken, getOrderInvoice);

module.exports = router; 