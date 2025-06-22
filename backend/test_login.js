const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api/v1';

async function testLogin() {
    try {
        console.log('Testing login endpoint...');
        
        // Test with cashier credentials
        const response = await axios.post(`${BASE_URL}/auth/login`, {
            username: 'cashier',
            password: 'password123'
        });
        
        console.log('Login response:', JSON.stringify(response.data, null, 2));
        
        if (response.data.customer) {
            console.log('✅ Login successful');
            console.log('User role:', response.data.customer.role);
            console.log('Username:', response.data.customer.username);
            console.log('Token received:', !!response.data.token);
        } else {
            console.log('❌ Login failed - no customer data in response');
        }
        
    } catch (error) {
        console.error('❌ Login test failed:', error.response?.data || error.message);
    }
}

// Test admin login
async function testAdminLogin() {
    try {
        console.log('\nTesting admin login...');
        
        const response = await axios.post(`${BASE_URL}/auth/login`, {
            username: 'admin',
            password: 'password123'
        });
        
        console.log('Admin login response:', JSON.stringify(response.data, null, 2));
        
    } catch (error) {
        console.error('❌ Admin login test failed:', error.response?.data || error.message);
    }
}

// Run tests
async function runTests() {
    await testLogin();
    await testAdminLogin();
}

runTests(); 