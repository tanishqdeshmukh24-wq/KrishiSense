import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/decision_result_model.dart';
import 'auth_service.dart';

class DecisionService {
  DecisionService({
    this.baseUrl = 'http://10.0.2.2:8000',
    this.accessToken,
  });

  final String baseUrl;
  final String? accessToken;

  Future<DecisionResultModel> evaluate({
    required String zoneId,
    double? soilMoisture,
    required String crop,
    required String growthStage,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };

    final body = <String, dynamic>{
      'zone_id': zoneId,
      'crop': crop,
      'growth_stage': growthStage,
    };

    if (soilMoisture != null) {
      body['soil_moisture'] = soilMoisture;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/decision-engine/evaluate'),
      headers: headers,
      body: jsonEncode(body),
    );

    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = decoded['detail'];
      final error = decoded['error'];
      final message = detail?.toString() ??
          (error is Map<String, dynamic>
              ? (error['message']?.toString() ?? 'Decision request failed.')
              : 'Decision request failed (${response.statusCode}).');
      throw ApiException(response.statusCode, message);
    }

    return DecisionResultModel.fromJson(decoded);
  }
}
