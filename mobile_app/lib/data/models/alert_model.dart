class AlertModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String severity;
  final DateTime timestamp;
  final bool isRead;

  const AlertModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.severity,
    required this.timestamp,
    required this.isRead,
  });
}