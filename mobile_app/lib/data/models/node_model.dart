class NodeModel {
  final String id;
  final String zoneId;
  final bool isOnline;
  final double soilMoisture;
  final double temperature;
  final double humidity;
  final DateTime lastUpdated;

  const NodeModel({
    required this.id,
    required this.zoneId,
    required this.isOnline,
    required this.soilMoisture,
    required this.temperature,
    required this.humidity,
    required this.lastUpdated,
  });
}