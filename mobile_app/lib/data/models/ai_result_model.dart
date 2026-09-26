class AiResultModel {
  final String prediction;
  final double confidence;
  final String explanation;
  final String recommendation;
  final DateTime timestamp;

  const AiResultModel({
    required this.prediction,
    required this.confidence,
    required this.explanation,
    required this.recommendation,
    required this.timestamp,
  });
}