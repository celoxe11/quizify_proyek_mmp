import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quizify_proyek_mmp/core/config/platform_config.dart';

/// Custom exception for Dio API errors
class DioApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  DioApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => message;
}

/// Dio-based API client with Firebase authentication interceptor.
///
/// Use this client for endpoints that need:
/// - File uploads (multipart/form-data)
/// - Complex interceptors
/// - Request/response transformations
///
/// For simple JSON requests, you can still use [ApiClient].
///
/// ## Usage:
/// ```dart
/// final client = DioClient();
///
/// // Simple GET
/// final response = await client.get('/teacher/quizzes');
///
/// // POST with data
/// final response = await client.post('/teacher/quiz', data: {...});
///
/// // File upload
/// final response = await client.uploadFile('/question', file, data: {...});
/// ```
class DioClient {
  static const Duration timeout = Duration(seconds: 10);
  late final Dio _dio;

  /// Singleton instance
  static DioClient? _instance;

  /// Get singleton instance
  factory DioClient() {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  DioClient._internal() {
    _dio = Dio(_baseOptions);
    _setupInterceptors();
  }

  /// Base Dio options
  BaseOptions get _baseOptions => BaseOptions(
    baseUrl: PlatformConfig.getBaseUrl(),
    connectTimeout: timeout,
    receiveTimeout: timeout,
    sendTimeout: timeout,
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  );

  /// Configure all interceptors
  void _setupInterceptors() {
    // 1. Authentication Interceptor
    _dio.interceptors.add(_authInterceptor);

    // 2. Logging Interceptor (only in debug mode)
    if (!PlatformConfig.isProduction) {
      _dio.interceptors.add(_loggingInterceptor);
    }

    // 3. Error Handling Interceptor
    _dio.interceptors.add(_errorInterceptor);
  }

  /// Firebase Authentication Interceptor
  InterceptorsWrapper get _authInterceptor => InterceptorsWrapper(
    onRequest: (options, handler) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final token = await user.getIdToken();
          options.headers['Authorization'] = 'Bearer $token';
        } catch (e) {
          print('Error getting Firebase token: $e');
        }
      }
      return handler.next(options);
    },
  );

  /// Logging Interceptor for debugging
  LogInterceptor get _loggingInterceptor => LogInterceptor(
    request: true,
    requestHeader: true,
    requestBody: true,
    responseHeader: false,
    responseBody: true,
    error: true,
    logPrint: (obj) => print('🌐 DIO: $obj'),
  );

  /// Error Handling Interceptor
  InterceptorsWrapper get _errorInterceptor => InterceptorsWrapper(
    onError: (DioException e, handler) {
      // Handle specific error cases
      if (e.response?.statusCode == 401) {
        // Token expired or unauthorized
        // TODO: Trigger re-authentication flow
        print('🔐 Unauthorized - Token may be expired');
      }

      // Check if response is an image (from http.cat error pages)
      if (e.response?.headers.value('content-type')?.contains('image') ==
          true) {
        print('📷 Received error image from server');
      }

      return handler.next(e);
    },
  );

  // ============================================================
  // HTTP Methods
  // ============================================================

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================================
  // File Upload Methods
  // ============================================================

  /// Upload a single file with optional additional data
  Future<Response> uploadFile(
    String path, {
    required String filePath,
    required String fileFieldName,
    String? fileName,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final formData = FormData.fromMap({
        ...?additionalData,
        fileFieldName: await MultipartFile.fromFile(
          filePath,
          filename: fileName ?? filePath.split('/').last,
        ),
      });

      return await _dio.post(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload multiple files
  Future<Response> uploadFiles(
    String path, {
    required List<String> filePaths,
    required String fileFieldName,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final files = await Future.wait(
        filePaths.map(
          (path) async =>
              MultipartFile.fromFile(path, filename: path.split('/').last),
        ),
      );

      final formData = FormData.fromMap({
        ...?additionalData,
        fileFieldName: files,
      });

      return await _dio.post(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================================
  // Error Handling
  // ============================================================

  /// Convert DioException to DioApiException
  DioApiException _handleError(DioException e) {
    String message;
    int? statusCode = e.response?.statusCode;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.connectionError:
        message = 'Unable to connect to server. Please check your connection.';
        break;
      case DioExceptionType.badResponse:
        // Try to extract error message from response
        final data = e.response?.data;
        if (data is Map) {
          message = data['message'] ?? data['error'] ?? 'Server error';
        } else {
          message = 'Server error: ${e.response?.statusCode}';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled';
        break;
      default:
        message = e.message ?? 'An unexpected error occurred';
    }

    return DioApiException(
      message,
      statusCode: statusCode,
      data: e.response?.data,
    );
  }

  /// Access to underlying Dio instance for advanced usage
  Dio get dio => _dio;
}
