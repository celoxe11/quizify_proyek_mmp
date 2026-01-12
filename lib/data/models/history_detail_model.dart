class HistoryDetailModel {
  final String quizTitle;
  final int score;
  final DateTime finishedAt;
  final List<QuestionReview> details;

  HistoryDetailModel({
    required this.quizTitle,
    required this.score,
    required this.finishedAt,
    required this.details,
  });

  factory HistoryDetailModel.fromJson(Map<String, dynamic> json) {
    return HistoryDetailModel(
      quizTitle: json['quiz_title'] ?? '',
      score: json['score'] ?? 0,
      finishedAt: DateTime.tryParse(json['finished_at'] ?? '') ?? DateTime.now(),
      details: (json['details'] as List)
          .map((e) => QuestionReview.fromJson(e))
          .toList(),
    );
  }
}

class QuestionReview {
  final String questionText;
  final String type;
  final String difficulty;
  final List<String> options;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;

  QuestionReview({
    required this.questionText,
    required this.type,
    required this.difficulty,
    required this.options,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
  });

  factory QuestionReview.fromJson(Map<String, dynamic> json) {
    return QuestionReview(
      questionText: json['question_text'] ?? '',
      type: json['type'] ?? 'multiple',
      difficulty: json['difficulty'] ?? 'easy',
      // Helper options parsing (sama seperti question model)
      options: (json['options'] is List) 
          ? (json['options'] as List).map((e) => e.toString()).toList() 
          : [], 
      userAnswer: json['user_answer'] ?? '',
      correctAnswer: json['correct_answer'] ?? '',
      isCorrect: json['is_correct'] == true || json['is_correct'] == 1,
    );
  }
}