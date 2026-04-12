import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../../core/services/socket_service.dart';
import '../../../core/services/api_service.dart';
import '../domain/device_status.dart';

final deviceStatusProvider =
    StateNotifierProvider<DeviceStatusNotifier, DeviceStatus>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  final apiService = ref.watch(apiServiceProvider);
  return DeviceStatusNotifier(socketService, apiService);
});

class DeviceStatusNotifier extends StateNotifier<DeviceStatus> {
  final SocketService _socketService;
  final ApiService _apiService;

  DeviceStatusNotifier(this._socketService, this._apiService)
      : super(
          const DeviceStatus(
            name:
                "Front Porch Box", // This could come from a database/auth later
            isOnline: false,
            isLocked: true,
            wifiStrength: 0,
            batteryLevel: 0,
            temperature: 0.0, // Default mock value
            motionDetected: false,
            internalCameraUrl:
                "https://via.placeholder.com/600x400.png?text=Internal+Camera",
            externalCameraUrl:
                "https://via.placeholder.com/600x400.png?text=External+Camera",
            packageState: "Empty",
            lastUpdated: null,
            latestCameraImageBase64: null,
          ),
        ) {
    _initSocketListeners();
  }

  void _initSocketListeners() {
    _socketService.connectionStateStream.listen((isOnline) {
      if (mounted) {
        state = state.copyWith(isOnline: isOnline);
      }
    });

    _socketService.boxUpdateStream.listen((payload) {
      if (!mounted) return;

      // The backend wraps everything in a "data" property: { hardwareId, data: {...} }
      Map<String, dynamic> actualData = payload;
      if (payload['data'] != null) {
        if (payload['data'] is Map) {
          actualData = Map<String, dynamic>.from(payload['data']);
        } else if (payload['data'] is String) {
          try {
            final decoded = jsonDecode(payload['data']);
            if (decoded is Map) {
              actualData = Map<String, dynamic>.from(decoded);
            }
          } catch (e) {
            // keep actualData as payload
          }
        }
      }

      var hwMsgRaw = actualData['hardwaremessage'];
      if (hwMsgRaw is String) {
        try {
          var decodedHwMsg = jsonDecode(hwMsgRaw);
          if (decodedHwMsg is Map) {
            hwMsgRaw = decodedHwMsg;
          }
        } catch (_) {}
      }

      Map<String, dynamic>? hwMsg;
      if (hwMsgRaw is Map) {
        hwMsg = Map<String, dynamic>.from(hwMsgRaw);
      }

      final photovideo = actualData['photovideo'] as String?;

      int parseIntSafe(dynamic value, int fallback) {
        if (value is num) return value.toInt();
        if (value is String) {
          final s = value.replaceAll(RegExp(r'[^0-9]'), '');
          return int.tryParse(s) ?? fallback;
        }
        return fallback;
      }

      double parseDoubleSafe(dynamic value, double fallback) {
        if (value is num) return value.toDouble();
        if (value is String) {
          final s = value.replaceAll(RegExp(r'[^0-9.]'), '');
          return double.tryParse(s) ?? fallback;
        }
        return fallback;
      }

      if (hwMsg != null) {
        final rawLock = hwMsg['boxstate'];
        final isLocked = !(rawLock == '1' || rawLock == 1);
        
        int wifiStrength = state.wifiStrength;
        final wifiRaw = hwMsg['wifi'];

        if (wifiRaw is String) {
          final wifiLower = wifiRaw.toLowerCase();
          if (wifiLower == "strong") {
            wifiStrength = 100;
          } else if (wifiLower == "medium") {
            wifiStrength = 60;
          } else if (wifiLower == "weak") {
            wifiStrength = 30;
          } else {
            wifiStrength = parseIntSafe(wifiRaw, state.wifiStrength);
          }
        } else if (wifiRaw != null) {
          wifiStrength = parseIntSafe(wifiRaw, state.wifiStrength);
        }

        final packageRaw = hwMsg['package'];
        final packageText = (packageRaw?.toString() == "1") ? "Delivered" : "Empty";

        state = state.copyWith(
          batteryLevel: parseIntSafe(hwMsg['battery'], state.batteryLevel),
          wifiStrength: wifiStrength,
          isLocked: isLocked,
          packageState: packageText,
          temperature: parseDoubleSafe(hwMsg['temperature'], state.temperature),
          lastUpdated: DateTime.now(),
        );
      }

      if (photovideo != null && photovideo.isNotEmpty) {
        state = state.copyWith(latestCameraImageBase64: photovideo);
      }
    });
  }

  Future<bool> unlockBox(String hardwareId) async {
    // Optionally trigger a loading state if we want to add `isUnlocking` to DeviceStatus
    final success = await _apiService.unlockBox(hardwareId);
    return success;
  }
}
