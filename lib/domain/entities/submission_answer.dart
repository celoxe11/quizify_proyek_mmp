import 'package:equatable/equatable.dart';

class SubmissionAnswer extends Equatable {
  final String id;
  final String quizSessionId;
  final String questionId;
  final String selectedAnswer;
  final bool isCorrect;
  final DateTime? answeredAt;

  const SubmissionAnswer({
    required this.id,
    required this.quizSessionId,
    required this.questionId,
    required this.selectedAnswer,
    required this.isCorrect,
    this.answeredAt,
  });

  @override
  List<Object?> get props => [
    id,
    quizSessionId,
    questionId,
    selectedAnswer,
    isCorrect,
    answeredAt,
  ];
}
