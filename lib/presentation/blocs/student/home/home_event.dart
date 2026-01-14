import 'package:equatable/equatable.dart';

abstract class StudentHomeEvent extends Equatable {
  const StudentHomeEvent();

  @override
  List<Object?> get props => [];
}

/// Load public quizzes from API
class LoadPublicQuizzesEvent extends StudentHomeEvent {
  const LoadPublicQuizzesEvent();
}

/// Search quizzes by keyword
class SearchQuizzesEvent extends StudentHomeEvent {
  final String query;

  const SearchQuizzesEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filter quizzes by category
class FilterByCategory extends StudentHomeEvent {
  final String category;

  const FilterByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// Filter quizzes by difficulty
class FilterByDifficulty extends StudentHomeEvent {
  final String difficulty;

  const FilterByDifficulty(this.difficulty);

  @override
  List<Object?> get props => [difficulty];
}

/// Reset filters and reload all quizzes
class ResetFiltersEvent extends StudentHomeEvent {
  const ResetFiltersEvent();
}

/// Refresh the quiz list
class RefreshQuizzesEvent extends StudentHomeEvent {
  const RefreshQuizzesEvent();
}

/// Fetch quiz info by quiz code
class FetchQuizByCodeEvent extends StudentHomeEvent {
  final String quizCode;

  const FetchQuizByCodeEvent(this.quizCode);

  @override
  List<Object?> get props => [quizCode];
}

/// Start quiz by code to get session
class StartQuizEvent extends StudentHomeEvent {
  final String quizCode;
  final String quizId;

  const StartQuizEvent(this.quizCode, this.quizId);

  @override
  List<Object?> get props => [quizCode, quizId];
}
