import 'dart:io';

import 'package:dio/dio.dart';
import 'package:quizify_proyek_mmp/core/api/dio_client.dart';
import 'package:quizify_proyek_mmp/data/models/question_model.dart';

/// Service for teacher question-related API endpoints.
///
/// Uses [DioClient] for HTTP requests with Firebase authentication.
/// Supports file uploads for question images.
///
/// ## Endpoints:
/// - `GET /teacher/quiz/:quizId/questions` - Get all questions for a quiz
/// - `POST /teacher/question` - Create a new question
/// - `PUT /teacher/question/:id` - Update question
/// - `DELETE /teacher/question/:id` - Delete question
class TeacherQuestionService {
  final DioClient _client;

  TeacherQuestionService({DioClient? client}) : _client = client ?? DioClient();

  // ============================================================
  // Question CRUD Operations
  // ============================================================

  /// Get all questions for a specific quiz
  Future<List<QuestionModel>> getQuestionsByQuizId(String quizId) async {
    final response = await _client.get('/teacher/quiz/$quizId/questions');

    final List<dynamic> data = response.data['questions'] ?? response.data;
    return data.map((json) => QuestionModel.fromJson(json)).toList();
  }

  /// Get a specific question by ID
  Future<QuestionModel> getQuestionById(String questionId) async {
    final response = await _client.get('/teacher/question/$questionId');
    return QuestionModel.fromJson(response.data);
  }

  /// Create a new question
  Future<QuestionModel> createQuestion({
    required String quizId,
    required String questionText,
    required String type,
    required String difficulty,
    required List<String> options,
    required String correctAnswer,
    File? imageFile,
  }) async {
    // If there's an image, use multipart form
    if (imageFile != null) {
      final response = await _client.uploadFile(
        '/teacher/question',
        filePath: imageFile.path,
        fileFieldName: 'gambar_soal', // Based on your backend parseForm
        additionalData: {
          'quiz_id': quizId,
          'question_text': questionText,
          'type': type,
          'difficulty': difficulty,
          'options': options,
          'correct_answer': correctAnswer,
        },
      );
      return QuestionModel.fromJson(response.data);
    }

    // No image - use regular JSON POST
    final response = await _client.post(
      '/teacher/question',
      data: {
        'quiz_id': quizId,
        'question_text': questionText,
        'type': type,
        'difficulty': difficulty,
        'options': options,
        'correct_answer': correctAnswer,
      },
    );

    return QuestionModel.fromJson(response.data);
  }

  /// Update an existing question
  Future<QuestionModel> updateQuestion({
    required String questionId,
    String? questionText,
    String? type,
    String? difficulty,
    List<String>? options,
    String? correctAnswer,
    File? imageFile,
  }) async {
    final data = <String, dynamic>{};
    if (questionText != null) data['question_text'] = questionText;
    if (type != null) data['type'] = type;
    if (difficulty != null) data['difficulty'] = difficulty;
    if (options != null) data['options'] = options;
    if (correctAnswer != null) data['correct_answer'] = correctAnswer;

    // If there's an image, use multipart form
    if (imageFile != null) {
      final response = await _client.uploadFile(
        '/teacher/question/$questionId',
        filePath: imageFile.path,
        fileFieldName: 'gambar_soal',
        additionalData: data,
      );
      return QuestionModel.fromJson(response.data);
    }

    final response = await _client.put(
      '/teacher/question/$questionId',
      data: data,
    );
    return QuestionModel.fromJson(response.data);
  }

  /// Delete a question
  Future<void> deleteQuestion(String questionId) async {
    await _client.delete('/teacher/question/$questionId');
  }

  // ============================================================
  // Bulk Operations
  // ============================================================

  /// Create multiple questions at once
  Future<List<QuestionModel>> createBulkQuestions({
    required String quizId,
    required List<Map<String, dynamic>> questions,
  }) async {
    final response = await _client.post(
      '/teacher/quiz/$quizId/questions/bulk',
      data: {'questions': questions},
    );

    final List<dynamic> data = response.data['questions'] ?? response.data;
    return data.map((json) => QuestionModel.fromJson(json)).toList();
  }

  /// Reorder questions within a quiz
  Future<void> reorderQuestions({
    required String quizId,
    required List<String> questionIds,
  }) async {
    await _client.put(
      '/teacher/quiz/$quizId/questions/reorder',
      data: {'question_ids': questionIds},
    );
  }
}
