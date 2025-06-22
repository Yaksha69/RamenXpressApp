const Menu = require('../models/Menu');
const Inventory = require('../models/Inventory');
const Sales = require('../models/Sales');
const Customer = require('../models/Customer');
const { getIO } = require('../websocket');

// Place a customer order from mobile app
const placeCustomerOrder = async (req, res) => {
  try {
    console.log('🔍 DEBUG: placeCustomerOrder called');
    console.log('🔍 DEBUG: req.body:', req.body);
    console.log('🔍 DEBUG: req.customerId:', req.customerId);
    
    const { 
      items, 
      orderType, 
      paymentMethod, 
      deliveryAddress, 
      notes
    } = req.body;

    // Get customer ID from authenticated customer
    const customerId = req.customerId;

    console.log('🔍 DEBUG: Parsed data:', {
      items,
      orderType,
      paymentMethod,
      deliveryAddress,
      notes,
      customerId
    });

    // Validate order type
    if (!orderType || !['takeout', 'dine-in', 'delivery'].includes(orderType)) {
      return res.status(400).json({ 
        message: 'Invalid order type. Must be either "takeout", "dine-in", or "delivery"' 
      });
    }

    // Validate payment method
    if (!paymentMethod || !['gcash', 'paymaya', 'cash'].includes(paymentMethod)) {
      return res.status(400).json({ 
        message: 'Invalid payment method. Must be either "gcash", "paymaya", or "cash"' 
      });
    }

    // Validate delivery address for delivery orders
    if (orderType === 'delivery' && !deliveryAddress) {
      return res.status(400).json({ 
        message: 'Delivery address is required for delivery orders' 
      });
    }

    if (!items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ message: 'Invalid order items' });
    }

    console.log('🔍 DEBUG: About to get next order ID');
    // Get next order ID
    const orderId = await Sales.getNextOrderId();
    console.log('🔍 DEBUG: Got order ID:', orderId);
    
    const orderItems = [];
    let totalAmount = 0;

    // Process each item in the order
    for (const item of items) {
      console.log('🔍 DEBUG: Processing item:', item);
      const { menuId, quantity = 1, addOns = [] } = item;
      const menuItem = await Menu.findById(menuId);
      
      console.log('🔍 DEBUG: Found menu item:', menuItem);
      
      if (!menuItem) {
        return res.status(404).json({ message: `Menu item not found: ${menuId}` });
      }

      // Check inventory for all ingredients
      const ingredientNames = menuItem.ingredients.map(i => i.inventoryItem);
      const inventoryItems = await Inventory.find({ name: { $in: ingredientNames } });
      const inventoryMap = {};
      inventoryItems.forEach(item => {
        inventoryMap[item.name] = item;
      });

      // Verify stock for all ingredients
      for (const ingredient of menuItem.ingredients) {
        const inventoryItem = inventoryMap[ingredient.inventoryItem];
        if (!inventoryItem) {
          return res.status(404).json({ 
            message: `Inventory item not found: ${ingredient.inventoryItem}` 
          });
        }
        if (inventoryItem.stocks < (ingredient.quantity * quantity)) {
          return res.status(400).json({ 
            message: `Not enough stock for ${inventoryItem.name}` 
          });
        }
      }

      // Deduct inventory
      for (const ingredient of menuItem.ingredients) {
        const inventoryItem = inventoryMap[ingredient.inventoryItem];
        inventoryItem.stocks -= (ingredient.quantity * quantity);
        await inventoryItem.save();
      }

      // Calculate add-ons total
      const addOnsTotal = addOns.reduce((sum, addon) => sum + addon.price, 0);
      
      // Calculate item total (base price + add-ons) * quantity
      const itemTotal = (menuItem.price + addOnsTotal) * quantity;
      totalAmount += itemTotal;

      // Add to order items
      orderItems.push({
        name: menuItem.name,
        price: menuItem.price,
        quantity,
        total: itemTotal,
        addOns: addOns
      });
    }

    console.log('🔍 DEBUG: Processed all items, total amount:', totalAmount);

    // Calculate delivery fee
    const deliveryFee = orderType === 'delivery' ? 50.0 : 0.0;
    totalAmount += deliveryFee;

    console.log('🔍 DEBUG: About to create sales record');
    // Create sales record
    const sale = new Sales({
      orderId,
      customerId,
      items: orderItems,
      total: totalAmount,
      orderType,
      paymentMethod,
      deliveryAddress: orderType === 'delivery' ? deliveryAddress : null,
      deliveryFee,
      status: 'pending',
      notes: notes || '',
      orderDate: new Date()
    });

    console.log('🔍 DEBUG: About to save sale');
    await sale.save();
    console.log('🔍 DEBUG: Sale saved successfully');

    getIO().emit('orderPlaced', {
      orderId,
      items: orderItems,
      total: totalAmount,
      orderType,
      paymentMethod,
      deliveryAddress: orderType === 'delivery' ? deliveryAddress : null,
      deliveryFee,
      status: 'pending',
      notes: notes || '',
      orderDate: sale.orderDate
    });

    const responseData = {
      message: 'Order placed successfully',
      orderDetails: {
        orderId,
        items: orderItems,
        total: totalAmount,
        orderType,
        paymentMethod,
        deliveryAddress: orderType === 'delivery' ? deliveryAddress : null,
        deliveryFee,
        status: 'pending',
        notes: notes || '',
        orderDate: sale.orderDate
      }
    };

    console.log('🔍 DEBUG: Sending response to client:', JSON.stringify(responseData, null, 2));
    res.status(200).json(responseData);
    console.log('🔍 DEBUG: Response sent successfully');

  } catch (error) {
    console.error('❌ ERROR placing customer order:', error);
    console.error('❌ ERROR stack:', error.stack);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// Get customer orders
const getCustomerOrders = async (req, res) => {
  try {
    // Get customer ID from route parameter or JWT token
    const customerId = req.params.customerId || req.customerId;
    
    if (!customerId) {
      return res.status(400).json({ message: 'Customer ID is required' });
    }

    // Security check: ensure the authenticated customer can only access their own orders
    if (req.customerId && req.customerId.toString() !== customerId) {
      return res.status(403).json({ message: 'Access denied' });
    }

    const orders = await Sales.find({ customerId })
      .sort({ orderDate: -1 })
      .populate('customerId', 'firstName lastName email phoneNumber');

    res.status(200).json({ orders });
  } catch (error) {
    console.error('Error getting customer orders:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// Get order by ID
const getOrderById = async (req, res) => {
  try {
    const { orderId } = req.params;
    const customerId = req.customerId;
    
    const order = await Sales.findOne({ orderId: parseInt(orderId) })
      .populate('customerId', 'firstName lastName email phoneNumber');

    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    // Security check: ensure the authenticated customer can only access their own orders
    if (customerId && order.customerId._id.toString() !== customerId.toString()) {
      return res.status(403).json({ message: 'Access denied' });
    }

    res.status(200).json(order);
  } catch (error) {
    console.error('Error getting order:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// Update order status
const updateOrderStatus = async (req, res) => {
  try {
    const { orderId } = req.params;
    const { status } = req.body;
    const customerId = req.customerId;

    if (!status || !['pending', 'confirmed', 'preparing', 'ready', 'delivered', 'cancelled'].includes(status)) {
      return res.status(400).json({ 
        message: 'Invalid status. Must be one of: pending, confirmed, preparing, ready, delivered, cancelled' 
      });
    }

    const order = await Sales.findOne({ orderId: parseInt(orderId) })
      .populate('customerId', 'firstName lastName email phoneNumber');

    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    // Security check: ensure the authenticated customer can only update their own orders
    if (customerId && order.customerId._id.toString() !== customerId.toString()) {
      return res.status(403).json({ message: 'Access denied' });
    }

    // Update the order status
    order.status = status;
    await order.save();

    getIO().emit('orderStatusUpdated', { orderId, status });

    res.status(200).json({
      message: 'Order status updated successfully',
      order
    });
  } catch (error) {
    console.error('Error updating order status:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// Get invoice for a specific order (for the authenticated customer)
const getOrderInvoice = async (req, res) => {
  try {
    const { orderId } = req.params;
    const customerId = req.customerId;
    
    if (!orderId) {
      return res.status(400).json({
        success: false,
        message: 'Order ID is required'
      });
    }

    // Find the order and populate customer data only
    const order = await Sales.findOne({
      orderId: parseInt(orderId),
      customerId: customerId
    }).populate('customerId', 'firstName lastName email phoneNumber');
    
    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    // Format the order data for the invoice
    const invoiceData = {
      orderId: order.orderId,
      orderDate: order.orderDate,
      status: order.status,
      total: order.total,
      orderType: order.orderType,
      deliveryAddress: order.deliveryAddress,
      paymentMethod: order.paymentMethod,
      notes: order.notes,
      items: order.items.map(item => ({
        name: item.name || 'Unknown Item',
        price: item.price || 0,
        quantity: item.quantity || 0,
        addOns: item.addOns || []
      })),
      customer: {
        name: order.customerId ? `${order.customerId.firstName} ${order.customerId.lastName}` : 'Unknown Customer',
        email: order.customerId?.email || 'No email',
        phone: order.customerId?.phoneNumber || 'No phone'
      }
    };
    
    res.json(invoiceData);
  } catch (error) {
    console.error('Error in getOrderInvoice:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
};

module.exports = {
  placeCustomerOrder,
  getCustomerOrders,
  getOrderById,
  updateOrderStatus,
  getOrderInvoice,
}; 