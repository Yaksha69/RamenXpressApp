const Menu = require('../models/Menu');
const Inventory = require('../models/Inventory');
const Sales = require('../models/Sales');
const Customer = require('../models/Customer');
const { io } = require('../server');

// Place a customer order from mobile app
const placeCustomerOrder = async (req, res) => {
  try {
    const { 
      items, 
      orderType, 
      paymentMethod, 
      deliveryAddress, 
      notes
    } = req.body;

    // Get customer ID from authenticated customer
    const customerId = req.customerId;

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

    // Get next order ID
    const orderId = await Sales.getNextOrderId();
    const orderItems = [];
    let totalAmount = 0;

    // Process each item in the order
    for (const item of items) {
      const { menuId, quantity = 1, addOns = [] } = item;
      const menuItem = await Menu.findById(menuId);
      
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

    // Calculate delivery fee
    const deliveryFee = orderType === 'delivery' ? 50.0 : 0.0;
    totalAmount += deliveryFee;

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

    await sale.save();

    io.emit('orderPlaced', {
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

    res.status(200).json({
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
    });

  } catch (error) {
    console.error('Error placing customer order:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// Get customer orders
const getCustomerOrders = async (req, res) => {
  try {
    // Use the authenticated customer's ID from the JWT token
    const customerId = req.customerId;
    
    if (!customerId) {
      return res.status(400).json({ message: 'Customer ID is required' });
    }

    const orders = await Sales.find({ customerId })
      .sort({ orderDate: -1 })
      .populate('customerId', 'firstName lastName email phoneNumber');

    res.status(200).json(orders);
  } catch (error) {
    console.error('Error getting customer orders:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// Get order by ID
const getOrderById = async (req, res) => {
  try {
    const { orderId } = req.params;
    
    const order = await Sales.findOne({ orderId: parseInt(orderId) })
      .populate('customerId', 'firstName lastName email phoneNumber');

    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
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

    if (!status || !['pending', 'confirmed', 'preparing', 'ready', 'delivered', 'cancelled'].includes(status)) {
      return res.status(400).json({ 
        message: 'Invalid status. Must be one of: pending, confirmed, preparing, ready, delivered, cancelled' 
      });
    }

    const order = await Sales.findOneAndUpdate(
      { orderId: parseInt(orderId) },
      { status },
      { new: true }
    ).populate('customerId', 'firstName lastName email phoneNumber');

    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    io.emit('orderStatusUpdated', { orderId, status });

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
  console.log('🔍 DEBUG: getOrderInvoice called');
  console.log('🔍 DEBUG: req.params:', req.params);
  console.log('🔍 DEBUG: req.customerId:', req.customerId);
  
  try {
    const { orderId } = req.params;
    const customerId = req.customerId;
    
    console.log('🔍 DEBUG: orderId from params:', orderId);
    console.log('🔍 DEBUG: customerId from customerId:', customerId);
    
    if (!orderId) {
      console.log('❌ DEBUG: No orderId provided');
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
    
    console.log('🔍 DEBUG: Found order:', order);
    
    if (!order) {
      console.log('❌ DEBUG: Order not found');
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
    
    console.log('🔍 DEBUG: Formatted invoice data:', invoiceData);
    
    res.json(invoiceData);
  } catch (error) {
    console.log('❌ DEBUG: Error in getOrderInvoice:', error);
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