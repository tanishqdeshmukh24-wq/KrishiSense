import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  static String? _accessToken;

  static String? get accessToken => _accessToken;

  static bool get isAuthenticated =>
      _accessToken != null && _accessToken!.isNotEmpty;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: const {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
      body: {
        'username': email.trim(),
        'password': password,
      },
    );

    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = decoded['detail'];
      throw ApiException(
        response.statusCode,
        detail?.toString() ?? 'Login failed (${response.statusCode}).',
      );
    }

    final token = decoded['access_token']?.toString();
    if (token == null || token.isEmpty) {
      throw const ApiException(
        200,
        'Login succeeded but no access token was returned.',
      );
    }

    _accessToken = token;
  }

  static void logout() {
    _accessToken = null;
  }
}
