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
    print('🔍 DEBUG: Parsing API response');
    print('🔍 DEBUG: Full response: $json');

    // Try different response structures
    Map<String, dynamic>? quizData;
    List? questionsData;

    // Structure 1: { "quiz": {...}, "questions": [...] }
    if (json.containsKey('quiz')) {
      quizData = json['quiz'] as Map<String, dynamic>?;
      questionsData = json['questions'] as List?;
    }
    // Structure 2: { "data": { "quiz": {...}, "questions": [...] } }
    else if (json.containsKey('data')) {
      final data = json['data'] as Map<String, dynamic>?;
      if (data != null) {
        quizData = data['quiz'] as Map<String, dynamic>?;
        questionsData = data['questions'] as List?;
      }
    }
    // Structure 3: Quiz data directly at root level with questions array
    else if (json.containsKey('title') && json.containsKey('questions')) {
      quizData = json;
      questionsData = json['questions'] as List?;
    }
    // Structure 4: Quiz object nested in quiz key with questions inside
    else if (json.containsKey('quiz')) {
      final quiz = json['quiz'] as Map<String, dynamic>?;
      if (quiz != null && quiz.containsKey('questions')) {
        quizData = quiz;
        questionsData = quiz['questions'] as List?;
      }
    }

    if (quizData == null) {
      print('❌ ERROR: Quiz data is null in API response');
      print('❌ ERROR: Response keys: ${json.keys.toList()}');
      throw Exception(
        'Quiz data is null in API response. Available keys: ${json.keys.toList()}',
      );
    }

    print('✅ DEBUG: Quiz data found: ${quizData.keys.toList()}');

    // Extract questions from quiz data if not already extracted
    if (questionsData == null && quizData.containsKey('questions')) {
      questionsData = quizData['questions'] as List?;
    }

    if (questionsData == null) {
      print('⚠️ WARNING: No questions found, using empty list');
      questionsData = [];
    }

    print('✅ DEBUG: Found ${questionsData.length} questions');

    return QuizDetailResponse(
      message: json['message'] ?? 'Success',
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
