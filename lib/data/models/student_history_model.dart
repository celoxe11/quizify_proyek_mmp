class StudentHistoryModel {
  final String id; // Session ID
  final String quizTitle;
  final int score;
  final int correct;
  final int incorrect;
  final DateTime finishedAt;

  StudentHistoryModel({
    required this.id,
    required this.quizTitle,
    required this.score,
    required this.correct,
    required this.incorrect,
    required this.finishedAt,
  });

  factory StudentHistoryModel.fromJson(Map<String, dynamic> json) {
    return StudentHistoryModel(
      id: json['id']?.toString() ?? '',
      quizTitle: json['quiz_title'] ?? 'Unknown Quiz',
      score: int.tryParse(json['score']?.toString() ?? '0') ?? 0,
      correct: int.tryParse(json['correct']?.toString() ?? '0') ?? 0,
      incorrect: int.tryParse(json['incorrect']?.toString() ?? '0') ?? 0,
      finishedAt: DateTime.tryParse(json['finished_at'] ?? '') ?? DateTime.now(),
    );
  }
}