class DecisionResultModel {
  final String decision;
  final String priority;
  final String reason;

  const DecisionResultModel({
    required this.decision,
    required this.priority,
    required this.reason,
  });

  factory DecisionResultModel.fromJson(Map<String, dynamic> json) {
    return DecisionResultModel(
      decision: json['decision'] as String,
      priority: json['priority'] as String,
      reason: json['reason'] as String,
    );
  }
}
