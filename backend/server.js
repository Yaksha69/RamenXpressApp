require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const cookieParser = require('cookie-parser');
const path = require('path');
const fs = require('fs');
const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGO_URI;

const InventoryRoutes = require('./routes/InventoryRoutes');
const MenuRoutes = require('./routes/MenuRoutes');
const SalesRoutes = require('./routes/SalesRoutes');
const AuthRoutes = require('./routes/AuthRoutes');
const OrderRoutes = require('./routes/OrderRoutes');
const MenuItemRoutes = require('./routes/MenuItemRoutes');
const { verifyToken, isAdmin, isCashier } = require('./middleware/AuthMiddleware');

const app = express();

// Configure CORS
app.use(cors({
    origin: '*', // Allow all origins during development
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
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
app.use(mapper + '/inventory', verifyToken, isAdmin, InventoryRoutes);
app.use(mapper + '/menu', verifyToken, isCashier, MenuRoutes);
app.use(mapper + '/menu-items', MenuItemRoutes);
app.use(mapper + '/sales', verifyToken, isAdmin, SalesRoutes);
app.use(mapper + '/orders', OrderRoutes);

app.use(mapper + '/upload', require('./routes/UploadRoutes'));

mongoose.connect(MONGO_URI)
  .then(() => console.log('MongoDB Connected'))
  .catch(err => console.log(err));

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Something went wrong!', error: err.message });
});

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));