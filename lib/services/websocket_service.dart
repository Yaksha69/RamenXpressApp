import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;

  void connect(String url) {
    if (_channel != null) return;
    _channel = WebSocketChannel.connect(Uri.parse(url));
  }

  void disconnect() {
    _channel?.sink.close(status.goingAway);
    _channel = null;
  }

  Stream? get stream => _channel?.stream;

  void send(dynamic data) {
    _channel?.sink.add(data);
  }
} 