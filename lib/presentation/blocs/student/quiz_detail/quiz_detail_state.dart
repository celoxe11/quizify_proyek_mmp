import 'package:equatable/equatable.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';

abstract class QuizDetailState extends Equatable {
  const QuizDetailState();

  @override
  List<Object?> get props => [];
}

class QuizDetailInitial extends QuizDetailState {
  const QuizDetailInitial();
}

class QuizDetailLoading extends QuizDetailState {
  const QuizDetailLoading();
}

class QuizDetailLoaded extends QuizDetailState {
  final QuizModel quiz;

  const QuizDetailLoaded(this.quiz);

  @override
  List<Object?> get props => [quiz];
}

class QuizSessionStarted extends QuizDetailState {
  final String sessionId;
  final String quizId;

  const QuizSessionStarted(this.sessionId, this.quizId);

  @override
  List<Object?> get props => [sessionId, quizId];
}

class QuizDetailError extends QuizDetailState {
  final String message;

  const QuizDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
