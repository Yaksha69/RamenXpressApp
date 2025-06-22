const express = require('express');
const router = express.Router();
const { 
  getAllOrders, 
  getOrderDetails, 
  updateOrderStatus, 
  updatePaymentStatus, 
  cancelOrder,
  getOrderStatistics
} = require('../controllers/MobileOrderController');
const { verifyToken, isCashier } = require('../middleware/AuthMiddleware');

// Mobile order management routes (require cashier authentication)
router.get('/orders', verifyToken, isCashier, getAllOrders);
router.get('/orders/:orderId', verifyToken, isCashier, getOrderDetails);
router.put('/orders/:orderId/status', verifyToken, isCashier, updateOrderStatus);
router.put('/orders/:orderId/payment-status', verifyToken, isCashier, updatePaymentStatus);
router.put('/orders/:orderId/cancel', verifyToken, isCashier, cancelOrder);
router.get('/statistics', verifyToken, isCashier, getOrderStatistics);

module.exports = router; 