import 'package:flutter/material.dart';
import '../services/websocket_service.dart';
import 'dart:convert';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
  });
}

class NotificationsProvider extends ChangeNotifier {
  final List<NotificationItem> _notifications = [];
  bool _hasUnread = false;
  WebSocketService? _ws;

  List<NotificationItem> get notifications => _notifications;
  bool get hasUnread => _hasUnread;

  void initWebSocket() {
    _ws = WebSocketService();
    _ws!.connect('http://localhost:3000'); // Socket.IO server URL
    _ws!.messageStream.listen((event) {
      final data = _parseEvent(event);
      if (data != null) {
        addNotification(data);
      }
    });
  }

  NotificationItem? _parseEvent(Map<String, dynamic> event) {
    try {
      if (event.containsKey('orderId') && event.containsKey('status')) {
        return NotificationItem(
          id: event['orderId'].toString(),
          title: 'Order Status Updated',
          message: 'Order #${event['orderId']} status: ${event['status']}',
          timestamp: DateTime.now(),
          imageUrl: 'assets/logo.png',
        );
      } else if (event.containsKey('orderId') && event.containsKey('items')) {
        return NotificationItem(
          id: event['orderId'].toString(),
          title: 'New Order Placed',
          message: 'Order #${event['orderId']} has been placed.',
          timestamp: DateTime.now(),
          imageUrl: 'assets/logo.png',
        );
      } else if (event['type'] == 'inventoryUpdated') {
        return NotificationItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Inventory Updated',
          message: 'Inventory item updated.',
          timestamp: DateTime.now(),
          imageUrl: 'assets/logo.png',
        );
      } else if (event.containsKey('salePlaced')) {
        return NotificationItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'New Sale',
          message: 'A new sale has been placed.',
          timestamp: DateTime.now(),
          imageUrl: 'assets/logo.png',
        );
      } else if (event['type'] == 'notification') {
        return NotificationItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: event['title'] ?? 'Notification',
          message: event['message'] ?? '',
          timestamp: DateTime.now(),
          imageUrl: 'assets/logo.png',
        );
      }
    } catch (e) {
      print('Error parsing notification event: $e');
    }
    return null;
  }

  void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    _hasUnread = true;
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = NotificationItem(
        id: _notifications[index].id,
        title: _notifications[index].title,
        message: _notifications[index].message,
        timestamp: _notifications[index].timestamp,
        isRead: true,
        imageUrl: _notifications[index].imageUrl,
      );
      _updateUnreadStatus();
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = NotificationItem(
          id: _notifications[i].id,
          title: _notifications[i].title,
          message: _notifications[i].message,
          timestamp: _notifications[i].timestamp,
          isRead: true,
          imageUrl: _notifications[i].imageUrl,
        );
      }
    }
    _updateUnreadStatus();
    notifyListeners();
  }

  void _updateUnreadStatus() {
    _hasUnread = _notifications.any((n) => !n.isRead);
  }

  // Subscribe to notifications for a specific user
  void subscribeToNotifications(String userId) {
    _ws?.subscribeToNotifications(userId);
  }

  // Dispose WebSocket connection
  @override
  void dispose() {
    _ws?.dispose();
    super.dispose();
  }

  // Add some sample notifications
  void addSampleNotifications() {
    addNotification(
      NotificationItem(
        id: '1',
        title: 'Order Confirmed',
        message: 'Your order #1234 has been confirmed and is being prepared.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        imageUrl: 'assets/logo.png',
      ),
    );
    addNotification(
      NotificationItem(
        id: '2',
        title: 'Special Offer',
        message: 'Get 20% off on your next order! Use code: RAMEN20',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        imageUrl: 'assets/logo.png',
      ),
    );
    addNotification(
      NotificationItem(
        id: '3',
        title: 'Order Delivered',
        message: 'Your order #1234 has been delivered. Enjoy your meal!',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        imageUrl: 'assets/logo.png',
      ),
    );
  }
} 