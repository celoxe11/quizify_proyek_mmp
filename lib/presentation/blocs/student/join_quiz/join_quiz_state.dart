import 'package:equatable/equatable.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';

abstract class JoinQuizState extends Equatable {
  const JoinQuizState();

  @override
  List<Object?> get props => [];
}

class JoinQuizInitial extends JoinQuizState {
  const JoinQuizInitial();
}

class JoinQuizLoading extends JoinQuizState {
  const JoinQuizLoading();
}

class JoinQuizSuccess extends JoinQuizState {
  final String sessionId;
  final String quizId;
  final String message;

  const JoinQuizSuccess({
    required this.sessionId,
    required this.quizId,
    this.message = 'Quiz berhasil dimulai',
  });

  @override
  List<Object?> get props => [sessionId, quizId, message];
}

class QuizInfoLoaded extends JoinQuizState {
  final QuizModel quiz;

  const QuizInfoLoaded(this.quiz);

  @override
  List<Object?> get props => [quiz];
}

class JoinQuizError extends JoinQuizState {
  final String message;

  const JoinQuizError(this.message);

  @override
  List<Object?> get props => [message];
}
