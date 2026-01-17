import 'package:equatable/equatable.dart';

abstract class TeacherHomeEvent extends Equatable {
  const TeacherHomeEvent();

  @override
  List<Object?> get props => [];
}

/// Load public quizzes from API
class LoadPublicQuizzesEvent extends TeacherHomeEvent {
  const LoadPublicQuizzesEvent();
}

/// Search quizzes by keyword
class SearchQuizzesEvent extends TeacherHomeEvent {
  final String query;

  const SearchQuizzesEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filter quizzes by category
class FilterByCategory extends TeacherHomeEvent {
  final String category;

  const FilterByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// Filter quizzes by difficulty
class FilterByDifficulty extends TeacherHomeEvent {
  final String difficulty;

  const FilterByDifficulty(this.difficulty);

  @override
  List<Object?> get props => [difficulty];
}

/// Reset filters and reload all quizzes
class ResetFiltersEvent extends TeacherHomeEvent {
  const ResetFiltersEvent();
}

/// Refresh the quiz list
class RefreshQuizzesEvent extends TeacherHomeEvent {
  const RefreshQuizzesEvent();
}

/// Fetch quiz info by quiz code
class FetchQuizByCodeEvent extends TeacherHomeEvent {
  final String quizCode;

  const FetchQuizByCodeEvent(this.quizCode);

  @override
  List<Object?> get props => [quizCode];
}

/// Start quiz by code to get session
class StartQuizEvent extends TeacherHomeEvent {
  final String quizCode;
  final String quizId;

  const StartQuizEvent(this.quizCode, this.quizId);

  @override
  List<Object?> get props => [quizCode, quizId];
}
