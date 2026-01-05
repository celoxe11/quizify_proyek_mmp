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

      if (response.data is List) {
        return response.data;
      }
      // Atau berupa Map dengan key 'data' (Kurung Kurawal {})
      else if (response.data is Map && response.data['data'] != null) {
        return response.data['data'];
      }

      return [];
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

      // Handle different response structures
      if (response.data is List) {
        return response.data;
      } else if (response.data is Map && response.data['data'] != null) {
        if (response.data['data'] is List) {
          return response.data['data'];
        }
      }

      return [];
    } catch (e) {
      throw Exception("API Error Fetch Quizzes: $e");
    }
  }

  Future<List<dynamic>> getQuizDetail(String quizId) async {
    try {
      // Endpoint sesuai request backend kamu: /quiz/detail/:quiz_id
      final response = await _dio.get('/api/admin/quiz/detail/$quizId');

      // Backend return: { message: "...", questions: [...] }
      return response.data['questions'];
    } catch (e) {
      throw Exception("API Error Get Quiz Detail: $e");
    }
  }

  // GET DASHBOARD ANALYTICS
  Future<dynamic> getAnalytics() async {
    try {
      final response = await _dio.get('/api/admin/analytics');
      return response
          .data; // Mengembalikan seluruh JSON { message:..., data:... }
    } catch (e) {
      throw Exception("API Error Analytics: $e");
    }
  }

  // GET LOGS
  Future<List<dynamic>> getLogs({String? userId}) async {
    try {
      // Dio otomatis menyusun query string: /logaccess?user_id=123
      final response = await _dio.get(
        '/api/admin/logaccess',
        queryParameters: userId != null ? {'user_id': userId} : null,
      );
      return response.data;
    } catch (e) {
      throw Exception("API Error Logs: $e");
    }
  }

  // DELETE QUESTION
  Future<void> deleteQuestion(String questionId) async {
    try {
      // Endpoint: /api/admin/question/:question_id
      await _dio.delete('/api/admin/question/$questionId');
    } catch (e) {
      throw Exception("API Error Delete Question: $e");
    }
  }

  // GET SUBSCRIPTIONS
  Future<List<dynamic>> getSubscriptions() async {
    final response = await _dio.get('/api/admin/subscriptions');
    return response.data['data'];
  }
  
 // UPDATE USER
  Future<void> updateUser(String userId, {String? role, int? subscriptionId}) async {
    try {
      print("📡 Sending Update to Backend: Role=$role, SubID=$subscriptionId");
      
      await _dio.put(
        '/api/admin/users/$userId', 
        data: {
          // Pastikan key-nya persis dengan yang diminta Backend (req.body)
          if (role != null) 'role': role,
          if (subscriptionId != null) 'subscription_id': subscriptionId, // <--- HARUS subscription_id
        },
      );
      print("✅ Update Success");
    } catch (e) {
      print("❌ Update Failed: $e");
      throw Exception("Gagal update user: $e");
    }
  }
  
}
