import 'package:equatable/equatable.dart';

/// Base class for all Quizzes events
abstract class QuizzesEvent extends Equatable {
  const QuizzesEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all quizzes for the teacher
class LoadQuizzesEvent extends QuizzesEvent {}

/// Event to refresh quizzes (pull-to-refresh)
class RefreshQuizzesEvent extends QuizzesEvent {}

/// Event to search quizzes
class SearchQuizzesEvent extends QuizzesEvent {
  final String query;

  const SearchQuizzesEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to filter quizzes by status
class FilterQuizzesEvent extends QuizzesEvent {
  final String? status; // 'public', 'private', or null for all

  const FilterQuizzesEvent(this.status);

  @override
  List<Object?> get props => [status];
}

/// Event to filter quizzes by category
class FilterByCategoryEvent extends QuizzesEvent {
  final String? category; // null for all categories

  const FilterByCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}
