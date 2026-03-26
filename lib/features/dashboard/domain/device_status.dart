class DeviceStatus {
  final String name;
  final bool isOnline;
  final bool isLocked;
  final int wifiStrength;
  final int batteryLevel;
  final double temperature;
  final bool motionDetected;
  final String internalCameraUrl;
  final String externalCameraUrl;
  final String packageState;
  final DateTime? lastUpdated;
  final String? latestCameraImageBase64;

  const DeviceStatus({
    required this.name,
    required this.isOnline,
    required this.isLocked,
    required this.wifiStrength,
    required this.batteryLevel,
    required this.temperature,
    required this.motionDetected,
    required this.internalCameraUrl,
    required this.externalCameraUrl,
    required this.packageState,
    this.lastUpdated,
    this.latestCameraImageBase64,
  });

  DeviceStatus copyWith({
    String? name,
    bool? isOnline,
    bool? isLocked,
    int? wifiStrength,
    int? batteryLevel,
    double? temperature,
    bool? motionDetected,
    String? internalCameraUrl,
    String? externalCameraUrl,
    String? packageState,
    DateTime? lastUpdated,
    String? latestCameraImageBase64,
  }) {
    return DeviceStatus(
      name: name ?? this.name,
      isOnline: isOnline ?? this.isOnline,
      isLocked: isLocked ?? this.isLocked,
      wifiStrength: wifiStrength ?? this.wifiStrength,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      temperature: temperature ?? this.temperature,
      motionDetected: motionDetected ?? this.motionDetected,
      internalCameraUrl: internalCameraUrl ?? this.internalCameraUrl,
      externalCameraUrl: externalCameraUrl ?? this.externalCameraUrl,
      packageState: packageState ?? this.packageState,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      latestCameraImageBase64: latestCameraImageBase64 ?? this.latestCameraImageBase64,
    );
  }
}
