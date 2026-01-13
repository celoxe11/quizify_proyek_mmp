import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../data/models/quiz_model.dart';
import '../../../data/models/question_model.dart';
import '../../api/dio_client.dart';

class TeacherService {
  final DioClient _client;

  TeacherService({DioClient? client}) : _client = client ?? DioClient();

  // endpoint for /teacher/myquiz
  Future<List<QuizModel>> getMyQuizzes() async {
    final response = await _client.get('/teacher/myquiz');
    final List<dynamic> data = response.data['quizzes'] ?? response.data;
    return data.map((json) => QuizModel.fromJson(json)).toList();
  }

  // endpoint for /teacher/quiz/detail/{quizId}
  Future<Map<String, dynamic>> getQuizDetail(String quizId) async {
    final response = await _client.get('/teacher/quiz/detail/$quizId');
    return response.data as Map<String, dynamic>;
  }

  // endpoint for /teacher/quiz/save
  /// Save or update quiz with questions
  /// Backend expects:
  /// {
  ///   "quiz_id": "QU001", // optional, if present = update mode
  ///   "title": "Quiz Title",
  ///   "description": "Quiz Description",
  ///   "quiz_code": "ABCD1234", // optional
  ///   "questions": [
  ///     {
  ///       "type": "multiple",
  ///       "difficulty": "easy",
  ///       "question_text": "What is...",
  ///       "correct_answer": "Option 1",
  ///       "incorrect_answers": ["Option 2", "Option 3", "Option 4"],
  ///       "question_image": "base64string" // optional
  ///     }
  ///   ]
  /// }
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
          // Include question ID if it exists (for editing existing questions)
          if (q.id.isNotEmpty && !q.id.startsWith(RegExp(r'\d{13}'))) 'id': q.id,
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
            } else if (q.image!.imageUrl.startsWith('http')) {
              // Existing backend URL - preserve it
              questionData['question_image'] = q.image!.imageUrl;
              print(
                '✓ Preserving existing backend image URL for question: ${q.questionText}',
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

    final response = await _client.post(
      '/teacher/quiz/save',
      data: requestBody,
    );
    return response.data as Map<String, dynamic>;
  }

  // endpoint for /teacher/quiz/save (old method, kept for backward compatibility)
  Future<void> saveQuiz(QuizModel quiz) async {
    await _client.post('/teacher/quiz/save', data: quiz.toJson());
  }

  // endpoint for /teacher/quiz/results/:quiz_id
  Future<List<Map<String, dynamic>>> getQuizResults(String quizId) async {
    final response = await _client.get('/teacher/quiz/results/$quizId');
    final List<dynamic> results = response.data['results'] ?? [];
    return results.cast<Map<String, dynamic>>();
  }

  // endpoint for /teacher/quiz/delete
  Future<void> deleteQuiz(String quizId) async {
    await _client.delete('/teacher/quiz/delete', data: {'id': quizId});
  }

  // endpoint for /teacher/quiz/answers
  Future<Map<String, dynamic>> getQuizAnswers(
    String quizId,
    String studentId,
  ) async {
    final response = await _client.get(
      '/teacher/quiz/answers',
      data: {'quiz_id': quizId, 'student_id': studentId},
    );
    return response.data as Map<String, dynamic>;
  }

  // endpoint for /teacher/student/answers (GET)
  Future<Map<String, dynamic>> getStudentAnswers({
    required String studentId,
    required String quizId,
  }) async {
    final response = await _client.get(
      '/teacher/quiz/answers/$quizId/$studentId',
    );
    return response.data as Map<String, dynamic>;
  }

  // endpoint for "teacher/quiz/accuracy/:quiz_id",
  Future<Map<String, dynamic>> getQuizAccuracy(String quizId) async {
    final response = await _client.get('/teacher/quiz/accuracy/$quizId');
    return response.data as Map<String, dynamic>;
  }

  // endpoint for /teacher/quiz/endquiz/:session_id
  Future<void> endQuiz(String quizId) async {
    await _client.post('/teacher/quiz/endquiz/$quizId');
  }

  //endpoint for /teacher/quiz/generatequestion
  Future<Map<String, dynamic>> generateQuestion({
    String? type,
    String? difficulty,
    String? category,
    String? topic,
    String? language,
    String? context,
    String? ageGroup,
    List<String>? avoidTopics,
    bool? includeExplanation,
    String? questionStyle,
  }) async {
    final requestBody = {
      if (type != null) 'type': type,
      if (difficulty != null) 'difficulty': difficulty,
      if (category != null) 'category': category,
      if (topic != null) 'topic': topic,
      if (language != null) 'language': language,
      if (context != null) 'context': context,
      if (ageGroup != null) 'age_group': ageGroup,
      if (avoidTopics != null && avoidTopics.isNotEmpty)
        'avoid_topics': avoidTopics,
      if (includeExplanation != null) 'include_explanation': includeExplanation,
      if (questionStyle != null) 'question_style': questionStyle,
    };

    final response = await _client.post(
      '/teacher/generatequestion',
      data: requestBody,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Check if a path is a local file path (not a URL)
  bool _isLocalPath(String path) {
    return !path.startsWith('http://') &&
        !path.startsWith('https://') &&
        (path.startsWith('/') || path.contains(':'));
  }
}
