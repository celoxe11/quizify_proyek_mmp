import '../../../data/models/quiz_model.dart';
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
  Future<void> saveQuiz(QuizModel quiz) async {
    await _client.post('/teacher/quiz/save', data: quiz.toJson());
  }

  // endpoint for /teacher/quiz/results/:quiz_id
  Future<Map<String, dynamic>> getQuizResults(String quizId) async {
    final response = await _client.get('/teacher/quiz/results/$quizId');
    return response.data as Map<String, dynamic>;
  }

  // endpoint for /teacher/quiz/delete
  Future<void> deleteQuiz(String quizId) async {
    await _client.post('/teacher/quiz/delete', data: {'quiz_id': quizId});
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

  // endpoint for "teacher/quiz/accuracy/:quiz_id",
  Future<Map<String, dynamic>> getQuizAccuracy(String quizId) async {
    final response = await _client.get('/teacher/quiz/accuracy/$quizId');
    return response.data as Map<String, dynamic>;
  }

  // endpoint for /teacher/quiz/endquiz/:session_id
  Future<void> endQuiz(String quizId) async {
    await _client.post(
      '/teacher/quiz/endquiz/$quizId',
    );
  }
}
