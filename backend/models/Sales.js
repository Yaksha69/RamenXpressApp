const mongoose = require('mongoose');

const SalesSchema = new mongoose.Schema({
  orderId: {
    type: Number,
    required: true,
    unique: true
  },
  customerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Customer',
    required: false // Optional for POS orders
  },
  items: [{
    name: {
      type: String,
      required: true
    },
    price: {
      type: Number,
      required: true
    },
    quantity: {
      type: Number,
      required: true
    },
    total: {
      type: Number,
      required: true
    },
    addOns: [{
      name: {
        type: String,
        required: true
      },
      price: {
        type: Number,
        required: true
      }
    }]
  }],
  total: {
    type: Number,
    required: true
  },
  orderType: {
    type: String,
    enum: ['takeout', 'dine-in', 'delivery'],
    required: true
  },
  paymentMethod: {
    type: String,
    enum: ['gcash', 'paymaya', 'cash'],
    required: true
  },
  deliveryAddress: {
    street: String,
    city: String,
    state: String,
    zipCode: String,
    country: String,
    isDefault: Boolean
  },
  deliveryFee: {
    type: Number,
    default: 0
  },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'preparing', 'ready', 'delivered', 'cancelled'],
    default: 'pending'
  },
  notes: {
    type: String,
    default: ''
  },
  orderDate: {
    type: Date,
    default: Date.now
  }
});

// Create a counter collection for order IDs
const CounterSchema = new mongoose.Schema({
  _id: { type: String, required: true },
  seq: { type: Number, default: 0 }
});

const Counter = mongoose.model('Counter', CounterSchema);

// Function to get next order ID
SalesSchema.statics.getNextOrderId = async function() {
  const counter = await Counter.findByIdAndUpdate(
    'orderId',
    { $inc: { seq: 1 } },
    { new: true, upsert: true }
  );
  return counter.seq;
};

module.exports = mongoose.model('Sales', SalesSchema);
