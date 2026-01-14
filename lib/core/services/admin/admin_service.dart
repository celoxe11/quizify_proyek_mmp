import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../data/models/quiz_model.dart';
import '../../../data/models/question_model.dart';
import '../../api/dio_client.dart';

class AdminService {
  final DioClient _client;

  AdminService({DioClient? client}) : _client = client ?? DioClient();

  // endpoint for /admin/quizzes (GET all quizzes)
  Future<List<QuizModel>> getAllQuizzes() async {
    final response = await _client.get('/admin/quizzes');

    // Handle response that could be array or object with 'quizzes' key
    final List<dynamic> data;
    if (response.data is List) {
      data = response.data;
    } else if (response.data is Map && response.data['quizzes'] != null) {
      data = response.data['quizzes'];
    } else {
      data = [];
    }

    return data.map((json) => QuizModel.fromJson(json)).toList();
  }

  // endpoint for /admin/quiz/detail/{quizId} (GET quiz detail)
  Future<Map<String, dynamic>> getQuizDetail(String quizId) async {
    print('Fetching quiz detail for ID: $quizId');
    final response = await _client.get('/admin/quiz/detail/$quizId');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> saveQuizWithQuestions({
    String? quizId,
    required String title,
    String? description,
    String? category,
    String? status,
    String? quizCode,
    required List<QuestionModel> questions,
  }) async {
    // Format questions according to backend requirements
    final formattedQuestions = await Future.wait(
      questions.map((q) async {
        // Separate correct answer from other options
        final incorrectAnswers = q.options
            .where((option) => option != q.correctAnswer)
            .toList();

        final questionData = {
          'type': q.type,
          'difficulty': q.difficulty,
          'question_text': q.questionText,
          'correct_answer': q.correctAnswer,
          'incorrect_answers': incorrectAnswers,
        };

        // Convert local image to base64 if exists
        if (q.image != null &&
            q.image!.isNotEmpty &&
            q.image!.imageUrl.isNotEmpty) {
          try {
            // Check if it's already base64 encoded (from web upload)
            if (q.image!.imageUrl.startsWith('data:image')) {
              questionData['question_image'] = q.image!.imageUrl;
              print(
                '✓ Using pre-encoded base64 image for question: ${q.questionText}',
              );
            } else if (!kIsWeb && _isLocalPath(q.image!.imageUrl)) {
              // Mobile: Read from file system
              final imageFile = File(q.image!.imageUrl);
              if (await imageFile.exists()) {
                final bytes = await imageFile.readAsBytes();
                final base64Image = base64Encode(bytes);
                questionData['question_image'] =
                    'data:image/png;base64,$base64Image';
                print(
                  '✓ Image converted to base64 for question: ${q.questionText}',
                );
              }
            }
          } catch (e) {
            print('Error converting image to base64: $e');
            // Continue without image if conversion fails
          }
        }

        return questionData;
      }),
    );

    final requestBody = {
      if (quizId != null) 'quiz_id': quizId,
      'title': title,
      if (description != null && description.isNotEmpty)
        'description': description,
      if (category != null && category.isNotEmpty) 'category': category,
      if (status != null && status.isNotEmpty) 'status': status,
      if (quizCode != null && quizCode.isNotEmpty) 'quiz_code': quizCode,
      'questions': formattedQuestions,
    };

    // Use POST for both create and update (like teacher service)
    // Backend will check quiz_id to determine if it's create or update
    final response = await _client.post('/admin/quiz/save', data: requestBody);

    return response.data as Map<String, dynamic>;
  }

  // endpoint for /admin/quiz (old method, kept for backward compatibility)
  Future<void> saveQuiz(QuizModel quiz) async {
    if (quiz.id.isNotEmpty) {
      await _client.put('/admin/quiz/${quiz.id}', data: quiz.toJson());
    } else {
      await _client.post('/admin/quiz', data: quiz.toJson());
    }
  }

  // endpoint for /admin/quiz/results
  Future<List<Map<String, dynamic>>> getQuizResults(String quizId) async {
    final response = await _client.get('/admin/quiz/results/$quizId');
    final List<dynamic> results = response.data['results'] ?? [];
    return results.cast<Map<String, dynamic>>();
  }

  // endpoint for /admin/quiz/delete (DELETE)
  Future<void> deleteQuiz(String quizId) async {
    await _client.delete('/admin/quiz/delete', data: {'id': quizId});
  }

  // endpoint for /admin/quiz/answers
  Future<Map<String, dynamic>> getQuizAnswers(
    String quizId,
    String studentId, {
    String? sessionId,
  }) async {
    // Use session-specific route if sessionId is provided
    final endpoint = sessionId != null && sessionId.isNotEmpty
        ? '/admin/quiz/answers/session/$sessionId/$studentId'
        : '/admin/quiz/answers/$quizId/$studentId';
    final response = await _client.get(endpoint);
    return response.data as Map<String, dynamic>;
  }

  // endpoint for /admin/quiz/accuracy/{quizId}
  Future<Map<String, dynamic>> getQuizAccuracy(String quizId) async {
    final response = await _client.get('/admin/quiz/accuracy/$quizId');
    return response.data as Map<String, dynamic>;
  }

  // endpoint for /admin/quiz/endquiz/{quizId}
  Future<void> endQuiz(String quizId) async {
    await _client.post('/admin/quiz/endquiz/$quizId');
  }

  // endpoint for /admin/users (GET all users)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final response = await _client.get('/admin/users');
    final List<dynamic> data = response.data['users'] ?? response.data;
    return data.cast<Map<String, dynamic>>();
  }

  // endpoint for /admin/users/{userId} (GET user detail)
  Future<Map<String, dynamic>> getUserDetail(String userId) async {
    final response = await _client.get('/admin/users/$userId');
    return response.data as Map<String, dynamic>;
  }

  // endpoint for /admin/users/{userId} (PUT - update user)
  Future<Map<String, dynamic>> updateUser(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    final response = await _client.put('/admin/users/$userId', data: userData);
    return response.data as Map<String, dynamic>;
  }

  // endpoint for /admin/users/{userId} (DELETE)
  Future<void> deleteUser(String userId) async {
    await _client.delete('/admin/users/$userId');
  }

  // endpoint for /admin/analytics
  Future<Map<String, dynamic>> getAnalytics() async {
    final response = await _client.get('/admin/analytics');
    return response.data as Map<String, dynamic>;
  }

  // endpoint for /admin/logs
  Future<List<Map<String, dynamic>>> getLogs({
    String? level,
    String? startDate,
    String? endDate,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};
    if (level != null) queryParams['level'] = level;
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;
    if (limit != null) queryParams['limit'] = limit;

    final response = await _client.get(
      '/admin/logs',
      queryParameters: queryParams,
    );
    final List<dynamic> data = response.data['logs'] ?? response.data;
    return data.cast<Map<String, dynamic>>();
  }

  /// Check if a path is a local file path (not a URL)
  bool _isLocalPath(String path) {
    return !path.startsWith('http://') &&
        !path.startsWith('https://') &&
        (path.startsWith('/') || path.contains(':'));
  }
}
