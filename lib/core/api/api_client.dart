import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  /**
   * CATATAN: 
   * - KALAU MAU RUN DI WEB GANTI KE 'http://localhost:3000/api'
   * - KALAU MAU RUN DI EMULATOR ANDROID GANTI KE 'http://10.0.2.2:3000/api'
   * - KALAU MAU RUN DI EMULATOR IOS GANTI KE 'http://localhost:3000/api'
   *  */
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (requiresAuth) {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<dynamic> get(String endpoint, {bool requiresAuth = true}) async {
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = true,
  }) async {
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = true,
  }) async {
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint, {bool requiresAuth = true}) async {
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      // Parse error message from backend
      String message = 'Unknown error';
      try {
        final body = jsonDecode(response.body);
        message = body['message'] ?? body['error'] ?? 'Unknown error';
      } catch (_) {
        message = response.body;
      }
      throw ApiException(message, statusCode: response.statusCode);
    }
  }
}
