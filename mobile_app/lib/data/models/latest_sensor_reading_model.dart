class LatestSensorReadingModel {
  final String nodeId;
  final double soilMoisture;
  final DateTime timestamp;

  const LatestSensorReadingModel({
    required this.nodeId,
    required this.soilMoisture,
    required this.timestamp,
  });
}
