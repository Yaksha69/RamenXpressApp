const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
    customerName: {
        type: String,
        required: true
    },
    items: [{
        menuItem: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'MenuItem',
            required: true
        },
        quantity: {
            type: Number,
            required: true,
            min: 1
        },
        price: {
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
    totalAmount: {
        type: Number,
        required: true
    },
    status: {
        type: String,
        enum: ['pending', 'preparing', 'ready', 'out_for_delivery', 'completed', 'cancelled'],
        default: 'pending'
    },
    orderType: {
        type: String,
        enum: ['dine-in', 'pickup', 'delivery'],
        required: true
    },
    tableNumber: {
        type: Number,
        required: function() {
            return this.orderType === 'dine-in';
        }
    },
    paymentMethod: {
        type: String,
        enum: ['gcash', 'paymaya', 'cod'],
        required: true
    },
    paymentStatus: {
        type: String,
        enum: ['pending', 'paid', 'failed'],
        default: 'pending'
    },
    deliveryAddress: {
        street: {
            type: String,
            required: function() {
                return this.orderType === 'delivery';
            }
        },
        city: {
            type: String,
            required: function() {
                return this.orderType === 'delivery';
            }
        },
        state: {
            type: String,
            required: function() {
                return this.orderType === 'delivery';
            }
        },
        zipCode: {
            type: String,
            required: function() {
                return this.orderType === 'delivery';
            }
        },
        coordinates: {
            latitude: Number,
            longitude: Number
        }
    },
    deliveryNotes: {
        type: String,
        maxLength: 500
    },
    contactNumber: {
        type: String,
        required: true
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

// Update the updatedAt timestamp before saving
orderSchema.pre('save', function(next) {
    this.updatedAt = Date.now();
    next();
});

module.exports = mongoose.model('Order', orderSchema); 