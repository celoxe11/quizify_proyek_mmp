part of 'admin_create_quiz_bloc.dart';

sealed class AdminCreateQuizEvent extends Equatable {
  const AdminCreateQuizEvent();

  @override
  List<Object> get props => [];
}

final class AdminSubmitQuizEvent extends AdminCreateQuizEvent {
  final String? quizId; // Optional, for updating existing quiz
  final String title;
  final String? description;
  final String? category;
  final String? status;
  final String? quizCode;
  final List<QuestionModel> questions;

  const AdminSubmitQuizEvent({
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

final class AdminValidateQuizEvent extends AdminCreateQuizEvent {
  final String title;
  final String description;
  final String category;
  final List<QuestionModel> questions;

  const AdminValidateQuizEvent({
    required this.title,
    required this.description,
    required this.category,
    required this.questions,
  });

  @override
  List<Object> get props => [title, description, category, questions];
}
