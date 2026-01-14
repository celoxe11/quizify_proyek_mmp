import 'package:equatable/equatable.dart';

abstract class QuizDetailEvent extends Equatable {
  const QuizDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Load quiz detail by ID
class LoadQuizDetailEvent extends QuizDetailEvent {
  final String quizId;

  const LoadQuizDetailEvent(this.quizId);

  @override
  List<Object?> get props => [quizId];
}

/// Start quiz by code
class StartQuizDetailEvent extends QuizDetailEvent {
  final String quizCode;
  final String quizId;

  const StartQuizDetailEvent(this.quizCode, this.quizId);

  @override
  List<Object?> get props => [quizCode, quizId];
}
