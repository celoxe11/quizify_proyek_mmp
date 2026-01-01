import 'package:equatable/equatable.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';

/// Base class for all Admin Quizzes states
abstract class AdminQuizzesState extends Equatable {
  const AdminQuizzesState();

  @override
  List<Object?> get props => [];
}

/// Initial state before quizzes are loaded
class AdminQuizzesInitial extends AdminQuizzesState {}

/// Loading state while fetching quizzes
class AdminQuizzesLoading extends AdminQuizzesState {}

/// State when quizzes are successfully loaded
class AdminQuizzesLoaded extends AdminQuizzesState {
  final List<QuizModel> quizzes;
  final List<QuizModel> filteredQuizzes;
  final String? searchQuery;
  final String? statusFilter;
  final String? categoryFilter;
  final bool isRefreshing;

  const AdminQuizzesLoaded({
    required this.quizzes,
    required this.filteredQuizzes,
    this.searchQuery,
    this.statusFilter,
    this.categoryFilter,
    this.isRefreshing = false,
  });

  /// Get unique categories from quizzes
  List<String> get categories {
    final cats = quizzes
        .where((q) => q.category != null && q.category!.isNotEmpty)
        .map((q) => q.category!)
        .toSet()
        .toList();
    cats.sort();
    return cats;
  }

  /// Create a copy with updated values
  AdminQuizzesLoaded copyWith({
    List<QuizModel>? quizzes,
    List<QuizModel>? filteredQuizzes,
    String? searchQuery,
    String? statusFilter,
    String? categoryFilter,
    bool? isRefreshing,
  }) {
    return AdminQuizzesLoaded(
      quizzes: quizzes ?? this.quizzes,
      filteredQuizzes: filteredQuizzes ?? this.filteredQuizzes,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter,
      categoryFilter: categoryFilter,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
    quizzes,
    filteredQuizzes,
    searchQuery,
    statusFilter,
    categoryFilter,
    isRefreshing,
  ];
}

/// Error state when something goes wrong
class AdminQuizzesError extends AdminQuizzesState {
  final String message;

  const AdminQuizzesError(this.message);

  @override
  List<Object?> get props => [message];
}
