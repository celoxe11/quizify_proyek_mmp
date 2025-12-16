import 'package:bloc/bloc.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';
import 'package:quizify_proyek_mmp/data/repositories/teacher_repository.dart';
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
  final TeacherRepositoryImpl _teacherRepository;

  QuizzesBloc({TeacherRepositoryImpl? teacherRepository})
    : _teacherRepository = teacherRepository ?? TeacherRepositoryImpl(),
      super(QuizzesInitial()) {
    on<LoadQuizzesEvent>(_onLoadQuizzes);
    on<RefreshQuizzesEvent>(_onRefreshQuizzes);
    on<SearchQuizzesEvent>(_onSearchQuizzes);
    on<FilterQuizzesEvent>(_onFilterQuizzes);
    on<FilterByCategoryEvent>(_onFilterByCategory);
  }

  /// Load all quizzes
  Future<void> _onLoadQuizzes(
    LoadQuizzesEvent event,
    Emitter<QuizzesState> emit,
  ) async {
    emit(QuizzesLoading());

    try {
      final quizzes = await _teacherRepository.getMyQuizzes();
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
      await Future.delayed(const Duration(seconds: 1));
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
