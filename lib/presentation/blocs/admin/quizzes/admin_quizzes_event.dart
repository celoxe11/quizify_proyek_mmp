import 'package:equatable/equatable.dart';

/// Base class for all Admin Quizzes events
abstract class AdminQuizzesEvent extends Equatable {
  const AdminQuizzesEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all quizzes (from all teachers)
class LoadAdminQuizzesEvent extends AdminQuizzesEvent {}

/// Event to refresh quizzes (pull-to-refresh)
class RefreshAdminQuizzesEvent extends AdminQuizzesEvent {}

/// Event to search quizzes
class SearchAdminQuizzesEvent extends AdminQuizzesEvent {
  final String query;

  const SearchAdminQuizzesEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to filter quizzes by status
class FilterAdminQuizzesEvent extends AdminQuizzesEvent {
  final String? status; // 'public', 'private', or null for all

  const FilterAdminQuizzesEvent(this.status);

  @override
  List<Object?> get props => [status];
}

/// Event to filter quizzes by category
class FilterAdminByCategoryEvent extends AdminQuizzesEvent {
  final String? category; // null for all categories

  const FilterAdminByCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}
