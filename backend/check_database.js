require('dotenv').config();
const mongoose = require('mongoose');
const Menu = require('./models/Menu');
const Inventory = require('./models/Inventory');

const MONGO_URI = process.env.MONGO_URI;

async function checkAndSeedDatabase() {
  try {
    await mongoose.connect(MONGO_URI);
    console.log('Connected to MongoDB');

    // Check if menu items exist
    const menuCount = await Menu.countDocuments();
    console.log(`Found ${menuCount} menu items in database`);

    if (menuCount === 0) {
      console.log('No menu items found. Adding sample data...');
      
      // Add sample inventory items first
      const inventoryItems = [
        { name: 'Ramen Noodles', stocks: 100, units: 'packs' },
        { name: 'Chashu Pork', stocks: 50, units: 'pieces' },
        { name: 'Soft Boiled Egg', stocks: 200, units: 'pieces' },
        { name: 'Green Onions', stocks: 30, units: 'bunches' },
        { name: 'Nori Seaweed', stocks: 100, units: 'sheets' },
        { name: 'Miso Paste', stocks: 20, units: 'jars' },
        { name: 'Soy Sauce', stocks: 50, units: 'bottles' },
        { name: 'Rice', stocks: 200, units: 'kg' },
        { name: 'Chicken Breast', stocks: 40, units: 'kg' },
        { name: 'Vegetables', stocks: 30, units: 'kg' },
      ];

      for (const item of inventoryItems) {
        const existing = await Inventory.findOne({ name: item.name });
        if (!existing) {
          await Inventory.create(item);
          console.log(`Added inventory item: ${item.name}`);
        }
      }

      // Add sample menu items
      const menuItems = [
        {
          name: 'Tonkotsu Ramen',
          price: 280.0,
          category: 'ramen',
          image: 'assets/ramen1.jpg',
          ingredients: [
            { inventoryItem: 'Ramen Noodles', quantity: 1 },
            { inventoryItem: 'Chashu Pork', quantity: 2 },
            { inventoryItem: 'Soft Boiled Egg', quantity: 1 },
            { inventoryItem: 'Green Onions', quantity: 1 },
            { inventoryItem: 'Nori Seaweed', quantity: 1 },
          ]
        },
        {
          name: 'Miso Ramen',
          price: 260.0,
          category: 'ramen',
          image: 'assets/ramen2.jpg',
          ingredients: [
            { inventoryItem: 'Ramen Noodles', quantity: 1 },
            { inventoryItem: 'Chashu Pork', quantity: 1 },
            { inventoryItem: 'Soft Boiled Egg', quantity: 1 },
            { inventoryItem: 'Green Onions', quantity: 1 },
            { inventoryItem: 'Miso Paste', quantity: 1 },
          ]
        },
        {
          name: 'Chicken Teriyaki Bowl',
          price: 220.0,
          category: 'rice bowls',
          image: 'assets/ramen3.jpg',
          ingredients: [
            { inventoryItem: 'Rice', quantity: 1 },
            { inventoryItem: 'Chicken Breast', quantity: 1 },
            { inventoryItem: 'Vegetables', quantity: 1 },
            { inventoryItem: 'Soy Sauce', quantity: 1 },
          ]
        },
        {
          name: 'Gyoza',
          price: 120.0,
          category: 'side dishes',
          image: 'assets/ramen4.jpg',
          ingredients: [
            { inventoryItem: 'Chicken Breast', quantity: 1 },
            { inventoryItem: 'Vegetables', quantity: 1 },
          ]
        },
        {
          name: 'Green Tea',
          price: 50.0,
          category: 'drinks',
          image: 'assets/ramen5.jpg',
          ingredients: []
        },
      ];

      for (const item of menuItems) {
        const existing = await Menu.findOne({ name: item.name });
        if (!existing) {
          await Menu.create(item);
          console.log(`Added menu item: ${item.name}`);
        }
      }

      console.log('Sample data added successfully!');
    } else {
      console.log('Database already has menu items. No need to seed.');
    }

    // List all menu items
    const allMenuItems = await Menu.find();
    console.log('\nCurrent menu items:');
    allMenuItems.forEach(item => {
      console.log(`- ${item.name} (${item.category}): ₱${item.price}`);
    });

  } catch (error) {
    console.error('Error:', error);
  } finally {
    await mongoose.disconnect();
    console.log('Disconnected from MongoDB');
  }
}

checkAndSeedDatabase(); 