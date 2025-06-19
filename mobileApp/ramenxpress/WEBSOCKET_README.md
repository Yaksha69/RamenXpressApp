# WebSocket Service Documentation

## Overview

The WebSocket service provides real-time communication between the Flutter app and the backend server using Socket.IO. This enables instant updates for order status changes and notifications.

## Features

- **Real-time Order Updates**: Receive instant notifications when order status changes
- **Real-time Notifications**: Get push notifications for various events
- **Automatic Reconnection**: Handles connection drops and reconnects automatically
- **Room-based Messaging**: Support for user-specific notifications

## Setup

### Backend Requirements

The backend server must have Socket.IO configured and running. The server should emit the following events:

- `orderStatusUpdated` - When order status changes
- `inventoryUpdated` - When inventory is updated
- `salePlaced` - When a new sale is placed
- `notification` - For general notifications

### Flutter App Setup

1. **Dependencies**: The `socket_io_client` package is already included in `pubspec.yaml`

2. **Service Initialization**: The WebSocket service is automatically initialized when a user logs in (see `main.dart`)

## Usage

### Basic Usage

```dart
// The service is automatically initialized in main.dart when user logs in
// No manual initialization needed
```

### Manual Initialization (if needed)

```dart
final notificationsProvider = Provider.of<NotificationsProvider>(context, listen: false);
notificationsProvider.initWebSocket();
notificationsProvider.subscribeToNotifications(userId);

final orderHistoryProvider = Provider.of<OrderHistoryProvider>(context, listen: false);
orderHistoryProvider.initWebSocket();
orderHistoryProvider.subscribeToOrders(userId);
```

### Listening to Events

The providers automatically listen to WebSocket events and update the UI accordingly:

- **NotificationsProvider**: Listens for order updates and notifications
- **OrderHistoryProvider**: Listens for order status changes and new orders

### Sending Events

```dart
// Send order update
websocketService.sendOrderUpdate('123', 'preparing');

// Send notification
websocketService.sendNotification('Order Ready', 'Your order is ready for pickup', userId: 'user123');

// Join user-specific room
websocketService.joinRoom('user_123');
```

## Event Types

### Order Status Updates
```json
{
  "type": "order_update",
  "orderId": "123",
  "status": "preparing"
}
```

### Inventory Updates
```json
{
  "type": "inventoryUpdated",
  "data": {
    "type": "update",
    "item": { ... }
  }
}
```

### Notifications
```json
{
  "type": "notification",
  "title": "Order Ready",
  "message": "Your order is ready for pickup",
  "userId": "user123"
}
```

## Configuration

### Connection URL

Update the connection URL in the providers if your backend runs on a different port:

```dart
// In notifications_provider.dart and order_history_provider.dart
_ws!.connect('http://localhost:3000'); // Change to your backend URL
```

### Authentication

To add authentication to WebSocket connections, update the auth token in `websocket_service.dart`:

```dart
'auth': {
  'token': 'your-actual-auth-token'
}
```

## Error Handling

The service includes automatic error handling:

- Connection errors are logged and reported
- Automatic reconnection attempts
- Graceful disconnection handling

## Testing

To test the WebSocket functionality:

1. Start your backend server
2. Run the Flutter app
3. Log in with a user account
4. The WebSocket connection will be established automatically
5. Test by updating order status in the backend admin panel

## Troubleshooting

### Connection Issues

1. **Check Backend**: Ensure the backend server is running and Socket.IO is configured
2. **Check URL**: Verify the connection URL matches your backend
3. **Check CORS**: Ensure CORS is properly configured on the backend
4. **Check Network**: Verify network connectivity

### Event Not Received

1. **Check Event Names**: Ensure event names match between frontend and backend
2. **Check Data Format**: Verify the data structure matches expected format
3. **Check Room Membership**: For user-specific events, ensure the user has joined the correct room

## Backend Integration

The backend should emit events using Socket.IO:

```javascript
// Example backend code
io.emit('orderStatusUpdated', { orderId: '123', status: 'preparing' });
io.emit('notification', { title: 'Order Ready', message: 'Your order is ready', userId: 'user123' });
```

## Security Considerations

- Use authentication tokens for WebSocket connections
- Validate all incoming messages
- Implement rate limiting if needed
- Use HTTPS/WSS in production 