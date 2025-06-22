const mongoose = require('mongoose');
const User = require('./models/User');
require('dotenv').config();

async function resetPasswords() {
    try {
        // Connect to MongoDB
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected to MongoDB');
        
        // Reset admin password
        const adminUser = await User.findOne({ username: 'admin' });
        if (adminUser) {
            adminUser.password = 'password123';
            await adminUser.save();
            console.log('✅ Admin password reset to: password123');
        } else {
            console.log('❌ Admin user not found');
        }
        
        // Reset cashier password
        const cashierUser = await User.findOne({ username: 'cashier' });
        if (cashierUser) {
            cashierUser.password = 'password123';
            await cashierUser.save();
            console.log('✅ Cashier password reset to: password123');
        } else {
            console.log('❌ Cashier user not found');
        }
        
        console.log('\n✅ Password reset completed');
        
    } catch (error) {
        console.error('❌ Error resetting passwords:', error);
    } finally {
        await mongoose.disconnect();
        console.log('Disconnected from MongoDB');
    }
}

resetPasswords(); 