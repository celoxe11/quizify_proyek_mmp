part of 'admin_edit_quiz_bloc.dart';

/// Base class for all AdminEditQuiz states
sealed class AdminEditQuizState extends Equatable {
  const AdminEditQuizState();

  @override
  List<Object?> get props => [];
}

/// Initial state before quiz data is loaded
final class AdminEditQuizInitial extends AdminEditQuizState {}

/// State while loading questions
final class AdminEditQuizLoading extends AdminEditQuizState {}

/// State when quiz is ready for editing
final class AdminEditQuizReady extends AdminEditQuizState {
  final QuizModel originalQuiz;
  final String title;
  final String description;
  final String category;
  final String code;
  final bool isPublic;
  final List<QuestionModel> questions;
  final bool hasChanges;
  final bool isSaving;

  const AdminEditQuizReady({
    required this.originalQuiz,
    required this.title,
    required this.description,
    required this.category,
    required this.code,
    required this.isPublic,
    required this.questions,
    this.hasChanges = false,
    this.isSaving = false,
  });

  /// Create a copy with updated values
  AdminEditQuizReady copyWith({
    QuizModel? originalQuiz,
    String? title,
    String? description,
    String? category,
    String? code,
    bool? isPublic,
    List<QuestionModel>? questions,
    bool? hasChanges,
    bool? isSaving,
  }) {
    return AdminEditQuizReady(
      originalQuiz: originalQuiz ?? this.originalQuiz,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      code: code ?? this.code,
      isPublic: isPublic ?? this.isPublic,
      questions: questions ?? this.questions,
      hasChanges: hasChanges ?? this.hasChanges,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [
    originalQuiz,
    title,
    description,
    category,
    code,
    isPublic,
    questions,
    hasChanges,
    isSaving,
  ];
}

/// State when quiz is successfully saved
final class AdminEditQuizSaved extends AdminEditQuizState {
  final QuizModel updatedQuiz;

  const AdminEditQuizSaved(this.updatedQuiz);

  @override
  List<Object?> get props => [updatedQuiz];
}

/// State when an error occurs
final class AdminEditQuizError extends AdminEditQuizState {
  final String message;

  const AdminEditQuizError(this.message);

  @override
  List<Object?> get props => [message];
}
