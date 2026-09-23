import '../models/ai_result_model.dart';
import '../models/farm_model.dart';
import '../models/field_model.dart';
import '../models/node_model.dart';
import '../models/recommendation_model.dart';
import '../models/sensor_reading_model.dart';
import '../models/zone_model.dart';

abstract class FarmRepository {
  Future<FarmModel> getFarm();

  Future<List<FieldModel>> getFields(String farmId);

  Future<List<ZoneModel>> getZones(String fieldId);

  Future<List<NodeModel>> getNodes(String zoneId);

  Future<NodeModel?> getNode(String nodeId);

  Future<SensorReadingModel?> getLatestReading(String nodeId);

  Future<List<SensorReadingModel>> getReadingHistory(String nodeId);

  Future<List<RecommendationModel>> getRecommendations();

  Future<List<AiResultModel>> getAiResults();
}