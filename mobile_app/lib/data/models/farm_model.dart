class FarmModel {
  final String id;
  final String name;
  final String location;
  final List<String> fieldIds;

  const FarmModel({
    required this.id,
    required this.name,
    required this.location,
    required this.fieldIds,
  });
}