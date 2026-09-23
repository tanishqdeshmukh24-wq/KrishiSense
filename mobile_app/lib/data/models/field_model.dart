class FieldModel {
  final String id;
  final String farmId;
  final String name;
  final List<String> zoneIds;

  const FieldModel({
    required this.id,
    required this.farmId,
    required this.name,
    required this.zoneIds,
  });
}