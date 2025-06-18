const Order = require('../models/Order');
const MenuItem = require('../models/MenuItem');

// Create a new order
exports.createOrder = async (req, res) => {
    try {
        const {
            customerName,
            items,
            orderType,
            tableNumber,
            paymentMethod,
            deliveryAddress,
            deliveryNotes,
            contactNumber
        } = req.body;

        // Calculate total amount and validate menu items
        let totalAmount = 0;
        const orderItems = [];

        for (const item of items) {
            const menuItem = await MenuItem.findById(item.menuItem);
            if (!menuItem) {
                return res.status(404).json({ message: `Menu item with ID ${item.menuItem} not found` });
            }
            if (!menuItem.isAvailable) {
                return res.status(400).json({ message: `Menu item ${menuItem.name} is not available` });
            }

            // Calculate item total including add-ons
            let itemTotal = menuItem.price * item.quantity;
            const addOns = [];

            if (item.addOns && item.addOns.length > 0) {
                for (const addOn of item.addOns) {
                    itemTotal += addOn.price * item.quantity;
                    addOns.push({
                        name: addOn.name,
                        price: addOn.price
                    });
                }
            }

            totalAmount += itemTotal;
            orderItems.push({
                menuItem: menuItem._id,
                quantity: item.quantity,
                price: menuItem.price,
                addOns: addOns
            });
        }

        // Validate delivery address for delivery orders
        if (orderType === 'delivery' && !deliveryAddress) {
            return res.status(400).json({ message: 'Delivery address is required for delivery orders' });
        }

        // Validate payment method
        if (!['gcash', 'paymaya', 'cod'].includes(paymentMethod)) {
            return res.status(400).json({ message: 'Invalid payment method' });
        }

        const order = new Order({
            customerName,
            items: orderItems,
            totalAmount,
            orderType,
            tableNumber: orderType === 'dine-in' ? tableNumber : undefined,
            paymentMethod,
            deliveryAddress: orderType === 'delivery' ? deliveryAddress : undefined,
            deliveryNotes,
            contactNumber
        });

        await order.save();
        res.status(201).json(order);
    } catch (error) {
        res.status(500).json({ message: 'Error creating order', error: error.message });
    }
};

// Get all orders
exports.getAllOrders = async (req, res) => {
    try {
        const orders = await Order.find()
            .populate('items.menuItem')
            .sort({ createdAt: -1 });
        res.json(orders);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching orders', error: error.message });
    }
};

// Get order by ID
exports.getOrderById = async (req, res) => {
    try {
        const order = await Order.findById(req.params.id)
            .populate('items.menuItem');
        if (!order) {
            return res.status(404).json({ message: 'Order not found' });
        }
        res.json(order);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching order', error: error.message });
    }
};

// Update order status
exports.updateOrderStatus = async (req, res) => {
    try {
        const { status } = req.body;
        const order = await Order.findById(req.params.id);
        
        if (!order) {
            return res.status(404).json({ message: 'Order not found' });
        }

        // Validate status transition
        const validTransitions = {
            'pending': ['preparing', 'cancelled'],
            'preparing': ['ready', 'cancelled'],
            'ready': ['out_for_delivery', 'completed', 'cancelled'],
            'out_for_delivery': ['completed', 'cancelled'],
            'completed': [],
            'cancelled': []
        };

        if (!validTransitions[order.status].includes(status)) {
            return res.status(400).json({ 
                message: `Cannot transition from ${order.status} to ${status}` 
            });
        }

        order.status = status;
        await order.save();
        res.json(order);
    } catch (error) {
        res.status(500).json({ message: 'Error updating order status', error: error.message });
    }
};

// Update payment status
exports.updatePaymentStatus = async (req, res) => {
    try {
        const { paymentStatus } = req.body;
        const order = await Order.findById(req.params.id);
        
        if (!order) {
            return res.status(404).json({ message: 'Order not found' });
        }

        if (!['pending', 'paid', 'failed'].includes(paymentStatus)) {
            return res.status(400).json({ message: 'Invalid payment status' });
        }

        order.paymentStatus = paymentStatus;
        await order.save();
        res.json(order);
    } catch (error) {
        res.status(500).json({ message: 'Error updating payment status', error: error.message });
    }
};

// Cancel order
exports.cancelOrder = async (req, res) => {
    try {
        const order = await Order.findById(req.params.id);
        
        if (!order) {
            return res.status(404).json({ message: 'Order not found' });
        }

        if (order.status === 'completed') {
            return res.status(400).json({ message: 'Cannot cancel a completed order' });
        }

        order.status = 'cancelled';
        await order.save();
        res.json(order);
    } catch (error) {
        res.status(500).json({ message: 'Error cancelling order', error: error.message });
    }
}; 