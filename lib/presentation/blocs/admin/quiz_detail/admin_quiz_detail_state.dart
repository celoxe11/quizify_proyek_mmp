part of 'admin_quiz_detail_bloc.dart';

/// Base class for all AdminQuizDetail states
abstract class AdminQuizDetailState extends Equatable {
  const AdminQuizDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class AdminQuizDetailInitial extends AdminQuizDetailState {}

/// Loading state while fetching quiz data
class AdminQuizDetailLoading extends AdminQuizDetailState {}

/// State when quiz data is successfully loaded
class AdminQuizDetailLoaded extends AdminQuizDetailState {
  final List<Question> questions; // Using Entity Question
  final String quizId;

  const AdminQuizDetailLoaded({required this.questions, required this.quizId});

  /// Create a copy with updated values
  AdminQuizDetailLoaded copyWith({List<Question>? questions, String? quizId}) {
    return AdminQuizDetailLoaded(
      questions: questions ?? this.questions,
      quizId: quizId ?? this.quizId,
    );
  }

  @override
  List<Object?> get props => [questions, quizId];
}

/// Error state when something goes wrong
class AdminQuizDetailError extends AdminQuizDetailState {
  final String message;

  const AdminQuizDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State when question is successfully deleted
class AdminQuestionDeleted extends AdminQuizDetailState {}
