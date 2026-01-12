import 'package:equatable/equatable.dart';

/// Base class for all StudentAnswers events
abstract class StudentAnswersEvent extends Equatable {
  const StudentAnswersEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load student's answers for a quiz
class LoadStudentAnswersEvent extends StudentAnswersEvent {
  final String studentId;
  final String quizId;

  const LoadStudentAnswersEvent({
    required this.studentId,
    required this.quizId,
  });

  @override
  List<Object?> get props => [studentId, quizId];
}
