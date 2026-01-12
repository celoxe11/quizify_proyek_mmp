import '../../domain/entities/quiz_session.dart';

class QuizSessionModel extends QuizSession {
  const QuizSessionModel({
    required super.id,
    required super.quizId,
    required super.userId,
    required super.startedAt,
    super.endedAt,
    super.score,
    required super.status, // 'in_progress', 'completed', 'expired'
  });

  factory QuizSessionModel.fromJson(Map<String, dynamic> json) {
    return QuizSessionModel(
      id: json['id'] as String,
      quizId: json['quiz_id'] as String,
      userId: json['user_id'] as String,
      startedAt: DateTime.parse(json['started_at']),
      endedAt: json['ended_at'] != null 
          ? DateTime.parse(json['ended_at']) 
          : null,
      score: json['score'] != null 
          ? int.tryParse(json['score'].toString()) 
          : null,
      status: json['status'] as String? ?? 'in_progress',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'user_id': userId,
      'started_at': startedAt?.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'score': score,
      'status': status,
    };
  }

  factory QuizSessionModel.fromEntity(QuizSession session) {
    return QuizSessionModel(
      id: session.id,
      quizId: session.quizId,
      userId: session.userId,
      startedAt: session.startedAt,
      endedAt: session.endedAt,
      score: session.score,
      status: session.status,
    );
  }
}