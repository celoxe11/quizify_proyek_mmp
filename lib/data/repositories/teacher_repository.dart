import 'package:quizify_proyek_mmp/core/services/services.dart';
import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';
import 'package:quizify_proyek_mmp/data/responses/quiz_detail_response.dart';
import 'package:quizify_proyek_mmp/domain/repositories/teacher_repository.dart';

class TeacherRepositoryImpl extends TeacherRepository {
  final TeacherService _teacherService;

  // todo: provider lokal bisa ditambahin disini nanti

  TeacherRepositoryImpl({
    TeacherService? teacherService
  }) : _teacherService = teacherService ?? TeacherService();

  @override
  Future<void> endQuiz(String sessionId) {
    // TODO: implement endQuiz
    throw UnimplementedError();
  }

  @override
  Future<QuestionModel> generateQuestion({
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
  }) {
    // TODO: implement generateQuestion
    throw UnimplementedError();
  }

  @override
  Future<List<QuizModel>> getMyQuizzes() {
    return _teacherService.getMyQuizzes();
  }

  @override
  Future<dynamic> getQuizAccuracy(String quizId) {
    // TODO: implement getQuizAccuracy
    throw UnimplementedError();
  }

  @override
  Future<QuizDetailResponse> getQuizDetail(String quizId) async {
    // TODO: BUAT LOCAL
    // Try local first
    // final localData = await _localDataSource?.getQuiz(quizId);
    // if (localData != null) {
    //   return QuizDetailResponse.fromLocal(localData);
    // }

    // Fallback to API
    final apiResponse = await _teacherService.getQuizDetail(quizId);
    return QuizDetailResponse.fromApi(apiResponse);
  }

  @override
  Future<dynamic> getQuizResult(String quizId) {
    // TODO: implement getQuizResult
    throw UnimplementedError();
  }

  @override
  Future<dynamic> getStudentsAnswers(String quizId) {
    // TODO: implement getStudentsAnswers
    throw UnimplementedError();
  }

  @override
  Future<QuizModel> saveQuiz({
    String? quizId,
    required String title,
    String? description,
    String? quizCode,
    required List<QuestionModel> questions,
  }) {
    // TODO: implement saveQuiz
    throw UnimplementedError();
  }
}
