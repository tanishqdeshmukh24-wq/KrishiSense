class ZoneModel {
  final String id;
  final String fieldId;
  final String name;
  final List<String> nodeIds;

  const ZoneModel({
    required this.id,
    required this.fieldId,
    required this.name,
    required this.nodeIds,
  });
}