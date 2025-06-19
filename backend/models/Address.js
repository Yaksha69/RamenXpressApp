const mongoose = require('mongoose');

const AddressSchema = new mongoose.Schema({
  customerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Customer',
    required: true
  },
  label: {
    type: String,
    required: true,
    trim: true,
    enum: ['Home', 'Work', 'School', 'Other']
  },
  recipientName: {
    type: String,
    required: true,
    trim: true
  },
  phoneNumber: {
    type: String,
    required: true,
    trim: true
  },
  street: {
    type: String,
    required: true,
    trim: true
  },
  city: {
    type: String,
    required: true,
    trim: true
  },
  state: {
    type: String,
    required: true,
    trim: true
  },
  zipCode: {
    type: String,
    required: true,
    trim: true
  },
  country: {
    type: String,
    default: 'Philippines',
    trim: true
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
AddressSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// Ensure only one default address per customer
AddressSchema.pre('save', async function(next) {
  if (this.isDefault) {
    await this.constructor.updateMany(
      { customerId: this.customerId, _id: { $ne: this._id } },
      { isDefault: false }
    );
  }
  next();
});

// Method to get formatted address
AddressSchema.methods.getFormattedAddress = function() {
  return {
    id: this._id,
    label: this.label,
    recipientName: this.recipientName,
    phoneNumber: this.phoneNumber,
    fullAddress: `${this.street}, ${this.city}, ${this.state} ${this.zipCode}, ${this.country}`,
    street: this.street,
    city: this.city,
    state: this.state,
    zipCode: this.zipCode,
    country: this.country,
    isDefault: this.isDefault,
    isActive: this.isActive
  };
};

module.exports = mongoose.model('Address', AddressSchema); 