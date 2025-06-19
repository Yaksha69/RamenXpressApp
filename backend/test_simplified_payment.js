const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api/v1';

// Test data for simplified payment method
const testCustomer = {
  email: 'testsimple@example.com',
  password: 'password123',
  firstName: 'Test',
  lastName: 'Simple',
  phoneNumber: '09123456789'
};

let authToken = '';

async function testSimplifiedPaymentMethod() {
  console.log('🧪 Testing Simplified Payment Method (Name + Phone Number)');
  console.log('==========================================================\n');

  try {
    // Step 1: Register customer
    console.log('1️⃣ Registering customer...');
    const registerResponse = await axios.post(`${BASE_URL}/customers/register`, testCustomer);
    console.log('✅ Customer registered successfully');

    // Step 2: Login customer
    console.log('\n2️⃣ Logging in customer...');
    const loginResponse = await axios.post(`${BASE_URL}/customers/login`, {
      email: testCustomer.email,
      password: testCustomer.password
    });
    authToken = loginResponse.data.token;
    console.log('✅ Customer logged in successfully');

    // Step 3: Create GCash payment method (simplified)
    console.log('\n3️⃣ Creating GCash payment method (simplified)...');
    const gcashPaymentMethod = {
      type: 'gcash',
      title: 'My GCash', // Auto-generated
      accountNumber: '09123456789', // Phone number
      accountName: 'John Doe', // Full name
      isDefault: true
    };

    const gcashResponse = await axios.post(`${BASE_URL}/payment-methods`, gcashPaymentMethod, {
      headers: { Authorization: `Bearer ${authToken}` }
    });
    console.log('✅ GCash payment method created successfully');
    console.log(`   Name: ${gcashResponse.data.data.accountName}`);
    console.log(`   Phone: ${gcashResponse.data.data.accountNumber}`);
    console.log(`   Type: ${gcashResponse.data.data.type}`);
    const gcashId = gcashResponse.data.data.id;

    // Step 4: Create PayMaya payment method (simplified)
    console.log('\n4️⃣ Creating PayMaya payment method (simplified)...');
    const paymayaPaymentMethod = {
      type: 'paymaya',
      title: 'My PayMaya', // Auto-generated
      accountNumber: '09187654321', // Phone number
      accountName: 'Jane Smith', // Full name
      isDefault: false
    };

    const paymayaResponse = await axios.post(`${BASE_URL}/payment-methods`, paymayaPaymentMethod, {
      headers: { Authorization: `Bearer ${authToken}` }
    });
    console.log('✅ PayMaya payment method created successfully');
    console.log(`   Name: ${paymayaResponse.data.data.accountName}`);
    console.log(`   Phone: ${paymayaResponse.data.data.accountNumber}`);
    console.log(`   Type: ${paymayaResponse.data.data.type}`);

    // Step 5: Get all payment methods
    console.log('\n5️⃣ Getting all payment methods...');
    const getAllResponse = await axios.get(`${BASE_URL}/payment-methods`, {
      headers: { Authorization: `Bearer ${authToken}` }
    });
    console.log('✅ Payment methods retrieved successfully');
    console.log(`   Found ${getAllResponse.data.data.length} payment methods`);
    
    getAllResponse.data.data.forEach((method, index) => {
      console.log(`   ${index + 1}. ${method.type.toUpperCase()} - ${method.accountName} (${method.accountNumber})`);
    });

    // Step 6: Test invalid payment type
    console.log('\n6️⃣ Testing invalid payment type...');
    try {
      const invalidPaymentMethod = {
        type: 'card', // This should fail
        title: 'My Card',
        accountNumber: '09123456789',
        accountName: 'John Doe'
      };

      await axios.post(`${BASE_URL}/payment-methods`, invalidPaymentMethod, {
        headers: { Authorization: `Bearer ${authToken}` }
      });
      console.log('❌ Should have failed for invalid payment type');
    } catch (error) {
      if (error.response && error.response.status === 400) {
        console.log('✅ Correctly rejected invalid payment method type');
        console.log(`   Error: ${error.response.data.message}`);
      } else {
        console.log('❌ Unexpected error:', error.message);
      }
    }

    // Step 7: Update payment method
    console.log('\n7️⃣ Updating payment method...');
    const updateData = {
      accountName: 'John Updated Doe',
      accountNumber: '09987654321'
    };

    const updateResponse = await axios.put(`${BASE_URL}/payment-methods/${gcashId}`, updateData, {
      headers: { Authorization: `Bearer ${authToken}` }
    });
    console.log('✅ Payment method updated successfully');
    console.log(`   New name: ${updateResponse.data.data.accountName}`);
    console.log(`   New phone: ${updateResponse.data.data.accountNumber}`);

    console.log('\n🎉 All simplified payment method tests passed successfully!');
    console.log('✅ Payment methods now use only name and phone number');
    console.log('✅ Only GCash and PayMaya are supported');

  } catch (error) {
    console.error('\n❌ Test failed:', error.response?.data || error.message);
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Data:', error.response.data);
    }
  }
}

// Run the test
testSimplifiedPaymentMethod(); 