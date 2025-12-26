part of 'edit_quiz_bloc.dart';

/// Base class for all EditQuiz events
sealed class EditQuizEvent extends Equatable {
  const EditQuizEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize the edit quiz page with quiz and questions
class InitializeEditQuizEvent extends EditQuizEvent {
  final QuizModel quiz;
  final List<QuestionModel> questions;

  const InitializeEditQuizEvent({required this.quiz, required this.questions});

  @override
  List<Object?> get props => [quiz, questions];
}

/// Event to save the quiz
class SaveQuizEvent extends EditQuizEvent {
  final String? quizId; // Optional, for updating existing quiz
  final String title;
  final String? description;
  final String? category;
  final String? status;
  final String? quizCode;
  final List<QuestionModel> questions;

  const SaveQuizEvent({
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
class MarkChangesEvent extends EditQuizEvent {}
