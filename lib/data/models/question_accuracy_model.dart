class QuestionAccuracy {
  final String questionId;
  final String question;
  final int totalAnswered;
  final int correctAnswers;
  final int incorrectAnswers;
  final double mean;
  final double accuracy;

  QuestionAccuracy({
    required this.questionId,
    required this.question,
    required this.totalAnswered,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.mean,
    required this.accuracy,
  });

  factory QuestionAccuracy.fromJson(Map<String, dynamic> json) {
    return QuestionAccuracy(
      questionId: json['question_id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      totalAnswered: json['total_answered'] as int? ?? 0,
      correctAnswers: json['correct_answers'] as int? ?? 0,
      incorrectAnswers: json['incorrect_answers'] as int? ?? 0,
      mean: (json['mean'] as num?)?.toDouble() ?? 0.0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
