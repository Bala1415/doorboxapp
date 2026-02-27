enum ActivityType { delivered, motion, unlocked, battery, update }

class ActivityLog {
  final String id;
  final ActivityType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final bool hasImage;

  const ActivityLog({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.hasImage = false,
  });
}
