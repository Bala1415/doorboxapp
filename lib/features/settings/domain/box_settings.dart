class BoxSettings {
  final bool alarmEnabled;
  final bool motionDetectionEnabled;

  const BoxSettings({
    required this.alarmEnabled,
    required this.motionDetectionEnabled,
  });

  BoxSettings copyWith({
    bool? alarmEnabled,
    bool? motionDetectionEnabled,
  }) {
    return BoxSettings(
      alarmEnabled: alarmEnabled ?? this.alarmEnabled,
      motionDetectionEnabled: motionDetectionEnabled ?? this.motionDetectionEnabled,
    );
  }
}
