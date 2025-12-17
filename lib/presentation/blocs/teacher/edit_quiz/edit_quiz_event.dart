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

/// Event when the title is changed
class TitleChangedEvent extends EditQuizEvent {
  final String title;

  const TitleChangedEvent(this.title);

  @override
  List<Object?> get props => [title];
}

/// Event when the description is changed
class DescriptionChangedEvent extends EditQuizEvent {
  final String description;

  const DescriptionChangedEvent(this.description);

  @override
  List<Object?> get props => [description];
}

/// Event when the category is changed
class CategoryChangedEvent extends EditQuizEvent {
  final String category;

  const CategoryChangedEvent(this.category);

  @override
  List<Object?> get props => [category];
}

/// Event when the public status is toggled
class TogglePublicEvent extends EditQuizEvent {
  final bool isPublic;

  const TogglePublicEvent(this.isPublic);

  @override
  List<Object?> get props => [isPublic];
}

/// Event to add a new question
class AddQuestionEvent extends EditQuizEvent {}

/// Event to update a question at an index
class UpdateQuestionEvent extends EditQuizEvent {
  final int index;
  final QuestionModel question;

  const UpdateQuestionEvent({required this.index, required this.question});

  @override
  List<Object?> get props => [index, question];
}

/// Event to remove a question at an index
class RemoveQuestionEvent extends EditQuizEvent {
  final int index;

  const RemoveQuestionEvent(this.index);

  @override
  List<Object?> get props => [index];
}

/// Event to save the quiz
class SaveQuizEvent extends EditQuizEvent {}

/// Event to mark that changes have been made
class MarkChangesEvent extends EditQuizEvent {}
