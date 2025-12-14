part of 'edit_quiz_bloc.dart';

/// Base class for all EditQuiz states
sealed class EditQuizState extends Equatable {
  const EditQuizState();

  @override
  List<Object?> get props => [];
}

/// Initial state before quiz data is loaded
final class EditQuizInitial extends EditQuizState {}

/// State while loading questions
final class EditQuizLoading extends EditQuizState {}

/// State when quiz is ready for editing
final class EditQuizReady extends EditQuizState {
  final QuizModel originalQuiz;
  final String title;
  final String description;
  final String category;
  final String code;
  final bool isPublic;
  final List<QuestionModel> questions;
  final bool hasChanges;
  final bool isSaving;

  const EditQuizReady({
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
  EditQuizReady copyWith({
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
    return EditQuizReady(
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
final class EditQuizSaved extends EditQuizState {
  final QuizModel updatedQuiz;

  const EditQuizSaved(this.updatedQuiz);

  @override
  List<Object?> get props => [updatedQuiz];
}

/// State when an error occurs
final class EditQuizError extends EditQuizState {
  final String message;

  const EditQuizError(this.message);

  @override
  List<Object?> get props => [message];
}
