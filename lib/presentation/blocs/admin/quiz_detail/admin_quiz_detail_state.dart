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

class AdminQuizDetailLoaded extends AdminQuizDetailState {
  final QuizModel quiz;
  final List<QuestionModel> questions;

  const AdminQuizDetailLoaded({required this.quiz, this.questions = const []});

  /// Create a copy with updated values
  AdminQuizDetailLoaded copyWith({
    QuizModel? quiz,
    List<QuestionModel>? questions,
    int? selectedTabIndex,
    bool? isPremiumUser,
  }) {
    return AdminQuizDetailLoaded(
      quiz: quiz ?? this.quiz,
      questions: questions ?? this.questions,
    );
  }

  @override
  List<Object?> get props => [quiz, questions];
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

class AdminQuizDetailDeleted extends AdminQuizDetailState {}

// === Students States ===
class AdminStudentsLoading extends AdminQuizDetailState {}

class AdminStudentsLoaded extends AdminQuizDetailState {
  final List<Map<String, dynamic>>
  students; // List of students who took the quiz and their scores

  const AdminStudentsLoaded({required this.students});
  @override
  List<Object?> get props => [students];
}

class AdminStudentsError extends AdminQuizDetailState {
  final String message;

  const AdminStudentsError({required this.message});

  @override
  List<Object?> get props => [message];
}

// === Accuracy States ===
class AdminAccuracyLoading extends AdminQuizDetailState {}

class AdminAccuracyLoaded extends AdminQuizDetailState {
  final List<QuestionAccuracy> accuracyResults; // Accuracy results data

  const AdminAccuracyLoaded({required this.accuracyResults});

  @override
  List<Object?> get props => [accuracyResults];
}

class AdminAccuracyError extends AdminQuizDetailState {
  final String message;

  const AdminAccuracyError({required this.message});

  @override
  List<Object?> get props => [message];
}
