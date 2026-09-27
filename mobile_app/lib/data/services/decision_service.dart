import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/decision_result_model.dart';

class DecisionService {
  DecisionService({
    this.baseUrl = 'http://127.0.0.1:8000',
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
      final error = decoded['error'];
      final message = error is Map<String, dynamic>
          ? (error['message']?.toString() ?? 'Decision request failed.')
          : 'Decision request failed (${response.statusCode}).';
      throw Exception(message);
    }

    return DecisionResultModel.fromJson(decoded);
  }
}
