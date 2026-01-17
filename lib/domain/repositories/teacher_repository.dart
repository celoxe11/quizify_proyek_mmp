import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';
import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/data/responses/quiz_detail_response.dart';

abstract class TeacherRepository {
  Future<List<QuizModel>> getMyQuizzes();

  /// Save quiz with questions
  /// - quizId: Optional, if provided will update existing quiz
  /// - title: Required, quiz title (must not be empty)
  /// - description: Optional, quiz description
  /// - quizCode: Optional, quiz code (max 20 characters)
  /// - questions: Required, list of questions (minimum 1 question)
  Future<QuizModel> saveQuiz({
    String? quizId,
    required String title,
    String? description,
    String? category,
    String? status,
    String? quizCode,
    required List<QuestionModel> questions,
  });

  Future<void> deleteQuiz(String quizId);

  /// Generate AI-powered question
  /// - type: "multiple" or "boolean" (default: "multiple")
  /// - difficulty: "easy", "medium", or "hard" (default: "medium")
  /// - category: Question category (default: "General Knowledge")
  /// - topic: Specific topic (optional, can be empty)
  /// - language: "id" (Indonesia) or "en" (English) (default: "id")
  /// - context: Additional context, max 5000 chars (optional)
  /// - ageGroup: "SD", "SMP", "SMA", or "Perguruan Tinggi" (default: "SMA")
  /// - avoidTopics: Topics to avoid in question generation
  /// - includeExplanation: Whether to include explanation (default: false)
  /// - questionStyle: "formal", "casual", or "scenario-based" (default: "formal")
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
  });

  Future<QuizDetailResponse> getQuizDetail(String quizId);

  Future<dynamic> getQuizResult(String quizId);

  Future<dynamic> getQuizAccuracy(String quizId);
  
  Future<Map<String, dynamic>> getStudentAnswers({
    required String studentId,
    required String quizId,
  });
}
