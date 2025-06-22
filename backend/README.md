# RamenXpress Backend API

Node.js backend API for the RamenXpress restaurant management system.

## 🚀 Quick Start

### Prerequisites
- Node.js (v14+)
- MongoDB (v4.4+)

### Installation

1. **Install dependencies**
   ```bash
   npm install
   ```

2. **Environment setup**
   Create `.env` file:
   ```env
   PORT=3000
   MONGODB_URI=mongodb://localhost:27017/ramenxpress
   JWT_SECRET=your_jwt_secret_key_here
   NODE_ENV=development
   ```

3. **Start server**
   ```bash
   npm start
   ```

## 📱 Features

### Authentication & Authorization
- JWT-based authentication
- Role-based access control (Admin, Cashier, Customer)
- Password hashing with bcrypt
- Token validation middleware

### Real-time Communication
- WebSocket integration with Socket.io
- Live order status updates
- Payment status notifications
- Order cancellation alerts

### Data Management
- MongoDB with Mongoose ODM
- Optimized database queries
- Data validation and sanitization
- File upload handling

### API Features
- RESTful API design
- Comprehensive error handling
- Request validation
- Pagination support
- Filtering and sorting

## 📡 API Endpoints

### Authentication
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/auth/login` | User login | No |
| POST | `/api/auth/register` | User registration | No |

### Menu Management
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/menu` | Get all menu items | Yes |
| GET | `/api/menu/category/:category` | Get menu by category | Yes |
| POST | `/api/menu` | Create menu item | Yes (Admin) |
| PUT | `/api/menu/:id` | Update menu item | Yes (Admin) |
| DELETE | `/api/menu/:id` | Delete menu item | Yes (Admin) |

### Inventory Management
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/inventory` | Get all inventory items | Yes |
| POST | `/api/inventory` | Add inventory item | Yes (Admin) |
| PUT | `/api/inventory/:id` | Update inventory item | Yes (Admin) |
| PATCH | `/api/inventory/:id/quantity` | Update quantity | Yes |
| DELETE | `/api/inventory/:id` | Delete inventory item | Yes (Admin) |

### Mobile Orders
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/v1/mobile-orders/orders` | Get all orders with filtering | Yes (Cashier/Admin) |
| GET | `/api/v1/mobile-orders/orders/:orderId` | Get order details | Yes (Cashier/Admin) |
| PUT | `/api/v1/mobile-orders/orders/:orderId/status` | Update order status | Yes (Cashier/Admin) |
| PUT | `/api/v1/mobile-orders/orders/:orderId/payment-status` | Update payment status | Yes (Cashier/Admin) |
| PUT | `/api/v1/mobile-orders/orders/:orderId/cancel` | Cancel order | Yes (Cashier/Admin) |
| GET | `/api/v1/mobile-orders/statistics` | Get order statistics | Yes (Admin) |

### Sales Management
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/sales/order` | Place new order | Yes |
| GET | `/api/sales` | Get all sales | Yes (Admin) |
| GET | `/api/sales/range` | Get sales by date range | Yes (Admin) |

### Customer Management
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/customers` | Get all customers | Yes (Admin) |
| GET | `/api/customers/:id` | Get customer by ID | Yes |
| POST | `/api/customers` | Create customer | No |
| PUT | `/api/customers/:id` | Update customer | Yes |
| DELETE | `/api/customers/:id` | Delete customer | Yes (Admin) |

### Payment Methods
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/payment-methods` | Get all payment methods | Yes |
| POST | `/api/payment-methods` | Create payment method | Yes (Admin) |

## 🔄 WebSocket Events

### Server Events
| Event | Description | Data |
|-------|-------------|------|
| `orderStatusUpdated` | Order status changed | `{orderId, status, order}` |
| `paymentStatusUpdated` | Payment status changed | `{orderId, paymentStatus, order}` |
| `orderCancelled` | Order cancelled | `{orderId, reason, order}` |
| `orderNotesUpdated` | Order notes updated | `{orderId, notes, order}` |

### Client Events
| Event | Description |
|-------|-------------|
| `join-admin` | Join admin room for updates |
| `join-customer` | Join customer room for updates |

## 🛠️ Tech Stack

- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: MongoDB with Mongoose
- **Authentication**: JWT
- **Real-time**: Socket.io
- **Validation**: Express-validator
- **File Upload**: Multer

## 📄 License

MIT License 