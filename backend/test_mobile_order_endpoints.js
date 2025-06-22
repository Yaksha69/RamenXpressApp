const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api/v1';
let authToken = '';

// Test data
const testOrderData = {
  items: [
    {
      menuId: '507f1f77bcf86cd799439011', // Replace with actual menu ID
      quantity: 2,
      addOns: [
        { name: 'Extra Noodles', price: 50 }
      ]
    }
  ],
  orderType: 'delivery',
  paymentMethod: 'gcash',
  deliveryAddress: {
    street: '123 Test Street',
    city: 'Test City',
    state: 'Test State',
    zipCode: '12345',
    country: 'Philippines',
    isDefault: true
  },
  notes: 'Test order from mobile app'
};

async function loginAsCashier() {
  try {
    const response = await axios.post(`${BASE_URL}/auth/login`, {
      email: 'cashier@ramenxpress.com', // Replace with actual cashier credentials
      password: 'password123'
    });
    
    authToken = response.data.token;
    console.log('✅ Logged in as cashier');
    return authToken;
  } catch (error) {
    console.error('❌ Login failed:', error.response?.data || error.message);
    throw error;
  }
}

async function testGetAllOrders() {
  try {
    const response = await axios.get(`${BASE_URL}/mobile-orders/orders`, {
      headers: { Authorization: `Bearer ${authToken}` }
    });
    
    console.log('✅ Get all orders successful');
    console.log('Orders count:', response.data.orders?.length || 0);
    return response.data;
  } catch (error) {
    console.error('❌ Get all orders failed:', error.response?.data || error.message);
    throw error;
  }
}

async function testGetOrderDetails(orderId) {
  try {
    const response = await axios.get(`${BASE_URL}/mobile-orders/orders/${orderId}`, {
      headers: { Authorization: `Bearer ${authToken}` }
    });
    
    console.log('✅ Get order details successful');
    console.log('Order ID:', response.data.order?.orderId);
    return response.data;
  } catch (error) {
    console.error('❌ Get order details failed:', error.response?.data || error.message);
    throw error;
  }
}

async function testUpdateOrderStatus(orderId, status) {
  try {
    const response = await axios.put(`${BASE_URL}/mobile-orders/orders/${orderId}/status`, 
      { status },
      { headers: { Authorization: `Bearer ${authToken}` } }
    );
    
    console.log('✅ Update order status successful');
    console.log('New status:', response.data.order?.status);
    return response.data;
  } catch (error) {
    console.error('❌ Update order status failed:', error.response?.data || error.message);
    throw error;
  }
}

async function testUpdatePaymentStatus(orderId, paymentStatus) {
  try {
    const response = await axios.put(`${BASE_URL}/mobile-orders/orders/${orderId}/payment-status`, 
      { paymentStatus },
      { headers: { Authorization: `Bearer ${authToken}` } }
    );
    
    console.log('✅ Update payment status successful');
    console.log('New payment status:', response.data.order?.paymentStatus);
    return response.data;
  } catch (error) {
    console.error('❌ Update payment status failed:', error.response?.data || error.message);
    throw error;
  }
}

async function testCancelOrder(orderId) {
  try {
    const response = await axios.put(`${BASE_URL}/mobile-orders/orders/${orderId}/cancel`, 
      { reason: 'Test cancellation' },
      { headers: { Authorization: `Bearer ${authToken}` } }
    );
    
    console.log('✅ Cancel order successful');
    console.log('Cancellation reason:', response.data.order?.cancellationReason);
    return response.data;
  } catch (error) {
    console.error('❌ Cancel order failed:', error.response?.data || error.message);
    throw error;
  }
}

async function testGetOrderStatistics() {
  try {
    const response = await axios.get(`${BASE_URL}/mobile-orders/statistics`, {
      headers: { Authorization: `Bearer ${authToken}` }
    });
    
    console.log('✅ Get order statistics successful');
    console.log('Total orders:', response.data.statistics?.totalOrders);
    return response.data;
  } catch (error) {
    console.error('❌ Get order statistics failed:', error.response?.data || error.message);
    throw error;
  }
}

async function runTests() {
  console.log('🚀 Starting Mobile Order Endpoints Tests...\n');
  
  try {
    // Login
    await loginAsCashier();
    
    // Test getting all orders
    const ordersData = await testGetAllOrders();
    
    if (ordersData.orders && ordersData.orders.length > 0) {
      const firstOrder = ordersData.orders[0];
      const orderId = firstOrder.orderId;
      
      console.log(`\n📋 Testing with order ID: ${orderId}\n`);
      
      // Test getting order details
      await testGetOrderDetails(orderId);
      
      // Test updating order status
      await testUpdateOrderStatus(orderId, 'confirmed');
      
      // Test updating payment status
      await testUpdatePaymentStatus(orderId, 'Paid');
      
      // Test getting statistics
      await testGetOrderStatistics();
      
      // Note: We won't test cancel order on a real order to avoid data loss
      console.log('\n⚠️  Skipping cancel order test to preserve data');
    } else {
      console.log('\n📝 No orders found to test with. Create some orders first.');
    }
    
    console.log('\n✅ All tests completed successfully!');
    
  } catch (error) {
    console.error('\n❌ Tests failed:', error.message);
  }
}

// Run tests if this file is executed directly
if (require.main === module) {
  runTests();
}

module.exports = {
  loginAsCashier,
  testGetAllOrders,
  testGetOrderDetails,
  testUpdateOrderStatus,
  testUpdatePaymentStatus,
  testCancelOrder,
  testGetOrderStatistics
}; 