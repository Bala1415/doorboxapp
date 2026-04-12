import 'dart:async';
import 'dart:convert';
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
  static const String baseUrl = 'http://34.93.119.123:3000';

  final _boxUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get boxUpdateStream =>
      _boxUpdateController.stream;

  final _connectionStateController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  String? _currentHardwareId;

  SocketService() {
    _initSocket();
  }

  void _initSocket() {
    _socket = io.io(
        baseUrl,
        io.OptionBuilder()
            // Use pure websocket to avoid timeout issues during polling handshakes
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableReconnection()
            .build());

    // Explicitly connect to ensure it fires off immediately
    _socket.connect();

    _socket.onConnect((_) {
      debugPrint('Socket connected');
      if (_currentHardwareId != null) {
        _socket.emit('join-box', _currentHardwareId);
        debugPrint('Joined box: $_currentHardwareId');
      }
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

    _socket.onAny((event, data) {
      debugPrint('Socket received ANY event [$event]: $data');
      if (event != 'box-update' &&
          event != 'connect' &&
          event != 'disconnect') {
        // If the backend is using a different event name, let's catch it!
        if (data is Map || data is String) {
          try {
            final decoded = data is String ? jsonDecode(data) : data;
            if (decoded is Map) {
              _boxUpdateController.add(Map<String, dynamic>.from(decoded));
            }
          } catch (e) {
            debugPrint('Failed to process ANY event: $e');
          }
        }
      }
    });

    _socket.on('box-update', (data) {
      debugPrint('Received box-update: $data');
      if (data is Map) {
        _boxUpdateController.add(Map<String, dynamic>.from(data));
      } else if (data is String) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map) {
            _boxUpdateController.add(Map<String, dynamic>.from(decoded));
          }
        } catch (e) {
          debugPrint('Failed to decode box-update JSON string: $e');
        }
      }
    });
  }

  void connect(String hardwareId) {
    _currentHardwareId = hardwareId;
    if (!_socket.connected) {
      _socket.connect();
    } else {
      _socket.emit('join-box', _currentHardwareId);
      debugPrint('Joined box: $_currentHardwareId');
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
