import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/dashboard/domain/device_status.dart';
import '../../features/activity/domain/activity_log.dart';
import '../../features/settings/domain/box_settings.dart';

// Dashboard / Device Status Provider
final deviceStatusProvider = StateProvider<DeviceStatus>((ref) {
  return const DeviceStatus(
    name: "Front Porch Box",
    isOnline: true,
    isLocked: true,
    wifiStrength: 75,
    batteryLevel: 85,
    temperature: 83.3,
    motionDetected: false,
    internalCameraUrl: "https://via.placeholder.com/600x400.png?text=Internal+Camera",
    externalCameraUrl: "https://via.placeholder.com/600x400.png?text=External+Camera",
  );
});

// Activity Logs Provider
final activityLogsProvider = Provider<List<ActivityLog>>((ref) {
  return [
    ActivityLog(
      id: "1",
      type: ActivityType.delivered,
      title: "Parcel Delivered",
      description: "Amazon package delivered to DoorBox.",
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      hasImage: true,
    ),
    ActivityLog(
      id: "2",
      type: ActivityType.motion,
      title: "Motion Detected",
      description: "Movement detected outside DoorBox.",
      timestamp: DateTime.now().subtract(const Duration(hours: 24)),
    ),
    ActivityLog(
      id: "3",
      type: ActivityType.unlocked,
      title: "Box Unlocked",
      description: "Unlocked by Kumar via App.",
      timestamp: DateTime.now().subtract(const Duration(hours: 26)),
    ),
    ActivityLog(
      id: "4",
      type: ActivityType.battery,
      title: "Battery Low",
      description: "DoorBox battery below 15%.",
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ActivityLog(
      id: "5",
      type: ActivityType.update,
      title: "System Update",
      description: "DoorBox firmware updated successfully.",
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];
});

// Settings Provider
final settingsProvider = StateProvider<BoxSettings>((ref) {
  return const BoxSettings(
    alarmEnabled: true,
    motionDetectionEnabled: false,
  );
});
