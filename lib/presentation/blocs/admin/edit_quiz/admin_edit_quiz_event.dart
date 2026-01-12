part of 'admin_edit_quiz_bloc.dart';

/// Base class for all AdminEditQuiz events
sealed class AdminEditQuizEvent extends Equatable {
  const AdminEditQuizEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize the edit quiz page with quiz and questions
class AdminInitializeEditQuizEvent extends AdminEditQuizEvent {
  final QuizModel quiz;
  final List<QuestionModel> questions;

  const AdminInitializeEditQuizEvent({
    required this.quiz,
    required this.questions,
  });

  @override
  List<Object?> get props => [quiz, questions];
}

/// Event to save the quiz
class AdminSaveQuizEvent extends AdminEditQuizEvent {
  final String? quizId; // Optional, for updating existing quiz
  final String title;
  final String? description;
  final String? category;
  final String? status;
  final String? quizCode;
  final List<QuestionModel> questions;

  const AdminSaveQuizEvent({
    this.quizId,
    required this.title,
    this.description,
    this.category,
    this.status,
    this.quizCode,
    required this.questions,
  });

  @override
  List<Object> get props => [
    if (quizId != null) quizId!,
    title,
    if (description != null) description!,
    if (category != null) category!,
    if (status != null) status!,
    if (quizCode != null) quizCode!,
    questions,
  ];
}

/// Event to mark that changes have been made
class AdminMarkChangesEvent extends AdminEditQuizEvent {}
