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
const { Server } = require('socket.io');

const InventoryRoutes = require('./routes/InventoryRoutes');
const MenuRoutes = require('./routes/MenuRoutes');
const SalesRoutes = require('./routes/SalesRoutes');
const AuthRoutes = require('./routes/AuthRoutes');
const CustomerRoutes = require('./routes/CustomerRoutes');
const AddressRoutes = require('./routes/AddressRoutes');
const PaymentMethodRoutes = require('./routes/PaymentMethodRoutes');
const CustomerOrderRoutes = require('./routes/CustomerOrderRoutes');
const { verifyToken, isAdmin, isCashier } = require('./middleware/AuthMiddleware');

const app = express();

// Configure CORS
app.use(cors({
    origin: [
        'http://127.0.0.1:5500', // Frontend origin
        'http://localhost:3000', // Backend origin
        'http://localhost:59261', // Mobile app origin
        'http://localhost:8080', // Alternative port
        'http://localhost:5000', // Alternative port
        'http://localhost:50522', // Flutter web app origin
        'http://10.0.2.2:3000', // Android emulator
        'http://10.0.2.2:8080', // Android emulator alternative
        ''
    ],
    credentials: true, // Allow credentials
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
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
const io = new Server(server, {
  cors: {
    origin: [
      'http://127.0.0.1:5500',
      'http://localhost:3000',
      'http://localhost:59261',
      'http://localhost:8080',
      'http://localhost:5000',
      'http://localhost:50522',
      'http://10.0.2.2:3000',
      'http://10.0.2.2:8080',
      ''
    ],
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
  }
});

// Export io for use in controllers
module.exports.io = io;

server.listen(PORT, () => console.log(`Server running on port ${PORT}`));