import 'package:equatable/equatable.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_session_model.dart';
import 'package:quizify_proyek_mmp/data/models/submission_answer_model.dart';

/// Base class for all StudentAnswers states
abstract class StudentAnswersState extends Equatable {
  const StudentAnswersState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class StudentAnswersInitial extends StudentAnswersState {}

/// Loading state
class StudentAnswersLoading extends StudentAnswersState {}

/// Loaded state with session and answers
class StudentAnswersLoaded extends StudentAnswersState {
  final QuizSessionModel session;
  final List<SubmissionAnswerModel> answers;

  const StudentAnswersLoaded({
    required this.session,
    required this.answers,
  });

  @override
  List<Object?> get props => [session, answers];
}

/// Error state
class StudentAnswersError extends StudentAnswersState {
  final String message;

  const StudentAnswersError({required this.message});

  @override
  List<Object?> get props => [message];
}
