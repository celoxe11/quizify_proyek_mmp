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
  final bool isResuming;
  final Map<String, String> answeredQuestions; // question_id -> selected_answer
  final int currentQuestionIndex;

  const JoinQuizSuccess({
    required this.sessionId,
    required this.quizId,
    this.message = 'Quiz berhasil dimulai',
    this.isResuming = false,
    this.answeredQuestions = const {},
    this.currentQuestionIndex = 0,
  });

  @override
  List<Object?> get props => [
    sessionId,
    quizId,
    message,
    isResuming,
    answeredQuestions,
    currentQuestionIndex,
  ];
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
