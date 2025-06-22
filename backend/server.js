require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const cookieParser = require('cookie-parser');
const path = require('path');
const fs = require('fs');
const PORT = process.env.PORT;
const MONGO_URI = process.env.MONGO_URI;
const http = require('http');
const { initializeWebSocket } = require('./websocket');

const InventoryRoutes = require('./routes/InventoryRoutes');
const MenuRoutes = require('./routes/MenuRoutes');
const SalesRoutes = require('./routes/SalesRoutes');
const AuthRoutes = require('./routes/AuthRoutes');
const CustomerRoutes = require('./routes/CustomerRoutes');
const AddressRoutes = require('./routes/AddressRoutes');
const PaymentMethodRoutes = require('./routes/PaymentMethodRoutes');
const CustomerOrderRoutes = require('./routes/CustomerOrderRoutes');
const MobileOrderRoutes = require('./routes/MobileOrderRoutes');
const { verifyToken, isAdmin, isCashier } = require('./middleware/AuthMiddleware');

const app = express();

// Configure CORS
app.use(cors({
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
    credentials: true, // Allow credentials
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());

// Serve static files from uploads directory
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Create uploads directory if it doesn't exist
if (!fs.existsSync('uploads')) {
  fs.mkdirSync('uploads');
}

const mapper = '/api/v1';

app.use(mapper + '/auth', AuthRoutes);
app.use(mapper + '/customer', CustomerRoutes);
app.use(mapper + '/addresses', AddressRoutes);
app.use(mapper + '/customer-orders', CustomerOrderRoutes);
app.use(mapper + '/mobile-orders', MobileOrderRoutes);
app.use(mapper + '/inventory', verifyToken, isAdmin, InventoryRoutes);
app.use(mapper + '/menu', verifyToken, isCashier, MenuRoutes);
app.use(mapper + '/menu-public', MenuRoutes);
app.use(mapper + '/sales', verifyToken, isCashier, SalesRoutes);
app.use(mapper + '/upload', require('./routes/UploadRoutes'));
app.use(mapper + '/payment-methods', PaymentMethodRoutes);

mongoose.connect(MONGO_URI)
  .then(() => console.log('MongoDB Connected'))
  .catch(err => console.log(err));

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Something went wrong!', error: err.message });
});

const server = http.createServer(app);

// Initialize WebSocket
const io = initializeWebSocket(server);

server.listen(PORT, () => console.log(`Server running on port ${PORT}`));