import 'package:dio/dio.dart';
import 'package:quizify_proyek_mmp/core/api/dio_client.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';

/// Service for teacher quiz-related API endpoints.
///
/// Uses [DioClient] for HTTP requests with Firebase authentication.
///
/// ## Endpoints:
/// - `GET /teacher/quiz` - Get all teacher's quizzes
/// - `POST /teacher/quiz` - Create a new quiz
/// - `GET /teacher/quiz/:id` - Get quiz by ID
/// - `PUT /teacher/quiz/:id` - Update quiz
/// - `DELETE /teacher/quiz/:id` - Delete quiz
/// - `GET /teacher/quiz/:id/result` - Get quiz results
/// - `GET /teacher/quiz/:id/accuracy` - Get quiz accuracy (premium)
class TeacherQuizService {
  final DioClient _client;

  TeacherQuizService({DioClient? client}) : _client = client ?? DioClient();

  // ============================================================
  // Quiz CRUD Operations
  // ============================================================

  /// Get all quizzes for the authenticated teacher
  Future<List<QuizModel>> getMyQuizzes() async {
    final response = await _client.get('/teacher/myquiz');
    final List<dynamic> data = response.data['quizzes'] ?? response.data;
    return data.map((json) => QuizModel.fromJson(json)).toList();
  }

  /// Get a specific quiz by ID with questions
  Future<Map<String, dynamic>> getQuizDetail(String quizId) async {
    final response = await _client.get('/teacher/quiz/detail/$quizId');
    return response.data as Map<String, dynamic>;
  }

  /// Create a new quiz
  Future<QuizModel> createQuiz({
    required String title,
    String? description,
    String? category,
    String status = 'private',
  }) async {
    final response = await _client.post(
      '/teacher/quiz',
      data: {
        'title': title,
        'description': description,
        'category': category,
        'status': status,
      },
    );

    return QuizModel.fromJson(response.data);
  }

  /// Update an existing quiz
  Future<QuizModel> updateQuiz({
    required String quizId,
    String? title,
    String? description,
    String? category,
    String? status,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (category != null) data['category'] = category;
    if (status != null) data['status'] = status;

    final response = await _client.put('/teacher/quiz/$quizId', data: data);
    return QuizModel.fromJson(response.data);
  }

  /// Delete a quiz
  Future<void> deleteQuiz(String quizId) async {
    await _client.delete('/teacher/quiz/$quizId');
  }

  // ============================================================
  // Quiz Results & Analytics
  // ============================================================

  /// Get results for a specific quiz
  /// Returns list of student results with scores and timestamps
  Future<List<Map<String, dynamic>>> getQuizResults(String quizId) async {
    final response = await _client.get('/teacher/quiz/$quizId/result');

    final List<dynamic> data = response.data['results'] ?? response.data;
    return data.cast<Map<String, dynamic>>();
  }

  /// Get accuracy statistics for a quiz (Premium feature)
  /// Returns per-question accuracy data
  Future<Map<String, dynamic>> getQuizAccuracy(String quizId) async {
    final response = await _client.get('/teacher/quiz/$quizId/accuracy');
    return response.data;
  }

  // ============================================================
  // Quiz Status Management
  // ============================================================

  /// Publish a quiz (make it public)
  Future<QuizModel> publishQuiz(String quizId) async {
    return updateQuiz(quizId: quizId, status: 'public');
  }

  /// Unpublish a quiz (make it private)
  Future<QuizModel> unpublishQuiz(String quizId) async {
    return updateQuiz(quizId: quizId, status: 'private');
  }
}
