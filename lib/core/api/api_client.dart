import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../config/platform_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  /// Base URL is automatically determined by platform and environment.
  ///
  /// For development (default):
  /// - Android emulator: http://10.0.2.2:3000/api
  /// - iOS/Desktop/Web: http://localhost:3000/api
  ///
  /// Override with --dart-define:
  /// ```bash
  /// flutter run --dart-define=API_ENV=staging
  /// flutter run --dart-define=API_BASE_URL=https://custom.api.com/api
  /// ```
  static final String baseUrl = PlatformConfig.getBaseUrl();
  static const Duration timeout = Duration(seconds: 10);

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
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'), headers: headers)
          .timeout(timeout);
      return _handleResponse(response);
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw ApiException(
          'Request timeout. Please check your connection and ensure the backend is running.',
        );
      }
      rethrow;
    }
  }

  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(timeout);
      return _handleResponse(response);
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw ApiException(
          'Request timeout. Please check your connection and ensure the backend is running.',
        );
      }
      rethrow;
    }
  }

  Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(timeout);
      return _handleResponse(response);
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw ApiException(
          'Request timeout. Please check your connection and ensure the backend is running.',
        );
      }
      rethrow;
    }
  }

  Future<dynamic> delete(String endpoint, {bool requiresAuth = true}) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await http
          .delete(Uri.parse('$baseUrl$endpoint'), headers: headers)
          .timeout(timeout);
      return _handleResponse(response);
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw ApiException(
          'Request timeout. Please check your connection and ensure the backend is running.',
        );
      }
      rethrow;
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      // Parse error message from backend
      String message = 'Unknown error';
      String? field;

      try {
        final body = jsonDecode(response.body);
        message = body['message'] ?? body['error'] ?? 'Unknown error';
        field = body['field']; // Optional: which field caused the error

        // If there are additional details, append them
        if (body['details'] != null && body['details'] is List) {
          final details = (body['details'] as List).join(', ');
          if (details.isNotEmpty) {
            message = '$message\n$details';
          }
        }
      } catch (_) {
        message = response.body;
      }

      throw ApiException(message, statusCode: response.statusCode);
    }
  }
}
