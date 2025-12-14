import 'package:equatable/equatable.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';

/// Base class for all Quizzes states
abstract class QuizzesState extends Equatable {
  const QuizzesState();

  @override
  List<Object?> get props => [];
}

/// Initial state before quizzes are loaded
class QuizzesInitial extends QuizzesState {}

/// Loading state while fetching quizzes
class QuizzesLoading extends QuizzesState {}

/// State when quizzes are successfully loaded
class QuizzesLoaded extends QuizzesState {
  final List<QuizModel> quizzes;
  final List<QuizModel> filteredQuizzes;
  final String? searchQuery;
  final String? statusFilter;
  final String? categoryFilter;
  final bool isRefreshing;

  const QuizzesLoaded({
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
  QuizzesLoaded copyWith({
    List<QuizModel>? quizzes,
    List<QuizModel>? filteredQuizzes,
    String? searchQuery,
    String? statusFilter,
    String? categoryFilter,
    bool? isRefreshing,
  }) {
    return QuizzesLoaded(
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
class QuizzesError extends QuizzesState {
  final String message;

  const QuizzesError(this.message);

  @override
  List<Object?> get props => [message];
}
