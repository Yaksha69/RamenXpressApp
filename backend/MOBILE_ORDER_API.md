# Mobile Order Management API

This document describes the API endpoints for managing customer orders from the mobile app. These endpoints are designed for cashiers and administrators to handle order processing, status updates, and order management.

## Base URL
```
http://localhost:3000/api/v1/mobile-orders
```

## Authentication
All endpoints require authentication with a cashier or admin token. Include the token in the Authorization header:
```
Authorization: Bearer <your-token>
```

## Endpoints

### 1. Get All Orders
Retrieve all orders with optional filtering and pagination.

**Endpoint:** `GET /orders`

**Query Parameters:**
- `startDate` (optional): Start date for filtering (YYYY-MM-DD)
- `endDate` (optional): End date for filtering (YYYY-MM-DD)
- `status` (optional): Filter by order status
- `paymentMethod` (optional): Filter by payment method
- `page` (optional): Page number for pagination (default: 1)
- `limit` (optional): Number of orders per page (default: 10)

**Example Request:**
```bash
GET /api/v1/mobile-orders/orders?status=pending&page=1&limit=10
```

**Response:**
```json
{
  "success": true,
  "orders": [
    {
      "orderId": 1001,
      "customerId": {
        "_id": "507f1f77bcf86cd799439011",
        "firstName": "John",
        "lastName": "Doe",
        "email": "john@example.com",
        "phoneNumber": "+1234567890"
      },
      "items": [
        {
          "name": "Shoyu Ramen",
          "price": 299.99,
          "quantity": 2,
          "total": 599.98,
          "addOns": []
        }
      ],
      "total": 649.98,
      "orderType": "delivery",
      "paymentMethod": "gcash",
      "paymentStatus": "Pending",
      "deliveryAddress": {
        "street": "123 Main St",
        "city": "Manila",
        "state": "Metro Manila",
        "zipCode": "1000",
        "country": "Philippines"
      },
      "deliveryFee": 50,
      "status": "pending",
      "notes": "Extra spicy please",
      "orderDate": "2024-01-15T10:30:00.000Z"
    }
  ],
  "pagination": {
    "currentPage": 1,
    "totalPages": 5,
    "totalOrders": 50,
    "hasNextPage": true,
    "hasPrevPage": false
  }
}
```

### 2. Get Order Details
Retrieve detailed information about a specific order.

**Endpoint:** `GET /orders/:orderId`

**Example Request:**
```bash
GET /api/v1/mobile-orders/orders/1001
```

**Response:**
```json
{
  "success": true,
  "order": {
    "orderId": 1001,
    "customerId": {
      "_id": "507f1f77bcf86cd799439011",
      "firstName": "John",
      "lastName": "Doe",
      "email": "john@example.com",
      "phoneNumber": "+1234567890"
    },
    "items": [...],
    "total": 649.98,
    "orderType": "delivery",
    "paymentMethod": "gcash",
    "paymentStatus": "Pending",
    "deliveryAddress": {...},
    "deliveryFee": 50,
    "status": "pending",
    "notes": "Extra spicy please",
    "orderDate": "2024-01-15T10:30:00.000Z"
  }
}
```

### 3. Update Order Status
Update the delivery status of an order.

**Endpoint:** `PUT /orders/:orderId/status`

**Request Body:**
```json
{
  "status": "confirmed"
}
```

**Valid Status Values:**
- `pending`
- `confirmed`
- `preparing`
- `ready`
- `delivered`
- `cancelled`

**Example Request:**
```bash
PUT /api/v1/mobile-orders/orders/1001/status
Content-Type: application/json

{
  "status": "confirmed"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Order status updated successfully",
  "order": {
    "orderId": 1001,
    "status": "confirmed",
    ...
  }
}
```

### 4. Update Payment Status
Update the payment status of an order.

**Endpoint:** `PUT /orders/:orderId/payment-status`

**Request Body:**
```json
{
  "paymentStatus": "Paid"
}
```

**Valid Payment Status Values:**
- `Paid`
- `Pending`
- `Refunded`
- `Failed`

**Example Request:**
```bash
PUT /api/v1/mobile-orders/orders/1001/payment-status
Content-Type: application/json

{
  "paymentStatus": "Paid"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Payment status updated successfully",
  "order": {
    "orderId": 1001,
    "paymentStatus": "Paid",
    ...
  }
}
```

### 5. Cancel Order
Cancel an order with an optional reason.

**Endpoint:** `PUT /orders/:orderId/cancel`

**Request Body:**
```json
{
  "reason": "Out of stock"
}
```

**Example Request:**
```bash
PUT /api/v1/mobile-orders/orders/1001/cancel
Content-Type: application/json

{
  "reason": "Out of stock"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Order cancelled successfully",
  "order": {
    "orderId": 1001,
    "status": "cancelled",
    "cancellationReason": "Out of stock",
    "cancelledAt": "2024-01-15T11:00:00.000Z",
    ...
  }
}
```

### 6. Get Order Statistics
Retrieve order statistics for dashboard display.

**Endpoint:** `GET /statistics`

**Query Parameters:**
- `startDate` (optional): Start date for filtering (YYYY-MM-DD)
- `endDate` (optional): End date for filtering (YYYY-MM-DD)

**Example Request:**
```bash
GET /api/v1/mobile-orders/statistics?startDate=2024-01-01&endDate=2024-01-31
```

**Response:**
```json
{
  "success": true,
  "statistics": {
    "totalOrders": 150,
    "statusBreakdown": {
      "pending": 25,
      "confirmed": 30,
      "preparing": 20,
      "ready": 15,
      "delivered": 55,
      "cancelled": 5
    },
    "paymentBreakdown": {
      "gcash": 80,
      "paymaya": 45,
      "cash": 25
    },
    "revenue": {
      "totalRevenue": 45000.50,
      "averageOrderValue": 300.00
    }
  }
}
```

## Error Responses

All endpoints return error responses in the following format:

```json
{
  "success": false,
  "message": "Error description",
  "error": "Detailed error message"
}
```

**Common HTTP Status Codes:**
- `200`: Success
- `400`: Bad Request (invalid parameters)
- `401`: Unauthorized (missing or invalid token)
- `403`: Forbidden (insufficient permissions)
- `404`: Not Found (order not found)
- `500`: Internal Server Error

## WebSocket Events

The API also emits WebSocket events for real-time updates:

- `orderStatusUpdated`: When order status is updated
- `paymentStatusUpdated`: When payment status is updated
- `orderCancelled`: When an order is cancelled

## Testing

Use the provided test script to verify the endpoints:

```bash
node test_mobile_order_endpoints.js
```

Make sure to:
1. Start the server
2. Have a cashier account in the database
3. Have some test orders in the database

## Frontend Integration

The frontend JavaScript file (`mobileOrder.js`) has been updated to integrate with these endpoints. Key features:

- Real-time order loading with pagination
- Filtering by date range, status, and payment method
- Order status and payment status updates
- Order cancellation with reason
- Error handling and user feedback
- Loading states and empty states

## Security Notes

- All endpoints require cashier or admin authentication
- Orders can only be accessed and modified by authorized personnel
- Cancellation is restricted to orders that haven't been delivered
- All actions are logged and can be audited 