import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

class WebSocketService {
  socket_io.Socket? _socket;
  StreamController<Map<String, dynamic>>? _messageController;
  StreamController<String>? _connectionStatusController;
  
  // Streams for external listeners
  Stream<Map<String, dynamic>> get messageStream => 
      _messageController?.stream ?? Stream.empty();
  Stream<String> get connectionStatusStream => 
      _connectionStatusController?.stream ?? Stream.empty();

  // Connection status
  bool get isConnected => _socket?.connected ?? false;

  WebSocketService() {
    _messageController = StreamController<Map<String, dynamic>>.broadcast();
    _connectionStatusController = StreamController<String>.broadcast();
  }

  /// Connect to Socket.IO server
  Future<void> connect(String url) async {
    try {
      if (isConnected) {
        print('Socket.IO already connected');
        return;
      }

      _socket = socket_io.io(url, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
        'auth': {
          'token': 'your-auth-token-here' // Add authentication if needed
        }
      });

      _socket!.onConnect((_) {
        print('Socket.IO connected');
        _connectionStatusController?.add('connected');
      });

      _socket!.onDisconnect((_) {
        print('Socket.IO disconnected');
        _connectionStatusController?.add('disconnected');
      });

      _socket!.onConnectError((error) {
        print('Socket.IO connection error: $error');
        _connectionStatusController?.add('error');
      });

      // Listen for all events and forward them to the message stream
      _socket!.onAny((event, data) {
        try {
          Map<String, dynamic> message = {
            'event': event,
            'data': data,
          };
          _messageController?.add(message);
        } catch (e) {
          print('Error processing Socket.IO message: $e');
        }
      });

      // Listen for specific events
      _socket!.on('orderStatusUpdated', (data) {
        _messageController?.add({
          'type': 'order_update',
          'orderId': data['orderId'],
          'status': data['status'],
        });
      });

      _socket!.on('inventoryUpdated', (data) {
        _messageController?.add({
          'type': 'inventoryUpdated',
          'data': data,
        });
      });

      _socket!.on('salePlaced', (data) {
        _messageController?.add({
          'type': 'salePlaced',
          'data': data,
        });
      });

      _socket!.on('notification', (data) {
        _messageController?.add({
          'type': 'notification',
          'title': data['title'],
          'message': data['message'],
          'userId': data['userId'],
        });
      });

    } catch (e) {
      print('Failed to connect to Socket.IO: $e');
      _connectionStatusController?.add('error');
    }
  }

  /// Send message to Socket.IO server
  void send(String event, Map<String, dynamic> data) {
    if (isConnected) {
      _socket!.emit(event, data);
    } else {
      print('Socket.IO not connected');
    }
  }

  /// Send order update
  void sendOrderUpdate(String orderId, String status) {
    send('orderStatusUpdated', {
      'orderId': orderId,
      'status': status,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Send notification
  void sendNotification(String title, String message, {String? userId}) {
    send('notification', {
      'title': title,
      'message': message,
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Subscribe to order updates
  void subscribeToOrders(String userId) {
    send('subscribe', {
      'channel': 'orders',
      'userId': userId,
    });
  }

  /// Subscribe to notifications
  void subscribeToNotifications(String userId) {
    send('subscribe', {
      'channel': 'notifications',
      'userId': userId,
    });
  }

  /// Join a room (for specific user notifications)
  void joinRoom(String roomName) {
    if (isConnected) {
      _socket!.emit('join', roomName);
    }
  }

  /// Leave a room
  void leaveRoom(String roomName) {
    if (isConnected) {
      _socket!.emit('leave', roomName);
    }
  }

  /// Disconnect from Socket.IO server
  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _connectionStatusController?.add('disconnected');
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _messageController?.close();
    _connectionStatusController?.close();
  }
} 