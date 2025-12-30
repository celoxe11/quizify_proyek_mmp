import 'package:equatable/equatable.dart';

abstract class QuizSessionEvent extends Equatable {
  const QuizSessionEvent();

  @override
  List<Object?> get props => [];
}

class LoadQuizSessionEvent extends QuizSessionEvent {
  final String sessionId;
  final String quizId;

  const LoadQuizSessionEvent({required this.sessionId, required this.quizId});

  @override
  List<Object?> get props => [sessionId, quizId];
}

class SelectAnswerEvent extends QuizSessionEvent {
  final String questionId;
  final String answer;

  const SelectAnswerEvent({required this.questionId, required this.answer});

  @override
  List<Object?> get props => [questionId, answer];
}

class SubmitAnswerEvent extends QuizSessionEvent {
  final String questionId;
  final String answer;

  const SubmitAnswerEvent({required this.questionId, required this.answer});

  @override
  List<Object?> get props => [questionId, answer];
}

class NextQuestionEvent extends QuizSessionEvent {
  const NextQuestionEvent();
}

class PreviousQuestionEvent extends QuizSessionEvent {
  const PreviousQuestionEvent();
}

class GoToQuestionEvent extends QuizSessionEvent {
  final int index;

  const GoToQuestionEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class EndQuizSessionEvent extends QuizSessionEvent {
  const EndQuizSessionEvent();
}

class ResetQuizSessionEvent extends QuizSessionEvent {
  const ResetQuizSessionEvent();
}
