import 'package:equatable/equatable.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_session_model.dart';
import 'package:quizify_proyek_mmp/data/models/submission_answer_model.dart';

abstract class QuizResultState extends Equatable {
  const QuizResultState();

  @override
  List<Object?> get props => [];
}

class QuizResultInitial extends QuizResultState {
  const QuizResultInitial();
}

class QuizResultLoading extends QuizResultState {
  const QuizResultLoading();
}

class QuizResultLoaded extends QuizResultState {
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final List<SubmissionAnswerModel> submissionAnswers;
  final String sessionId;

  const QuizResultLoaded({
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.submissionAnswers,
    required this.sessionId,
  });

  double get percentage =>
      totalQuestions > 0 ? (score / totalQuestions) * 100 : 0.0;

  bool get isPassed => percentage >= 60.0;

  @override
  List<Object?> get props => [
    score,
    totalQuestions,
    correctAnswers,
    incorrectAnswers,
    submissionAnswers,
    sessionId,
  ];
}

class QuizHistoryLoaded extends QuizResultState {
  final List<QuizSessionModel> sessions;

  const QuizHistoryLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

class QuizResultError extends QuizResultState {
  final String message;

  const QuizResultError(this.message);

  @override
  List<Object?> get props => [message];
}
