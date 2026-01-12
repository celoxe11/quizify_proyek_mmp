import 'package:bloc/bloc.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';
import 'package:quizify_proyek_mmp/domain/repositories/admin_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/quizzes/admin_quizzes_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/quizzes/admin_quizzes_state.dart';

/// BLoC for managing Admin Quizzes page state
///
/// Handles loading, filtering, searching all quizzes in the system.
/// Unlike teacher quizzes, admin can see ALL quizzes from all teachers.
///
/// Usage:
/// ```dart
/// BlocProvider(
///   create: (context) => AdminQuizzesBloc(
///     adminRepository: context.read<AdminRepository>(),
///   )..add(LoadAdminQuizzesEvent()),
///   child: AdminQuizPage(),
/// )
/// ```
class AdminQuizzesBloc extends Bloc<AdminQuizzesEvent, AdminQuizzesState> {
  final AdminRepository _adminRepository;

  AdminQuizzesBloc({required AdminRepository adminRepository})
    : _adminRepository = adminRepository,
      super(AdminQuizzesInitial()) {
    on<LoadAdminQuizzesEvent>(_onLoadQuizzes);
    on<RefreshAdminQuizzesEvent>(_onRefreshQuizzes);
    on<SearchAdminQuizzesEvent>(_onSearchQuizzes);
    on<FilterAdminQuizzesEvent>(_onFilterQuizzes);
    on<FilterAdminByCategoryEvent>(_onFilterByCategory);
  }

  /// Load all quizzes from all teachers
  Future<void> _onLoadQuizzes(
    LoadAdminQuizzesEvent event,
    Emitter<AdminQuizzesState> emit,
  ) async {
    emit(AdminQuizzesLoading());

    try {
      final quizzes = await _adminRepository.fetchAllQuizzes();
      // Convert List<Quiz> to List<QuizModel> if needed
      final quizModels = quizzes.map((quiz) {
        if (quiz is QuizModel) {
          return quiz;
        } else {
          // Convert Quiz entity to QuizModel
          return QuizModel(
            id: quiz.id,
            title: quiz.title,
            description: quiz.description,
            category: quiz.category,
            status: quiz.status,
            quizCode: quiz.quizCode,
            createdAt: quiz.createdAt,
            updatedAt: quiz.updatedAt,
            createdBy: quiz.createdBy,
          );
        }
      }).toList();

      emit(
        AdminQuizzesLoaded(quizzes: quizModels, filteredQuizzes: quizModels),
      );
    } catch (e) {
      emit(AdminQuizzesError('Failed to load quizzes: ${e.toString()}'));
    }
  }

  /// Refresh quizzes
  Future<void> _onRefreshQuizzes(
    RefreshAdminQuizzesEvent event,
    Emitter<AdminQuizzesState> emit,
  ) async {
    final currentState = state;
    if (currentState is AdminQuizzesLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
    }

    try {
      await Future.delayed(const Duration(seconds: 1));
      add(LoadAdminQuizzesEvent());
    } catch (e) {
      emit(AdminQuizzesError('Failed to refresh quizzes: ${e.toString()}'));
    }
  }

  /// Search quizzes by query
  void _onSearchQuizzes(
    SearchAdminQuizzesEvent event,
    Emitter<AdminQuizzesState> emit,
  ) {
    final currentState = state;
    if (currentState is! AdminQuizzesLoaded) return;

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
  void _onFilterQuizzes(
    FilterAdminQuizzesEvent event,
    Emitter<AdminQuizzesState> emit,
  ) {
    final currentState = state;
    if (currentState is! AdminQuizzesLoaded) return;

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
    FilterAdminByCategoryEvent event,
    Emitter<AdminQuizzesState> emit,
  ) {
    final currentState = state;
    if (currentState is! AdminQuizzesLoaded) return;

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
