import '../models/ai_result_model.dart';
import '../models/farm_model.dart';
import '../models/field_model.dart';
import '../models/node_model.dart';
import '../models/recommendation_model.dart';
import '../models/sensor_reading_model.dart';
import '../models/zone_model.dart';
import 'farm_repository.dart';

class MockFarmRepository implements FarmRepository {
  static final DateTime _now = DateTime.now();

  final FarmModel _farm = FarmModel(
    id: 'farm_001',
    name: 'Prototype Farm',
    location: 'Demo Location',
    fieldIds: ['field_001', 'field_002'],
  );

  final List<FieldModel> _fields = [
    const FieldModel(
      id: 'field_001',
      farmId: 'farm_001',
      name: 'Field 01',
      zoneIds: ['zone_a1', 'zone_a2'],
    ),
    const FieldModel(
      id: 'field_002',
      farmId: 'farm_001',
      name: 'Field 02',
      zoneIds: ['zone_b1'],
    ),
  ];

  final List<ZoneModel> _zones = [
    const ZoneModel(
      id: 'zone_a1',
      fieldId: 'field_001',
      name: 'Zone A1',
      nodeIds: ['NODE_001', 'NODE_002'],
    ),
    const ZoneModel(
      id: 'zone_a2',
      fieldId: 'field_001',
      name: 'Zone A2',
      nodeIds: ['NODE_003'],
    ),
    const ZoneModel(
      id: 'zone_b1',
      fieldId: 'field_002',
      name: 'Zone B1',
      nodeIds: ['NODE_004'],
    ),
  ];

  final List<NodeModel> _nodes = [
    NodeModel(
      id: 'NODE_001',
      zoneId: 'zone_a1',
      isOnline: true,
      soilMoisture: 68,
      temperature: 27,
      humidity: 64,
      lastUpdated: _now,
    ),
    NodeModel(
      id: 'NODE_002',
      zoneId: 'zone_a1',
      isOnline: true,
      soilMoisture: 61,
      temperature: 28,
      humidity: 62,
      lastUpdated: _now,
    ),
    NodeModel(
      id: 'NODE_003',
      zoneId: 'zone_a2',
      isOnline: false,
      soilMoisture: 31,
      temperature: 29,
      humidity: 58,
      lastUpdated: _now.subtract(const Duration(minutes: 18)),
    ),
    NodeModel(
      id: 'NODE_004',
      zoneId: 'zone_b1',
      isOnline: true,
      soilMoisture: 72,
      temperature: 26,
      humidity: 67,
      lastUpdated: _now,
    ),
  ];

  final List<RecommendationModel> _recommendations = [
    RecommendationModel(
      id: 'rec_001',
      zoneId: 'zone_a1',
      title: 'Soil Moisture Optimal',
      message: 'Current soil moisture is within the optimal range.',
      action: 'No Irrigation Required',
      timestamp: _now,
    ),
  ];

  final List<AiResultModel> _aiResults = [
    AiResultModel(
      prediction: 'Early Blight',
      confidence: 0.87,
      explanation: 'The image shows symptoms that may be consistent with early blight.',
      recommendation: 'Inspect affected leaves and follow the recommended crop-care action.',
      timestamp: _now,
    ),
  ];

  @override
  Future<FarmModel> getFarm() async {
    return _farm;
  }

  @override
  Future<List<FieldModel>> getFields(String farmId) async {
    return _fields.where((field) => field.farmId == farmId).toList();
  }

  @override
  Future<List<ZoneModel>> getZones(String fieldId) async {
    return _zones.where((zone) => zone.fieldId == fieldId).toList();
  }

  @override
  Future<List<NodeModel>> getNodes(String zoneId) async {
    return _nodes.where((node) => node.zoneId == zoneId).toList();
  }

  @override
  Future<NodeModel?> getNode(String nodeId) async {
    for (final node in _nodes) {
      if (node.id == nodeId) {
        return node;
      }
    }

    return null;
  }

  @override
  Future<SensorReadingModel?> getLatestReading(String nodeId) async {
    final node = await getNode(nodeId);

    if (node == null) {
      return null;
    }

    return SensorReadingModel(
      nodeId: node.id,
      soilMoisture: node.soilMoisture,
      temperature: node.temperature,
      humidity: node.humidity,
      rainfall: null,
      timestamp: node.lastUpdated,
    );
  }

  @override
  Future<List<SensorReadingModel>> getReadingHistory(String nodeId) async {
    final latest = await getLatestReading(nodeId);

    if (latest == null) {
      return [];
    }

    return [latest];
  }

  @override
  Future<List<RecommendationModel>> getRecommendations() async {
    return _recommendations;
  }

  @override
  Future<List<AiResultModel>> getAiResults() async {
    return _aiResults;
  }
}