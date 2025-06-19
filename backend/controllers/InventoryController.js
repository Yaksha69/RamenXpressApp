const Inventory = require('../models/Inventory');
const { io } = require('../server');

// Get all inventory items
const getInventory = async (req, res) => {
  try {
    const items = await Inventory.find();
    res.status(200).json(items);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch inventory' });
  }
};

// Add a new inventory item
const addInventory = async (req, res) => {
  try {
    const { name, stocks, units, restocked, status } = req.body;
    const newItem = new Inventory({
      name,
      stocks,
      units,
      restocked,
      status
    });
    const savedItem = await newItem.save();
    io.emit('inventoryUpdated', { type: 'add', item: savedItem });
    res.status(201).json(savedItem);
  } catch (err) {
    res.status(400).json({ error: 'Failed to add inventory item' });
  }
};

// Update inventory quantity
const updateInventoryQuantity = async (req, res) => {
  try {
    const { id } = req.params;
    const { quantity } = req.body;

    if (!quantity || quantity < 0) {
      return res.status(400).json({ error: 'Invalid quantity value' });
    }

    const item = await Inventory.findById(id);
    if (!item) {
      return res.status(404).json({ error: 'Inventory item not found' });
    }

    item.stocks += quantity;
    item.restocked = Date.now();
    
    // Update status based on new stock level
    if (item.stocks <= 0) {
      item.status = 'out of stock';
    } else if (item.stocks < 10) {
      item.status = 'low stock';
    } else {
      item.status = 'in stock';
    }

    const updatedItem = await item.save();
    io.emit('inventoryUpdated', { type: 'update', item: updatedItem });
    res.status(200).json(updatedItem);
  } catch (err) {
    res.status(500).json({ error: 'Failed to update inventory quantity' });
  }
};

// Delete inventory item
const deleteInventory = async (req, res) => {
  try {
    const { id } = req.params;
    
    const deletedItem = await Inventory.findByIdAndDelete(id);
    if (!deletedItem) {
      return res.status(404).json({ error: 'Inventory item not found' });
    }
    
    io.emit('inventoryUpdated', { type: 'delete', item: deletedItem });
    res.status(200).json({ message: 'Inventory item deleted successfully', deletedItem });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete inventory item' });
  }
};

// Edit inventory item
const editInventory = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, stocks, units, status } = req.body;

    // Validate required fields
    if (!name || !stocks || !units) {
      return res.status(400).json({ error: 'Name, stocks, and units are required' });
    }

    // Validate stocks is a positive number
    if (stocks < 0) {
      return res.status(400).json({ error: 'Stocks cannot be negative' });
    }

    // Validate status if provided
    if (status && !['in stock', 'low stock', 'out of stock'].includes(status)) {
      return res.status(400).json({ error: 'Invalid status value' });
    }

    const item = await Inventory.findById(id);
    if (!item) {
      return res.status(404).json({ error: 'Inventory item not found' });
    }

    // Update fields
    item.name = name;
    item.stocks = stocks;
    item.units = units;
    item.restocked = Date.now();
    
    // Update status based on stock level if not explicitly provided
    if (!status) {
      if (stocks <= 0) {
        item.status = 'out of stock';
      } else if (stocks < 10) {
        item.status = 'low stock';
      } else {
        item.status = 'in stock';
      }
    } else {
      item.status = status;
    }

    const updatedItem = await item.save();
    io.emit('inventoryUpdated', { type: 'edit', item: updatedItem });
    res.status(200).json(updatedItem);
  } catch (err) {
    res.status(500).json({ error: 'Failed to update inventory item' });
  }
};

module.exports = {
  getInventory,
  addInventory,
  updateInventoryQuantity,
  deleteInventory,
  editInventory
};