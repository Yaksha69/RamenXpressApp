const express = require('express');
const router = express.Router();
const OrderController = require('../controllers/OrderController');
const { verifyToken, isAdmin, isCashier } = require('../middleware/AuthMiddleware');

// Public routes (no authentication required)
router.post('/', OrderController.createOrder);

// Protected routes (require authentication)
router.get('/', verifyToken, isCashier, OrderController.getAllOrders);
router.get('/:id', verifyToken, isCashier, OrderController.getOrderById);
router.patch('/:id/status', verifyToken, isCashier, OrderController.updateOrderStatus);
router.patch('/:id/payment-status', verifyToken, isCashier, OrderController.updatePaymentStatus);
router.patch('/:id/cancel', verifyToken, isCashier, OrderController.cancelOrder);

module.exports = router; 