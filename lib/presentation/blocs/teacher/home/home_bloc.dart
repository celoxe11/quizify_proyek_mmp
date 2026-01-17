import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';
import 'package:quizify_proyek_mmp/data/repositories/student_repository.dart';
import 'package:quizify_proyek_mmp/domain/repositories/teacher_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/home/home_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/home/home_state.dart';

class TeacherHomeBloc extends Bloc<TeacherHomeEvent, TeacherHomeState> {
  final TeacherRepository teacherRepository;
  final StudentRepository studentRepository;
  List<QuizModel> _allQuizzes = [];

  TeacherHomeBloc(this.teacherRepository, this.studentRepository)
    : super(TeacherHomeInitial()) {
    on<LoadPublicQuizzesEvent>(_onLoadPublicQuizzes);
    on<SearchQuizzesEvent>(_onSearchQuizzes);
    on<FilterByCategory>(_onFilterByCategory);
    on<FilterByDifficulty>(_onFilterByDifficulty);
    on<ResetFiltersEvent>(_onResetFilters);
    on<RefreshQuizzesEvent>(_onRefreshQuizzes);
    on<FetchQuizByCodeEvent>(_onFetchQuizByCode);
    on<StartQuizEvent>(_onStartQuiz);
  }

  /// Load all public quizzes from API
  Future<void> _onLoadPublicQuizzes(
    LoadPublicQuizzesEvent event,
    Emitter<TeacherHomeState> emit,
  ) async {
    emit(const TeacherHomeLoading());

    try {
      print('🔄 [TeacherHomeBloc] Loading public quizzes...');
      final quizzes = await studentRepository.fetchPublicQuizzes();
      _allQuizzes = quizzes;
      print(
        '✅ [TeacherHomeBloc] Successfully loaded ${quizzes.length} quizzes',
      );

      emit(TeacherHomeLoaded(quizzes: quizzes, filteredQuizzes: quizzes));
    } catch (e, stackTrace) {
      print('❌ [TeacherHomeBloc] Error loading quizzes: $e');
      print('Stack trace: $stackTrace');
      emit(TeacherHomeError('Failed to load quizzes: ${e.toString()}'));
    }
  }

  /// Search quizzes by title or keyword
  Future<void> _onSearchQuizzes(
    SearchQuizzesEvent event,
    Emitter<TeacherHomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TeacherHomeLoaded) return;

    try {
      String query = event.query.toLowerCase().trim();

      List<QuizModel> filtered;
      if (query.isEmpty) {
        filtered = _allQuizzes;
      } else {
        filtered = _allQuizzes
            .where(
              (quiz) =>
                  quiz.title.toLowerCase().contains(query) ||
                  (quiz.description?.toLowerCase().contains(query) ?? false),
            )
            .toList();
      }

      // Apply existing filters
      filtered = _applyFilters(
        filtered,
        currentState.selectedCategory,
        currentState.selectedDifficulty,
      );

      emit(
        currentState.copyWith(
          filteredQuizzes: filtered,
          searchQuery: event.query,
        ),
      );
    } catch (e) {
      emit(TeacherHomeError('Search failed: ${e.toString()}'));
    }
  }

  /// Filter quizzes by category
  Future<void> _onFilterByCategory(
    FilterByCategory event,
    Emitter<TeacherHomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TeacherHomeLoaded) return;

    try {
      List<QuizModel> filtered = _applyFilters(
        _allQuizzes,
        event.category,
        currentState.selectedDifficulty,
      );

      // Apply search if exists
      if (currentState.searchQuery != null &&
          currentState.searchQuery!.isNotEmpty) {
        String query = currentState.searchQuery!.toLowerCase().trim();
        filtered = filtered
            .where(
              (quiz) =>
                  quiz.title.toLowerCase().contains(query) ||
                  (quiz.description?.toLowerCase().contains(query) ?? false),
            )
            .toList();
      }

      emit(
        currentState.copyWith(
          filteredQuizzes: filtered,
          selectedCategory: event.category,
        ),
      );
    } catch (e) {
      emit(TeacherHomeError('Filter failed: ${e.toString()}'));
    }
  }

  /// Filter quizzes by difficulty
  Future<void> _onFilterByDifficulty(
    FilterByDifficulty event,
    Emitter<TeacherHomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TeacherHomeLoaded) return;

    try {
      List<QuizModel> filtered = _applyFilters(
        _allQuizzes,
        currentState.selectedCategory,
        event.difficulty,
      );

      // Apply search if exists
      if (currentState.searchQuery != null &&
          currentState.searchQuery!.isNotEmpty) {
        String query = currentState.searchQuery!.toLowerCase().trim();
        filtered = filtered
            .where(
              (quiz) =>
                  quiz.title.toLowerCase().contains(query) ||
                  (quiz.description?.toLowerCase().contains(query) ?? false),
            )
            .toList();
      }

      emit(
        currentState.copyWith(
          filteredQuizzes: filtered,
          selectedDifficulty: event.difficulty,
        ),
      );
    } catch (e) {
      emit(TeacherHomeError('Filter failed: ${e.toString()}'));
    }
  }

  /// Reset all filters and searches
  Future<void> _onResetFilters(
    ResetFiltersEvent event,
    Emitter<TeacherHomeState> emit,
  ) async {
    try {
      emit(
        TeacherHomeLoaded(quizzes: _allQuizzes, filteredQuizzes: _allQuizzes),
      );
    } catch (e) {
      emit(TeacherHomeError('Reset failed: ${e.toString()}'));
    }
  }

  /// Refresh the quiz list from API
  Future<void> _onRefreshQuizzes(
    RefreshQuizzesEvent event,
    Emitter<TeacherHomeState> emit,
  ) async {
    emit(const TeacherHomeLoading());

    try {
      final quizzes = await studentRepository.fetchPublicQuizzes();
      _allQuizzes = quizzes;

      emit(TeacherHomeLoaded(quizzes: quizzes, filteredQuizzes: quizzes));
    } catch (e) {
      emit(TeacherHomeError('Failed to refresh quizzes: ${e.toString()}'));
    }
  }

  /// Helper method to apply filters
  List<QuizModel> _applyFilters(
    List<QuizModel> quizzes,
    String? category,
    String? difficulty,
  ) {
    var filtered = quizzes;

    if (category != null && category.isNotEmpty) {
      filtered = filtered
          .where(
            (quiz) =>
                quiz.category != null &&
                quiz.category!.toLowerCase() == category.toLowerCase(),
          )
          .toList();
    }

    // Note: difficulty filtering would depend on quiz_questions relationship
    // For now, just return the category-filtered list

    return filtered;
  }

  /// Fetch quiz by code before navigating to start quiz
  Future<void> _onFetchQuizByCode(
    FetchQuizByCodeEvent event,
    Emitter<TeacherHomeState> emit,
  ) async {
    emit(const TeacherHomeLoading());

    try {
      final quiz = await studentRepository.getQuizByCode(event.quizCode);
      emit(QuizFetchedByCode(quiz));
    } catch (e) {
      emit(TeacherHomeError('Failed to fetch quiz: ${e.toString()}'));
    }
  }

  /// Start quiz by code to get session
  Future<void> _onStartQuiz(
    StartQuizEvent event,
    Emitter<TeacherHomeState> emit,
  ) async {
    emit(const TeacherHomeLoading());

    try {
      final response = await studentRepository.startQuizByCode(event.quizCode);

      // Extract session ID from response
      final sessionId = response['session_id'] ?? response['id'] ?? '';

      if (sessionId.isEmpty) {
        throw Exception('Session ID not found in response');
      }

      emit(QuizSessionStarted(sessionId, event.quizId));
    } catch (e) {
      emit(TeacherHomeError('Failed to start quiz: ${e.toString()}'));
    }
  }
}
