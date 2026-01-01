import 'package:equatable/equatable.dart';

/// Base class for all QuizDetail events
abstract class QuizDetailEvent extends Equatable {
  const QuizDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load quiz details including questions
class LoadQuizDetailEvent extends QuizDetailEvent {
  final String quizId;

  const LoadQuizDetailEvent({required this.quizId});

  @override
  List<Object?> get props => [quizId];
}

/// Event to load students who attended the quiz
class LoadStudentsEvent extends QuizDetailEvent {
  final String quizId;

  const LoadStudentsEvent({required this.quizId});

  @override
  List<Object?> get props => [quizId];
}

/// Event to load accuracy results (premium only)
class LoadAccuracyResultsEvent extends QuizDetailEvent {
  final String quizId;

  const LoadAccuracyResultsEvent({required this.quizId});

  @override
  List<Object?> get props => [quizId];
}

/// Event to delete the quiz
class DeleteQuizEvent extends QuizDetailEvent {
  final String quizId;

  const DeleteQuizEvent({required this.quizId});

  @override
  List<Object?> get props => [quizId];
}

/// Event to refresh all data
class RefreshQuizDetailEvent extends QuizDetailEvent {
  final String quizId;

  const RefreshQuizDetailEvent({required this.quizId});

  @override
  List<Object?> get props => [quizId];
}
