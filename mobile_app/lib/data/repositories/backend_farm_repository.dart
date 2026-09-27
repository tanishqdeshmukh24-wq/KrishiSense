import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/ai_result_model.dart';
import '../models/farm_model.dart';
import '../models/field_model.dart';
import '../models/node_model.dart';
import '../models/recommendation_model.dart';
import '../models/sensor_reading_model.dart';
import '../models/zone_model.dart';
import '../services/auth_service.dart';
import 'farm_repository.dart';

class BackendFarmRepository implements FarmRepository {
  BackendFarmRepository({
    String? baseUrl,
    String? accessToken,
  })  : baseUrl = baseUrl ?? AuthService.baseUrl,
        accessToken = accessToken ?? AuthService.accessToken ?? '';

  final String baseUrl;
  final String accessToken;

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

  Future<dynamic> _get(String path) async {
    if (accessToken.isEmpty) {
      throw const ApiException(401, 'Authentication required.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );

    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail =
          decoded is Map<String, dynamic> ? decoded['detail'] : null;
      throw ApiException(
        response.statusCode,
        detail?.toString() ?? 'Request failed (${response.statusCode}).',
      );
    }

    return decoded;
  }

  @override
  Future<FarmModel> getFarm() async {
    final farms = (await _get('/farms')) as List<dynamic>;

    if (farms.isEmpty) {
      throw StateError('No farm is associated with this account.');
    }

    final farm = farms.first as Map<String, dynamic>;
    final fields = await getFields(farm['id'].toString());

    return FarmModel(
      id: farm['id'].toString(),
      name: farm['name'].toString(),
      location: farm['location']?.toString() ?? 'Unknown location',
      fieldIds: fields.map((field) => field.id).toList(),
    );
  }

  @override
  Future<List<FieldModel>> getFields(String farmId) async {
    final fields = (await _get('/farms/$farmId/fields')) as List<dynamic>;

    final result = <FieldModel>[];
    for (final item in fields) {
      final field = item as Map<String, dynamic>;
      final zones = await getZones(field['id'].toString());

      result.add(
        FieldModel(
          id: field['id'].toString(),
          farmId: field['farm_id'].toString(),
          name: field['name'].toString(),
          zoneIds: zones.map((zone) => zone.id).toList(),
        ),
      );
    }

    return result;
  }

  @override
  Future<List<ZoneModel>> getZones(String fieldId) async {
    final farms = (await _get('/farms')) as List<dynamic>;
    if (farms.isEmpty) {
      throw StateError('No farm is associated with this account.');
    }

    final farmId = (farms.first as Map<String, dynamic>)['id'].toString();

    final zones = (await _get(
      '/farms/$farmId/fields/$fieldId/zones',
    )) as List<dynamic>;

    final result = <ZoneModel>[];
    for (final item in zones) {
      final zone = item as Map<String, dynamic>;
      final nodes = (await _get(
        '/nodes?zone_id=${zone['id']}',
      )) as List<dynamic>;

      result.add(
        ZoneModel(
          id: zone['id'].toString(),
          fieldId: zone['field_id'].toString(),
          name: zone['name'].toString(),
          nodeIds: nodes
              .map(
                (node) =>
                    (node as Map<String, dynamic>)['node_id'].toString(),
              )
              .toList(),
        ),
      );
    }

    return result;
  }

  @override
  Future<List<NodeModel>> getNodes(String zoneId) =>
      throw UnsupportedError(
        'Node detail data remains on the mock repository.',
      );

  @override
  Future<NodeModel?> getNode(String nodeId) =>
      throw UnsupportedError(
        'Node detail data remains on the mock repository.',
      );

  @override
  Future<SensorReadingModel?> getLatestReading(String nodeId) =>
      throw UnsupportedError(
        'Use SensorService for real sensor readings.',
      );

  @override
  Future<List<SensorReadingModel>> getReadingHistory(String nodeId) =>
      throw UnsupportedError(
        'Use SensorService for real sensor readings.',
      );

  @override
  Future<List<RecommendationModel>> getRecommendations() async => [];

  @override
  Future<List<AiResultModel>> getAiResults() async => [];
}
