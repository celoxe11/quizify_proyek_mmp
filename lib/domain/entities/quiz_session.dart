import 'package:equatable/equatable.dart';

class QuizSession extends Equatable {
  final String id;
  final String quizId;
  final String userId;
  final DateTime? startedAt; // Made nullable for empty state flexibility
  final DateTime? endedAt;
  final int? score;
  final String status; // 'in_progress', 'completed', 'expired'

  const QuizSession({
    required this.id,
    required this.quizId,
    required this.userId,
    this.startedAt,
    this.endedAt,
    this.score,
    required this.status,
  });

  /// Empty session for initial states
  static const empty = QuizSession(
    id: '',
    quizId: '',
    userId: '',
    status: 'in_progress',
  );

  bool get isEmpty => this == QuizSession.empty;
  bool get isNotEmpty => this != QuizSession.empty;

  @override
  List<Object?> get props => [
        id,
        quizId,
        userId,
        startedAt,
        endedAt,
        score,
        status,
      ];
}