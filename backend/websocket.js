const { Server } = require('socket.io');

let io = null;

const initializeWebSocket = (server) => {
  io = new Server(server, {
    cors: {
      origin: function (origin, callback) {
        // Allow requests with no origin (like mobile apps or Postman)
        if (!origin) return callback(null, true);
        
        // Allow any localhost port for development
        if (origin.startsWith('http://localhost:') || 
            origin.startsWith('http://127.0.0.1:') ||
            origin.startsWith('http://10.0.2.2:')) {
          return callback(null, true);
        }
        
        // Allow specific production origins if needed
        const allowedOrigins = [
          'https://your-production-domain.com', // Add your production domain here
        ];
        
        if (allowedOrigins.includes(origin)) {
          return callback(null, true);
        }
        
        callback(new Error('Not allowed by CORS'));
      },
      credentials: true,
      methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
    }
  });

  // WebSocket connection handling
  io.on('connection', (socket) => {
    console.log('🔌 Client connected:', socket.id);

    // Join admin room for real-time order updates
    socket.on('join-admin', () => {
      socket.join('admin');
      console.log('👨‍💼 Admin joined room');
    });

    // Join customer room for order status updates
    socket.on('join-customer', (customerId) => {
      socket.join(`customer-${customerId}`);
      console.log(`👤 Customer ${customerId} joined room`);
    });

    // Handle order status updates from admin
    socket.on('update-order-status', (data) => {
      io.to('admin').emit('orderStatusUpdated', data);
      if (data.customerId) {
        io.to(`customer-${data.customerId}`).emit('orderStatusUpdated', data);
      }
    });

    socket.on('disconnect', () => {
      console.log('🔌 Client disconnected:', socket.id);
    });
  });

  return io;
};

const getIO = () => {
  if (!io) {
    throw new Error('WebSocket not initialized. Call initializeWebSocket first.');
  }
  return io;
};

module.exports = {
  initializeWebSocket,
  getIO
}; 