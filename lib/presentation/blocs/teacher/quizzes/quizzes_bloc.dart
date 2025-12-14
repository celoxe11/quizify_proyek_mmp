import 'package:bloc/bloc.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/quizzes/quizzes_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/quizzes/quizzes_state.dart';

/// BLoC for managing Quizzes page state
///
/// Handles loading, filtering, searching, and deleting quizzes.
///
/// Usage:
/// ```dart
/// BlocProvider(
///   create: (context) => QuizzesBloc()..add(LoadQuizzesEvent()),
///   child: TeacherQuizPage(),
/// )
/// ```
class QuizzesBloc extends Bloc<QuizzesEvent, QuizzesState> {
  // TODO: Inject repositories when implementing backend integration
  // final QuizRepository quizRepository;

  QuizzesBloc() : super(QuizzesInitial()) {
    on<LoadQuizzesEvent>(_onLoadQuizzes);
    on<RefreshQuizzesEvent>(_onRefreshQuizzes);
    on<SearchQuizzesEvent>(_onSearchQuizzes);
    on<FilterQuizzesEvent>(_onFilterQuizzes);
    on<FilterByCategoryEvent>(_onFilterByCategory);
    on<DeleteQuizFromListEvent>(_onDeleteQuiz);
  }

  /// Load all quizzes
  Future<void> _onLoadQuizzes(
    LoadQuizzesEvent event,
    Emitter<QuizzesState> emit,
  ) async {
    emit(QuizzesLoading());

    try {
      // TODO: Replace with actual backend call
      // final quizzes = await quizRepository.getAll();

      // Simulated delay for development
      await Future.delayed(const Duration(milliseconds: 500));

      // TODO: Replace with actual data from API
      final quizzes = [
        QuizModel(
          id: '1',
          title: 'Math Quiz 101',
          description: 'Basic algebra and geometry questions',
          status: 'public',
          category: 'Mathematics',
          createdAt: DateTime(2024, 11, 15),
        ),
        QuizModel(
          id: '2',
          title: 'Science Challenge',
          description: 'Physics and Chemistry fundamentals',
          status: 'public',
          category: 'Science',
          createdAt: DateTime(2024, 11, 20),
        ),
        QuizModel(
          id: '3',
          title: 'History Trivia',
          description: 'World War II historical events',
          status: 'private',
          category: 'History',
          createdAt: DateTime(2024, 11, 22),
        ),
        QuizModel(
          id: '4',
          title: 'English Grammar',
          description: 'Advanced grammar rules and usage',
          status: 'public',
          category: 'English',
          createdAt: DateTime(2024, 11, 25),
        ),
        QuizModel(
          id: '5',
          title: 'Programming Basics',
          description: 'Introduction to programming concepts',
          status: 'public',
          category: 'Technology',
          createdAt: DateTime(2024, 11, 28),
        ),
      ];

      emit(QuizzesLoaded(quizzes: quizzes, filteredQuizzes: quizzes));
    } catch (e) {
      emit(QuizzesError('Failed to load quizzes: ${e.toString()}'));
    }
  }

  /// Refresh quizzes
  Future<void> _onRefreshQuizzes(
    RefreshQuizzesEvent event,
    Emitter<QuizzesState> emit,
  ) async {
    final currentState = state;
    if (currentState is QuizzesLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
    }

    try {
      // TODO: Replace with actual backend call
      await Future.delayed(const Duration(milliseconds: 500));

      // Re-fetch quizzes (in real app, this would be an API call)
      add(LoadQuizzesEvent());
    } catch (e) {
      emit(QuizzesError('Failed to refresh quizzes: ${e.toString()}'));
    }
  }

  /// Search quizzes by query
  void _onSearchQuizzes(SearchQuizzesEvent event, Emitter<QuizzesState> emit) {
    final currentState = state;
    if (currentState is! QuizzesLoaded) return;

    final query = event.query.toLowerCase().trim();

    if (query.isEmpty) {
      // Reset to all quizzes with current filters
      emit(
        currentState.copyWith(
          searchQuery: null,
          filteredQuizzes: _applyFilters(
            currentState.quizzes,
            null,
            currentState.statusFilter,
            currentState.categoryFilter,
          ),
        ),
      );
    } else {
      final filtered = _applyFilters(
        currentState.quizzes,
        query,
        currentState.statusFilter,
        currentState.categoryFilter,
      );

      emit(
        currentState.copyWith(searchQuery: query, filteredQuizzes: filtered),
      );
    }
  }

  /// Filter quizzes by status
  void _onFilterQuizzes(FilterQuizzesEvent event, Emitter<QuizzesState> emit) {
    final currentState = state;
    if (currentState is! QuizzesLoaded) return;

    final filtered = _applyFilters(
      currentState.quizzes,
      currentState.searchQuery,
      event.status,
      currentState.categoryFilter,
    );

    emit(
      currentState.copyWith(
        statusFilter: event.status,
        filteredQuizzes: filtered,
      ),
    );
  }

  /// Filter quizzes by category
  void _onFilterByCategory(
    FilterByCategoryEvent event,
    Emitter<QuizzesState> emit,
  ) {
    final currentState = state;
    if (currentState is! QuizzesLoaded) return;

    final filtered = _applyFilters(
      currentState.quizzes,
      currentState.searchQuery,
      currentState.statusFilter,
      event.category,
    );

    emit(
      currentState.copyWith(
        categoryFilter: event.category,
        filteredQuizzes: filtered,
      ),
    );
  }

  /// Delete a quiz
  Future<void> _onDeleteQuiz(
    DeleteQuizFromListEvent event,
    Emitter<QuizzesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! QuizzesLoaded) return;

    try {
      // TODO: Replace with actual backend call
      // await quizRepository.delete(event.quizId);

      await Future.delayed(const Duration(milliseconds: 300));

      // Remove from local list
      final updatedQuizzes = currentState.quizzes
          .where((q) => q.id != event.quizId)
          .toList();

      final updatedFiltered = currentState.filteredQuizzes
          .where((q) => q.id != event.quizId)
          .toList();

      emit(
        currentState.copyWith(
          quizzes: updatedQuizzes,
          filteredQuizzes: updatedFiltered,
        ),
      );
    } catch (e) {
      emit(QuizzesError('Failed to delete quiz: ${e.toString()}'));
    }
  }

  /// Apply all filters to the quizzes list
  List<QuizModel> _applyFilters(
    List<QuizModel> quizzes,
    String? searchQuery,
    String? statusFilter,
    String? categoryFilter,
  ) {
    var filtered = List<QuizModel>.from(quizzes);

    // Apply search filter
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered.where((quiz) {
        return quiz.title.toLowerCase().contains(searchQuery) ||
            (quiz.description?.toLowerCase().contains(searchQuery) ?? false) ||
            (quiz.category?.toLowerCase().contains(searchQuery) ?? false);
      }).toList();
    }

    // Apply status filter
    if (statusFilter != null && statusFilter.isNotEmpty) {
      filtered = filtered.where((quiz) {
        return quiz.status.toLowerCase() == statusFilter.toLowerCase();
      }).toList();
    }

    // Apply category filter
    if (categoryFilter != null && categoryFilter.isNotEmpty) {
      filtered = filtered.where((quiz) {
        return quiz.category?.toLowerCase() == categoryFilter.toLowerCase();
      }).toList();
    }

    return filtered;
  }
}
