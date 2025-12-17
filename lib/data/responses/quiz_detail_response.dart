import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';

class QuizDetailResponse {
  final String message;
  final QuizModel quiz;
  final List<QuestionModel> questions;

  QuizDetailResponse({
    required this.message,
    required this.quiz,
    required this.questions,
  });

  // From API response
  factory QuizDetailResponse.fromApi(Map<String, dynamic> json) {
    print('🔍 Parsing API response: $json');
    
    final quizData = json['quiz'] as Map<String, dynamic>?;
    if (quizData == null) {
      throw Exception('Quiz data is null in API response');
    }
    
    print('🔍 Quiz data: $quizData');
    
    final questionsData = quizData['questions'] as List?;
    if (questionsData == null) {
      throw Exception('Questions data is null in quiz');
    }
    
    return QuizDetailResponse(
      message: json['message'] ?? '',
      quiz: QuizModel.fromJson(quizData),
      questions: questionsData
          .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }

  // From local storage
  factory QuizDetailResponse.fromLocal(Map<String, dynamic> data) {
    return QuizDetailResponse(
      message: 'Loaded from cache',
      quiz: QuizModel.fromJson(data),
      questions: (data['questions'] as List)
          .map((q) => QuestionModel.fromJson(q))
          .toList(),
    );
  }
}
