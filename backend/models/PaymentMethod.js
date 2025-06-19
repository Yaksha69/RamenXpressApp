const mongoose = require('mongoose');

const PaymentMethodSchema = new mongoose.Schema({
  customerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Customer',
    required: true
  },
  type: {
    type: String,
    required: true,
    enum: ['gcash', 'paymaya']
  },
  title: {
    type: String,
    required: true,
    trim: true
  },
  accountNumber: {
    type: String,
    required: true,
    trim: true,
    // This stores the phone number for GCash/PayMaya
  },
  accountName: {
    type: String,
    required: true,
    trim: true,
    // This stores the full name of the account holder
  },
  isDefault: {
    type: Boolean,
    default: false
  },
  isActive: {
    type: Boolean,
    default: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// Update the updatedAt field before saving
PaymentMethodSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// Ensure only one default payment method per customer
PaymentMethodSchema.pre('save', async function(next) {
  if (this.isDefault) {
    await this.constructor.updateMany(
      { customerId: this.customerId, _id: { $ne: this._id } },
      { isDefault: false }
    );
  }
  next();
});

// Method to get public profile (without sensitive data)
PaymentMethodSchema.methods.getPublicProfile = function() {
  return {
    id: this._id,
    type: this.type,
    title: this.title,
    accountNumber: this.accountNumber ? '****' + this.accountNumber.slice(-4) : 'N/A',
    accountName: this.accountName,
    isDefault: this.isDefault,
    isActive: this.isActive
  };
};

module.exports = mongoose.model('PaymentMethod', PaymentMethodSchema); 