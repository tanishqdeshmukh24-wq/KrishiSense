import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/latest_sensor_reading_model.dart';
import 'auth_service.dart';

class SensorService {
  SensorService({
    required this.baseUrl,
    required this.accessToken,
  });

  final String baseUrl;
  final String accessToken;

  Future<LatestSensorReadingModel> getLatest(String nodeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/sensor/readings/$nodeId/latest'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = decoded['detail'];
      throw ApiException(
        response.statusCode,
        detail?.toString() ??
            'Sensor request failed (${response.statusCode}).',
      );
    }

    return LatestSensorReadingModel(
      nodeId: decoded['node_id'].toString(),
      soilMoisture: (decoded['soil_moisture'] as num).toDouble(),
      timestamp: DateTime.parse(decoded['timestamp'].toString()).toLocal(),
    );
  }
}
