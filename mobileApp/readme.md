# RamenXpress Mobile App

Flutter mobile application for the RamenXpress restaurant.

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (v3.0+)
- Dart SDK (v3.0+)
- Backend API server running

### Installation

1. **Install Flutter**
   ```bash
   # Download from https://flutter.dev/docs/get-started/install
   flutter doctor
   ```

2. **Setup project**
   ```bash
   cd mobileApp/ramenxpress
   flutter pub get
   ```

3. **Run app**
   ```bash
   flutter run
   ```

## 📱 Features

### Authentication
- User login and registration
- Profile management
- Password reset
- Auto-login with JWT

### Menu & Ordering
- Browse menu by categories
- Search menu items
- Add items to cart
- Order customization with add-ons
- Real-time order tracking

### Payment & Delivery
- Multiple payment methods (GCash, PayMaya, COD)
- Address management
- Delivery tracking
- Order history and reordering

### Real-time Features
- Live order status updates
- Push notifications
- Socket.IO integration
- Payment confirmations

## 📡 API Integration

### Authentication
| Method | Endpoint | Usage |
|--------|----------|-------|
| POST | `/api/auth/login` | User login |
| POST | `/api/auth/register` | User registration |

### Menu
| Method | Endpoint | Usage |
|--------|----------|-------|
| GET | `/api/menu` | Load menu items |
| GET | `/api/menu/category/:category` | Get menu by category |

### Orders
| Method | Endpoint | Usage |
|--------|----------|-------|
| POST | `/api/v1/mobile-orders/orders` | Place new order |
| GET | `/api/v1/mobile-orders/orders/:orderId` | Get order details |
| GET | `/api/v1/mobile-orders/orders` | Get user orders |

### Customer Management
| Method | Endpoint | Usage |
|--------|----------|-------|
| GET | `/api/customers/profile` | Get user profile |
| PUT | `/api/customers/profile` | Update profile |
| POST | `/api/customers/addresses` | Add delivery address |
| GET | `/api/customers/addresses` | Get user addresses |

### Payment Methods
| Method | Endpoint | Usage |
|--------|----------|-------|
| GET | `/api/payment-methods` | Get payment methods |
| POST | `/api/customers/payment-methods` | Add payment method |

## 🛠️ Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Provider pattern
- **HTTP Client**: Dio
- **Real-time**: Socket.IO
- **Local Storage**: SharedPreferences
- **UI**: Material Design 3

## 📄 License

MIT License 