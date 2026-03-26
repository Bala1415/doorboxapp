import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  final service = SocketService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

class SocketService {
  late io.Socket _socket;
  // Updated with actual backend IP
  static const String baseUrl = 'http://34.47.214.219:3000';

  final _boxUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get boxUpdateStream => _boxUpdateController.stream;

  final _connectionStateController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  SocketService() {
    _initSocket();
  }

  void _initSocket() {
    _socket = io.io(baseUrl, io.OptionBuilder()
      // Allow fallback to polling if websockets are blocked by server/firewall
      .setTransports(['websocket', 'polling']) 
      .enableAutoConnect()
      .enableReconnection()
      .build());

    // Explicitly connect to ensure it fires off immediately
    _socket.connect();

    _socket.onConnect((_) {
      debugPrint('Socket connected');
      _connectionStateController.add(true);
    });

    _socket.onDisconnect((_) {
      debugPrint('Socket disconnected');
      _connectionStateController.add(false);
    });

    _socket.onConnectError((err) {
      debugPrint('Socket connect error: $err');
      _connectionStateController.add(false);
    });

    _socket.on('box-update', (data) {
      debugPrint('Received box-update: $data');
      if (data is Map<String, dynamic>) {
        _boxUpdateController.add(data);
      }
    });
  }

  void connect() {
    if (!_socket.connected) {
      _socket.connect();
    }
  }

  void disconnect() {
    if (_socket.connected) {
      _socket.disconnect();
    }
  }

  void dispose() {
    _socket.dispose();
    _boxUpdateController.close();
    _connectionStateController.close();
  }
}
