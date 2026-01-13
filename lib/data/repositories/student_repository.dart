import 'package:dio/dio.dart';
import 'package:quizify_proyek_mmp/core/api/api_client.dart';
import 'package:quizify_proyek_mmp/core/api/dio_client.dart';
import 'package:quizify_proyek_mmp/data/models/history_detail_model.dart';
import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_session_model.dart';
import 'package:quizify_proyek_mmp/data/models/student_history_model.dart';
import 'package:quizify_proyek_mmp/data/models/submission_answer_model.dart';

class StudentRepository {
  final ApiClient _client;
  final Dio _dio;
  final DioClient _dioClient;

  StudentRepository(this._client, this._dio, this._dioClient);

  List<dynamic> _unwrapList(dynamic json) {
    try {
      if (json is List) {
        return json;
      }
      if (json is Map) {
        if (json['data'] is List) {
          final list = json['data'] as List;
          return list;
        }
        if (json['quizzes'] is List) {
          final list = json['quizzes'] as List;
          return list;
        }
      }
      throw ApiException(
        'Unexpected list response format from API: ${json.runtimeType}',
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> _unwrapObject(dynamic json) {
    if (json is Map<String, dynamic>) {
      if (json['data'] is Map<String, dynamic>) {
        return json['data'] as Map<String, dynamic>;
      }
      return json;
    }
    throw ApiException('Unexpected object response format from API');
  }

  // Join Quiz
  Future<Map<String, dynamic>> startQuizByCode(String code) async {
    final raw = await _client.post('/student/startquizbycode/$code', {});
    if (raw is Map<String, dynamic>) {
      // Unwrap if response has 'data' wrapper
      if (raw['data'] is Map<String, dynamic>) {
        return raw['data'] as Map<String, dynamic>;
      }
      return raw;
    }
    throw ApiException('Unexpected response format from startQuizByCode');
  }

  // Check if student has active session for this quiz code
  Future<Map<String, dynamic>?> getActiveSessionByCode(String code) async {
    try {
      // First get quiz by code to get quiz_id
      final quiz = await getQuizByCode(code);

      // Then check if user has active session for this quiz
      final sessions = await getMyQuizHistory();

      for (var session in sessions) {
        if (session.quizId == quiz.id && session.status == 'in_progress') {
          // Found active session, get its answers
          final answers = await getSubmissionAnswers(session.id);

          return {
            'session_id': session.id,
            'quiz_id': quiz.id,
            'is_resuming': true,
            'answered_questions': {
              for (var answer in answers)
                answer.questionId: answer.selectedAnswer,
            },
            'current_question_index': answers.length,
            'message': 'Melanjutkan quiz yang sedang berjalan',
          };
        }
      }

      return null; // No active session found
    } catch (e) {
      print('⚠️ [StudentRepository] Error checking active session: $e');
      return null;
    }
  }

  // GET /student/quiz/:quiz_id - Get quiz detail by ID
  Future<QuizModel> getQuizDetail(String quizId) async {
    try {
      final raw = await _client.get('/student/quiz/$quizId');
      final map = _unwrapObject(raw);

      return QuizModel.fromJson(map);
    } catch (e) {
      rethrow;
    }
  }

  // GET /student/quiz/code/:code - Get quiz by code (legacy)
  Future<QuizModel> getQuizByCode(String code) async {
    final raw = await _client.get('/student/quiz/code/$code');
    final map = _unwrapObject(raw);
    return QuizModel.fromJson(map);
  }

  Future<List<QuizModel>> fetchPublicQuizzes({
    String? search,
    String? category,
    String? difficulty,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null && category.isNotEmpty) 'category': category,
        if (difficulty != null && difficulty.isNotEmpty)
          'difficulty': difficulty,
      };

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');

      // Use the correct endpoint for public quizzes
      final endpoint =
          '/users/landing/get_public_quiz${queryString.isNotEmpty ? '?$queryString' : ''}';
      final raw = await _client.get(endpoint);
      final listJson = _unwrapList(raw);

      return listJson
          .map((e) => QuizModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception("Gagal mengambil daftar quiz: $e");
    }
  }

  // Quiz Session
  Future<QuizSessionModel> getQuizSession(String sessionId) async {
    final raw = await _client.get('/student/session/$sessionId');
    final map = _unwrapObject(raw);
    return QuizSessionModel.fromJson(map);
  }

  Future<List<QuestionModel>> getQuizQuestions(String sessionId) async {
    final raw = await _client.get('/student/questions/$sessionId');

    // Handle response with 'questions' wrapper
    List<dynamic> listJson;
    if (raw is Map<String, dynamic> && raw['questions'] is List) {
      listJson = raw['questions'] as List;
    } else {
      listJson = _unwrapList(raw);
    }

    return listJson.map((e) {
      final question = e as Map<String, dynamic>;

      // Backend returns 'possible_answers' instead of 'options'
      if (question['possible_answers'] != null && question['options'] == null) {
        question['options'] = question['possible_answers'];
      }

      // Add a default correct_answer since backend doesn't send it
      if (question['correct_answer'] == null) {
        question['correct_answer'] = '';
      }

      return QuestionModel.fromJson(question);
    }).toList();
  }

  Future<void> submitAnswer({
    required String sessionId,
    required String questionId,
    required String selectedAnswer,
  }) async {
    await _client.post('/student/answer', {
      'quiz_session_id': sessionId,
      'question_id': questionId,
      'selected_answer': selectedAnswer,
    });
  }

  Future<Map<String, dynamic>> endQuizSession(String sessionId) async {
    print('🌐 [StudentRepository] Ending quiz session: $sessionId');
    print('📡 [StudentRepository] POST /student/submitquiz');

    final raw = await _client.post('/student/submitquiz', {
      'quiz_session_id': sessionId,
    });

    print('📥 [StudentRepository] Response type: ${raw.runtimeType}');
    print('📥 [StudentRepository] Response data: $raw');

    if (raw is Map<String, dynamic>) {
      print('✅ [StudentRepository] Valid response received');
      return raw;
    }
    print('❌ [StudentRepository] Invalid response format');
    throw ApiException('Unexpected response format from endQuizSession');
  }

  // Quiz Results
  Future<Map<String, dynamic>> getQuizResult(String sessionId) async {
    final raw = await _client.get('/student/session/$sessionId/result');
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    throw ApiException('Unexpected response format from getQuizResult');
  }

  Future<List<SubmissionAnswerModel>> getSubmissionAnswers(
    String sessionId,
  ) async {
    final raw = await _client.get('/student/session/$sessionId/answers');
    final listJson = _unwrapList(raw);
    return listJson
        .map(
          (e) => SubmissionAnswerModel.fromJsonWithQuestion(
            e as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<QuizSessionModel>> getMyQuizHistory() async {
    final raw = await _client.get('/student/my-quiz-history');
    final listJson = _unwrapList(raw);
    return listJson
        .map((e) => QuizSessionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Practice Questions - Generate questions
  Future<List<QuestionModel>> generatePracticeQuestions({
    String? category,
    String? difficulty,
    int count = 10,
  }) async {
    final queryParams = <String, dynamic>{
      'count': count.toString(),
      if (category != null && category.isNotEmpty) 'category': category,
      if (difficulty != null && difficulty.isNotEmpty) 'difficulty': difficulty,
    };

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final raw = await _client.get('/student/practice/generate?$queryString');
    final listJson = _unwrapList(raw);
    return listJson
        .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> getGeminiEvaluation({
    required String submissionAnswerId,
    String language = 'id',
    bool detailedFeedback = true,
    String questionType = 'multiple',
  }) async {
    final response = await _dioClient.post(
      '/student/question/gemini-evaluation',
      data: {
        'submission_answer_id': submissionAnswerId,
        'language': language,
        'detailed_feedback': detailedFeedback,
        'question_type': questionType,
      },
    );
    print(response.data["evaluation"]);
    return Map<String, dynamic>.from(response.data['evaluation']);
  }

  Future<List<StudentHistoryModel>> fetchHistory() async {
    try {
      // Pake _dio agar token 'Bearer ...' otomatis terkirim
      final response = await _dio.get('/student/history');

      // Dio response.data sudah berupa Object (List/Map), tidak perlu jsonDecode
      final data = response.data;

      // Handle format { "data": [...] } atau [...]
      List<dynamic> listJson = [];
      if (data is Map && data['data'] is List) {
        listJson = data['data'];
      } else if (data is List) {
        listJson = data;
      }

      return listJson
          .map((e) => StudentHistoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception("Gagal mengambil history: $e");
    }
  }

  Future<HistoryDetailModel> fetchHistoryDetail(String sessionId) async {
    try {
      // Panggil API Backend
      final response = await _dio.get('/student/history/$sessionId');

      // Ambil bagian 'data' dari JSON response
      final data = _unwrapObject(response.data);

      return HistoryDetailModel.fromJson(data);
    } catch (e) {
      throw Exception("Gagal mengambil detail history: $e");
    }
  }
}
