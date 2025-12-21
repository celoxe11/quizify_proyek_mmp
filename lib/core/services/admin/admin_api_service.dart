import 'package:dio/dio.dart';

class AdminApiService {
  final Dio _dio;

  AdminApiService(this._dio);

  // GET ALL USERS
  Future<List<dynamic>> getAllUsers() async {
    try {
      // Endpoint ini harus mereturn JSON dengan structure { data: [...] }
      // Query backend harus ada JOIN ke subscription untuk dapat status text
      final response = await _dio.get('/api/admin/users');
      return response.data['data']; 
    } catch (e) {
      throw Exception("API Error Fetch Users: $e");
    }
  }

  // BLOCK / UNBLOCK USER
  Future<void> toggleUserStatus(String userId, bool isActive) async {
    try {
      await _dio.patch(
        '/api/admin/users/$userId/status',
        data: {'is_active': isActive ? 1 : 0},
      );
    } catch (e) {
      throw Exception("API Error Toggle User: $e");
    }
  }

  // GET ALL QUIZZES
  Future<List<dynamic>> getAllQuizzes() async {
    try {
      final response = await _dio.get('/api/admin/quizzes');
      return response.data['data'];
    } catch (e) {
      throw Exception("API Error Fetch Quizzes: $e");
    }
  }
}