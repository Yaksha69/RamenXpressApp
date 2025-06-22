const Sales = require('../models/Sales');
const Customer = require('../models/Customer');
const { getIO } = require('../websocket');

// Get all orders with filtering (for cashiers/admins)
const getAllOrders = async (req, res) => {
  try {
    const { 
      startDate, 
      endDate, 
      status, 
      paymentMethod, 
      page = 1, 
      limit = 10 
    } = req.query;

    // Build filter object
    const filter = {};

    // Date range filter
    if (startDate && endDate) {
      filter.orderDate = {
        $gte: new Date(startDate),
        $lte: new Date(endDate + 'T23:59:59.999Z')
      };
    } else if (startDate) {
      filter.orderDate = { $gte: new Date(startDate) };
    } else if (endDate) {
      filter.orderDate = { $lte: new Date(endDate + 'T23:59:59.999Z') };
    }

    // Status filter
    if (status && status !== 'all') {
      filter.status = status;
    }

    // Payment method filter
    if (paymentMethod && paymentMethod !== 'all') {
      filter.paymentMethod = paymentMethod;
    }

    // Calculate pagination
    const skip = (parseInt(page) - 1) * parseInt(limit);

    // Get orders with customer information
    const orders = await Sales.find(filter)
      .populate('customerId', 'firstName lastName email phoneNumber')
      .sort({ orderDate: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    // Get total count for pagination
    const totalOrders = await Sales.countDocuments(filter);

    // Calculate total pages
    const totalPages = Math.ceil(totalOrders / parseInt(limit));

    res.status(200).json({
      success: true,
      orders,
      pagination: {
        currentPage: parseInt(page),
        totalPages,
        totalOrders,
        hasNextPage: parseInt(page) < totalPages,
        hasPrevPage: parseInt(page) > 1
      }
    });
  } catch (error) {
    console.error('Error getting all orders:', error);
    res.status(500).json({ 
      success: false,
      message: 'Server error', 
      error: error.message 
    });
  }
};

// Get order details by ID (for cashiers/admins)
const getOrderDetails = async (req, res) => {
  try {
    const { orderId } = req.params;

    const order = await Sales.findOne({ orderId: parseInt(orderId) })
      .populate('customerId', 'firstName lastName email phoneNumber');

    if (!order) {
      return res.status(404).json({ 
        success: false,
        message: 'Order not found' 
      });
    }

    res.status(200).json({
      success: true,
      order
    });
  } catch (error) {
    console.error('Error getting order details:', error);
    res.status(500).json({ 
      success: false,
      message: 'Server error', 
      error: error.message 
    });
  }
};

// Update order status (for cashiers/admins)
const updateOrderStatus = async (req, res) => {
  try {
    const { orderId } = req.params;
    const { status } = req.body;

    if (!status || !['pending', 'confirmed', 'preparing', 'ready', 'delivered', 'cancelled'].includes(status)) {
      return res.status(400).json({ 
        success: false,
        message: 'Invalid status. Must be one of: pending, confirmed, preparing, ready, delivered, cancelled' 
      });
    }

    const order = await Sales.findOne({ orderId: parseInt(orderId) })
      .populate('customerId', 'firstName lastName email phoneNumber');

    if (!order) {
      return res.status(404).json({ 
        success: false,
        message: 'Order not found' 
      });
    }

    // Update the order status
    order.status = status;
    await order.save();

    // Emit WebSocket event for real-time updates
    getIO().emit('orderStatusUpdated', { 
      orderId: parseInt(orderId), 
      status,
      order 
    });

    res.status(200).json({
      success: true,
      message: 'Order status updated successfully',
      order
    });
  } catch (error) {
    console.error('Error updating order status:', error);
    res.status(500).json({ 
      success: false,
      message: 'Server error', 
      error: error.message 
    });
  }
};

// Update payment status (for cashiers/admins)
const updatePaymentStatus = async (req, res) => {
  try {
    const { orderId } = req.params;
    const { paymentStatus } = req.body;

    if (!paymentStatus || !['Paid', 'Pending', 'Refunded', 'Failed'].includes(paymentStatus)) {
      return res.status(400).json({ 
        success: false,
        message: 'Invalid payment status. Must be one of: Paid, Pending, Refunded, Failed' 
      });
    }

    const order = await Sales.findOne({ orderId: parseInt(orderId) })
      .populate('customerId', 'firstName lastName email phoneNumber');

    if (!order) {
      return res.status(404).json({ 
        success: false,
        message: 'Order not found' 
      });
    }

    // Update the payment status
    order.paymentStatus = paymentStatus;
    await order.save();

    // Emit WebSocket event for real-time updates
    getIO().emit('paymentStatusUpdated', { 
      orderId: parseInt(orderId), 
      paymentStatus,
      order 
    });

    res.status(200).json({
      success: true,
      message: 'Payment status updated successfully',
      order
    });
  } catch (error) {
    console.error('Error updating payment status:', error);
    res.status(500).json({ 
      success: false,
      message: 'Server error', 
      error: error.message 
    });
  }
};

// Cancel order (for cashiers/admins)
const cancelOrder = async (req, res) => {
  try {
    const { orderId } = req.params;
    const { reason } = req.body;

    const order = await Sales.findOne({ orderId: parseInt(orderId) })
      .populate('customerId', 'firstName lastName email phoneNumber');

    if (!order) {
      return res.status(404).json({ 
        success: false,
        message: 'Order not found' 
      });
    }

    // Check if order can be cancelled
    if (order.status === 'delivered' || order.status === 'cancelled') {
      return res.status(400).json({ 
        success: false,
        message: 'Order cannot be cancelled. Current status: ' + order.status 
      });
    }

    // Update the order status to cancelled
    order.status = 'cancelled';
    order.cancellationReason = reason || 'Cancelled by cashier';
    order.cancelledAt = new Date();
    await order.save();

    // Emit WebSocket event for real-time updates
    getIO().emit('orderCancelled', { 
      orderId: parseInt(orderId), 
      reason: order.cancellationReason,
      order 
    });

    res.status(200).json({
      success: true,
      message: 'Order cancelled successfully',
      order
    });
  } catch (error) {
    console.error('Error cancelling order:', error);
    res.status(500).json({ 
      success: false,
      message: 'Server error', 
      error: error.message 
    });
  }
};

// Get order statistics (for dashboard)
const getOrderStatistics = async (req, res) => {
  try {
    const { startDate, endDate } = req.query;

    // Build date filter
    const dateFilter = {};
    if (startDate && endDate) {
      dateFilter.orderDate = {
        $gte: new Date(startDate),
        $lte: new Date(endDate + 'T23:59:59.999Z')
      };
    } else if (startDate) {
      dateFilter.orderDate = { $gte: new Date(startDate) };
    } else if (endDate) {
      dateFilter.orderDate = { $lte: new Date(endDate + 'T23:59:59.999Z') };
    }

    // Get total orders
    const totalOrders = await Sales.countDocuments(dateFilter);

    // Get orders by status
    const statusStats = await Sales.aggregate([
      { $match: dateFilter },
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 }
        }
      }
    ]);

    // Get orders by payment method
    const paymentStats = await Sales.aggregate([
      { $match: dateFilter },
      {
        $group: {
          _id: '$paymentMethod',
          count: { $sum: 1 }
        }
      }
    ]);

    // Get total revenue
    const revenueStats = await Sales.aggregate([
      { $match: dateFilter },
      {
        $group: {
          _id: null,
          totalRevenue: { $sum: '$total' },
          averageOrderValue: { $avg: '$total' }
        }
      }
    ]);

    // Format statistics
    const statistics = {
      totalOrders,
      statusBreakdown: statusStats.reduce((acc, stat) => {
        acc[stat._id] = stat.count;
        return acc;
      }, {}),
      paymentBreakdown: paymentStats.reduce((acc, stat) => {
        acc[stat._id] = stat.count;
        return acc;
      }, {}),
      revenue: revenueStats[0] || { totalRevenue: 0, averageOrderValue: 0 }
    };

    res.status(200).json({
      success: true,
      statistics
    });
  } catch (error) {
    console.error('Error getting order statistics:', error);
    res.status(500).json({ 
      success: false,
      message: 'Server error', 
      error: error.message 
    });
  }
};

module.exports = {
  getAllOrders,
  getOrderDetails,
  updateOrderStatus,
  updatePaymentStatus,
  cancelOrder,
  getOrderStatistics
}; 