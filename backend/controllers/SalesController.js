const Menu = require('../models/Menu');
const Inventory = require('../models/Inventory');
const Sales = require('../models/Sales');
const { getIO } = require('../websocket');

// Place an order with multiple items
const placeOrder = async (req, res) => {
  try {
    const { items, orderType, paymentMethod } = req.body;

    // Validate order type
    if (!orderType || !['takeout', 'dine-in'].includes(orderType)) {
      return res.status(400).json({ 
        message: 'Invalid order type. Must be either "takeout" or "dine-in"' 
      });
    }

    // Validate payment method
    if (!paymentMethod || !['gcash', 'paymaya', 'cash'].includes(paymentMethod)) {
      return res.status(400).json({ 
        message: 'Invalid payment method. Must be either "gcash", "paymaya", or "cash"' 
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

    // Create sales record
    const sale = new Sales({
      orderId,
      items: orderItems,
      total: totalAmount,
      orderType,
      paymentMethod,
      orderDate: new Date()
    });

    await sale.save();

    getIO().emit('salePlaced', {
      orderId,
      items: orderItems,
      total: totalAmount,
      orderType,
      paymentMethod,
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
        orderDate: sale.orderDate
      }
    });

  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
};

// Get all sales
const getSales = async (req, res) => {
  try {
    const sales = await Sales.find().sort({ orderDate: -1 });
    res.status(200).json(sales);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
};

// Get sales by date range
const getSalesByDateRange = async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    const sales = await Sales.find({
      orderDate: {
        $gte: new Date(startDate),
        $lte: new Date(endDate)
      }
    }).sort({ orderDate: -1 });
    res.status(200).json(sales);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
};

module.exports = {
  placeOrder,
  getSales,
  getSalesByDateRange
};