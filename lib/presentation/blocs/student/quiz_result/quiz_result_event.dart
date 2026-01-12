import 'package:equatable/equatable.dart';

abstract class QuizResultEvent extends Equatable {
  const QuizResultEvent();

  @override
  List<Object?> get props => [];
}

class LoadQuizResultEvent extends QuizResultEvent {
  final String sessionId;

  const LoadQuizResultEvent(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class LoadQuizHistoryEvent extends QuizResultEvent {
  const LoadQuizHistoryEvent();
}

class ResetQuizResultEvent extends QuizResultEvent {
  const ResetQuizResultEvent();
}
