# RamenXpress - Restaurant Management System

A comprehensive restaurant management system for ramen restaurants with mobile app, web admin panel, and cashier interface.

## 🚀 Quick Start

### Prerequisites
- Node.js (v14+)
- MongoDB (v4.4+)
- Flutter SDK (v3.0+) - for mobile development

### Installation

1. **Backend Setup**
   ```bash
   cd backend
   npm install
   # Create .env file with MONGODB_URI and JWT_SECRET
   npm start
   ```

2. **Frontend Access**
   - Admin Panel: `http://localhost:3000/admin`
   - Cashier Interface: `http://localhost:3000/cashier`
   - Login: `http://localhost:3000/login.html`

3. **Mobile App**
   ```bash
   cd mobileApp/ramenxpress
   flutter pub get
   flutter run
   ```

## 📱 Features

### Mobile App (Customer)
- User authentication & profile management
- Menu browsing with categories and search
- Order placement with customization
- Real-time order tracking via WebSocket
- Multiple payment methods (GCash, PayMaya, COD)
- Address management and order history
- Push notifications for order updates

### Admin Panel
- Dashboard with sales analytics and charts
- Inventory management with stock monitoring
- Menu management with image uploads
- Sales reports with date filtering
- Staff management and user roles
- Real-time order monitoring

### Cashier Interface (POS)
- Point of sale with quick order processing
- Mobile order management and status updates
- Payment processing with multiple methods
- Order queue with real-time updates
- Daily sales summary and reconciliation
- Receipt generation and printing

## 📡 API Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/login` | User login |
| POST | `/api/auth/register` | User registration |

### Menu Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/menu` | Get all menu items |
| GET | `/api/menu/category/:category` | Get menu by category |
| POST | `/api/menu` | Create menu item |
| PUT | `/api/menu/:id` | Update menu item |
| DELETE | `/api/menu/:id` | Delete menu item |

### Inventory Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/inventory` | Get all inventory items |
| POST | `/api/inventory` | Add inventory item |
| PUT | `/api/inventory/:id` | Update inventory item |
| PATCH | `/api/inventory/:id/quantity` | Update quantity |
| DELETE | `/api/inventory/:id` | Delete inventory item |

### Mobile Orders
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/mobile-orders/orders` | Get all orders with filtering |
| GET | `/api/v1/mobile-orders/orders/:orderId` | Get order details |
| PUT | `/api/v1/mobile-orders/orders/:orderId/status` | Update order status |
| PUT | `/api/v1/mobile-orders/orders/:orderId/payment-status` | Update payment status |
| PUT | `/api/v1/mobile-orders/orders/:orderId/cancel` | Cancel order |
| GET | `/api/v1/mobile-orders/statistics` | Get order statistics |

### Sales Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/sales/order` | Place new order |
| GET | `/api/sales` | Get all sales |
| GET | `/api/sales/range` | Get sales by date range |

### Customer Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/customers` | Get all customers |
| GET | `/api/customers/:id` | Get customer by ID |
| POST | `/api/customers` | Create customer |
| PUT | `/api/customers/:id` | Update customer |
| DELETE | `/api/customers/:id` | Delete customer |

### Payment Methods
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/payment-methods` | Get all payment methods |
| POST | `/api/payment-methods` | Create payment method |

## 🔐 Default Credentials

- **Admin**: admin@ramenxpress.com / admin123
- **Cashier**: cashier@ramenxpress.com / cashier123

## 🛠️ Tech Stack

- **Backend**: Node.js, Express.js, MongoDB, Mongoose
- **Frontend**: HTML5, CSS3, JavaScript, Bootstrap 5
- **Mobile**: Flutter, Dart, Provider pattern
- **Real-time**: Socket.io
- **Authentication**: JWT

## 📄 License

MIT License 