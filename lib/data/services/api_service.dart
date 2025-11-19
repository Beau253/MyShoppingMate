import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_shopping_mate/core/config/app_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status Code: $statusCode)';
}

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
    try {
      final response = await _client.get(url);
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Failed to connect to the server: $e');
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Failed to connect to the server: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw ApiException('Failed to parse response: $e');
      }
    } else {
      throw ApiException(
        'Request failed with status: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }
}
