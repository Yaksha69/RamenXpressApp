import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;
  String? _customerId;

  // Callbacks for different events
  Function(Map<String, dynamic>)? onOrderPlaced;
  Function(Map<String, dynamic>)? onOrderStatusUpdated;
  Function()? onConnected;
  Function()? onDisconnected;
  Function(String)? onError;

  bool get isConnected => _isConnected;

  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000'; // For web browser
    } else {
      return 'http://10.0.2.2:3000'; // For Android emulator
    }
  }

  void initialize(String baseUrl, {String? customerId}) {
    _customerId = customerId;
    
    _socket = IO.io(_baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'forceNew': true,
    });

    _setupEventListeners();
  }

  void _setupEventListeners() {
    _socket?.onConnect((_) {
      _isConnected = true;
      if (kDebugMode) {
        print('🔌 WebSocket connected');
      }
      onConnected?.call();

      // Join customer room if customerId is provided
      if (_customerId != null) {
        _socket?.emit('join-customer', _customerId);
        if (kDebugMode) {
          print('👤 Joined customer room: $_customerId');
        }
      }
    });

    _socket?.onDisconnect((_) {
      _isConnected = false;
      if (kDebugMode) {
        print('🔌 WebSocket disconnected');
      }
      onDisconnected?.call();
    });

    _socket?.onConnectError((error) {
      _isConnected = false;
      if (kDebugMode) {
        print('❌ WebSocket connection error: $error');
      }
      onError?.call(error.toString());
    });

    _socket?.on('orderPlaced', (data) {
      if (kDebugMode) {
        print('📦 New order placed: $data');
      }
      if (data is Map<String, dynamic>) {
        onOrderPlaced?.call(data);
      }
    });

    _socket?.on('orderStatusUpdated', (data) {
      if (kDebugMode) {
        print('🔄 Order status updated: $data');
      }
      if (data is Map<String, dynamic>) {
        onOrderStatusUpdated?.call(data);
      }
    });

    _socket?.on('salePlaced', (data) {
      if (kDebugMode) {
        print('💰 New sale placed: $data');
      }
      // Handle sale placed event if needed
    });
  }

  void connect() {
    if (_socket != null && !_isConnected) {
      _socket!.connect();
    }
  }

  void disconnect() {
    if (_socket != null && _isConnected) {
      _socket!.disconnect();
    }
  }

  void joinCustomerRoom(String customerId) {
    _customerId = customerId;
    if (_socket != null && _isConnected) {
      _socket!.emit('join-customer', customerId);
      if (kDebugMode) {
        print('👤 Joined customer room: $customerId');
      }
    }
  }

  void joinAdminRoom() {
    if (_socket != null && _isConnected) {
      _socket!.emit('join-admin');
      if (kDebugMode) {
        print('👨‍💼 Joined admin room');
      }
    }
  }

  void updateOrderStatus(String orderId, String status, {String? customerId}) {
    if (_socket != null && _isConnected) {
      final data = {
        'orderId': orderId,
        'status': status,
        if (customerId != null) 'customerId': customerId,
      };
      _socket!.emit('update-order-status', data);
      if (kDebugMode) {
        print('🔄 Emitting order status update: $data');
      }
    }
  }

  void dispose() {
    disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }
} 