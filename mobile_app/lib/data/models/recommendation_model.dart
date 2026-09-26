class RecommendationModel {
  final String id;
  final String zoneId;
  final String title;
  final String message;
  final String action;
  final DateTime timestamp;

  const RecommendationModel({
    required this.id,
    required this.zoneId,
    required this.title,
    required this.message,
    required this.action,
    required this.timestamp,
  });
}