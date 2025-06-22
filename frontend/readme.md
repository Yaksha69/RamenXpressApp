# RamenXpress Frontend

Web interfaces for the RamenXpress restaurant management system.

## 🚀 Quick Start

### Prerequisites
- Modern web browser
- Backend API server running

### Installation

1. **Ensure backend is running**
   ```bash
   cd backend
   npm start
   ```

2. **Access interfaces**
   - Admin Panel: `http://localhost:3000/admin`
   - Cashier Interface: `http://localhost:3000/cashier`
   - Login: `http://localhost:3000/login.html`

3. **Login credentials**
   - Admin: admin@ramenxpress.com / admin123
   - Cashier: cashier@ramenxpress.com / cashier123

## 📱 Features

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

### Common Features
- Responsive design for all devices
- Real-time Socket.IO updates
- JWT authentication
- Role-based access control
- Modern UI with Bootstrap 5

## 📡 API Integration

### Authentication
| Method | Endpoint | Usage |
|--------|----------|-------|
| POST | `/api/auth/login` | User login |
| POST | `/api/auth/register` | User registration |

### Menu Management
| Method | Endpoint | Usage |
|--------|----------|-------|
| GET | `/api/menu` | Load menu items |
| POST | `/api/menu` | Create menu item |
| PUT | `/api/menu/:id` | Update menu item |
| DELETE | `/api/menu/:id` | Delete menu item |

### Inventory Management
| Method | Endpoint | Usage |
|--------|----------|-------|
| GET | `/api/inventory` | Load inventory |
| POST | `/api/inventory` | Add inventory item |
| PUT | `/api/inventory/:id` | Update inventory |
| PATCH | `/api/inventory/:id/quantity` | Update quantity |

### Mobile Orders
| Method | Endpoint | Usage |
|--------|----------|-------|
| GET | `/api/v1/mobile-orders/orders` | Load orders with filters |
| GET | `/api/v1/mobile-orders/orders/:orderId` | Get order details |
| PUT | `/api/v1/mobile-orders/orders/:orderId/status` | Update order status |
| PUT | `/api/v1/mobile-orders/orders/:orderId/payment-status` | Update payment status |
| PUT | `/api/v1/mobile-orders/orders/:orderId/cancel` | Cancel order |

### Sales Management
| Method | Endpoint | Usage |
|--------|----------|-------|
| POST | `/api/sales/order` | Place new order |
| GET | `/api/sales` | Get sales data |
| GET | `/api/sales/range` | Get sales by date |

## 🛠️ Tech Stack

- **HTML5**: Structure and semantics
- **CSS3**: Styling and responsive design
- **JavaScript (ES6+)**: Interactivity and API calls
- **Bootstrap 5**: UI framework
- **Chart.js**: Data visualization
- **Socket.IO**: Real-time updates
- **SweetAlert2**: Notifications
- **DateRangePicker**: Date filtering

## 📄 License

MIT License 