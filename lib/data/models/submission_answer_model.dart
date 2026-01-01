import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/domain/entities/submission_answer.dart';

class SubmissionAnswerModel extends SubmissionAnswer {
  final QuestionModel? question;

  SubmissionAnswerModel({
    required super.id,
    required super.quizSessionId,
    required super.questionId,
    required super.selectedAnswer,
    required super.isCorrect,
    super.answeredAt,
    this.question, // field ini nullable karena mungkin tidak selalu ada
  });

  factory SubmissionAnswerModel.fromJson(Map<String, dynamic> json) {
    return SubmissionAnswerModel(
      id: json['id'] as String,
      quizSessionId: json['quiz_session_id'] as String,
      questionId: json['question_id'] as String,
      selectedAnswer: json['selected_answer'] as String,
      isCorrect: json['is_correct'] as bool,
      answeredAt: json['answered_at'] != null 
          ? DateTime.parse(json['answered_at'] as String)
          : null,
    );
  }

  /// Factory for parsing response with nested Question object
  factory SubmissionAnswerModel.fromJsonWithQuestion(Map<String, dynamic> json) {
    return SubmissionAnswerModel(
      id: json['id'] as String,
      quizSessionId: json['quiz_session_id'] as String,
      questionId: json['question_id'] as String,
      selectedAnswer: json['selected_answer'] as String,
      isCorrect: json['is_correct'] as bool,
      answeredAt: json['answered_at'] != null 
          ? DateTime.parse(json['answered_at'] as String)
          : null,
      question: json['Question'] != null
          ? QuestionModel.fromJson(json['Question'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_session_id': quizSessionId,
      'question_id': questionId,
      'selected_answer': selectedAnswer,
      'is_correct': isCorrect,
      if (answeredAt != null) 'answered_at': answeredAt!.toIso8601String(),
      if (question != null) 'Question': question!.toJson(),
    };
  }
}
