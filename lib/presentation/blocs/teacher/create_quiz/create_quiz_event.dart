part of 'create_quiz_bloc.dart';

sealed class CreateQuizEvent extends Equatable {
  const CreateQuizEvent();

  @override
  List<Object> get props => [];
}

final class SubmitQuizEvent extends CreateQuizEvent {
  final String? quizId; // Optional, for updating existing quiz
  final String title;
  final String? description;
  final String? category;
  final String? status;
  final String? quizCode;
  final List<QuestionModel> questions;

  const SubmitQuizEvent({
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

final class ValidateQuizEvent extends CreateQuizEvent {
  final String title;
  final String description;
  final String category;
  final List<QuestionModel> questions;

  const ValidateQuizEvent({
    required this.title,
    required this.description,
    required this.category,
    required this.questions,
  });

  @override
  List<Object> get props => [title, description, category, questions];
}
