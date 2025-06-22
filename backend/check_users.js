const mongoose = require('mongoose');
const User = require('./models/User');
require('dotenv').config();

async function checkUsers() {
    try {
        // Connect to MongoDB
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected to MongoDB');
        
        // Get all users
        const users = await User.find({}).select('-password');
        console.log('\nUsers in database:');
        console.log(JSON.stringify(users, null, 2));
        
        // Check if we have admin and cashier users
        const adminUsers = users.filter(user => user.role === 'admin');
        const cashierUsers = users.filter(user => user.role === 'cashier');
        
        console.log(`\nAdmin users: ${adminUsers.length}`);
        console.log(`Cashier users: ${cashierUsers.length}`);
        
        if (adminUsers.length === 0) {
            console.log('\n⚠️  No admin users found. Creating default admin...');
            const adminUser = new User({
                username: 'admin',
                password: 'password123',
                role: 'admin'
            });
            await adminUser.save();
            console.log('✅ Default admin user created');
        }
        
        if (cashierUsers.length === 0) {
            console.log('\n⚠️  No cashier users found. Creating default cashier...');
            const cashierUser = new User({
                username: 'cashier',
                password: 'password123',
                role: 'cashier'
            });
            await cashierUser.save();
            console.log('✅ Default cashier user created');
        }
        
        console.log('\n✅ User check completed');
        
    } catch (error) {
        console.error('❌ Error checking users:', error);
    } finally {
        await mongoose.disconnect();
        console.log('Disconnected from MongoDB');
    }
}

checkUsers(); 