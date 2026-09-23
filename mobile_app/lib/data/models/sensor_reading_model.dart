class SensorReadingModel {
  final String nodeId;
  final double soilMoisture;
  final double temperature;
  final double humidity;
  final double? rainfall;
  final DateTime timestamp;

  const SensorReadingModel({
    required this.nodeId,
    required this.soilMoisture,
    required this.temperature,
    required this.humidity,
    this.rainfall,
    required this.timestamp,
  });
}