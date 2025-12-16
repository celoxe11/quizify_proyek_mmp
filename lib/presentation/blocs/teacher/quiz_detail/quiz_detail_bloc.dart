import 'package:bloc/bloc.dart';
import 'package:quizify_proyek_mmp/data/repositories/auth_repository.dart';
import 'package:quizify_proyek_mmp/data/repositories/teacher_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/quiz_detail/quiz_detail_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/quiz_detail/quiz_detail_state.dart';

class QuizDetailBloc extends Bloc<QuizDetailEvent, QuizDetailState> {
  final TeacherRepositoryImpl teacherRepository;
  final AuthenticationRepositoryImpl authRepository;

  QuizDetailBloc({
    TeacherRepositoryImpl? teacherRepository,
    AuthenticationRepositoryImpl? authRepository,
  }) : teacherRepository = teacherRepository ?? TeacherRepositoryImpl(),
       authRepository = authRepository ?? AuthenticationRepositoryImpl(),
       super(QuizDetailInitial()) {
    on<LoadQuizDetailEvent>(_onLoadQuizDetail);
    on<LoadStudentsEvent>(_onLoadStudents);
    on<LoadAccuracyResultsEvent>(_onLoadAccuracyResults);
    on<ChangeTabEvent>(_onChangeTab);
    on<DeleteQuizEvent>(_onDeleteQuiz);
    on<RefreshQuizDetailEvent>(_onRefresh);
  }

  /// Load quiz details and questions
  Future<void> _onLoadQuizDetail(
    LoadQuizDetailEvent event,
    Emitter<QuizDetailState> emit,
  ) async {
    emit(QuizDetailLoading());

    try {
      final response = await teacherRepository.getQuizDetail(event.quizId);
      print('Quiz detail response received: $response');

      final quiz = response.quiz;
      print('Loaded quiz: ${quiz.title}');

      final questions = response.questions;
      print('Loaded ${questions.length} questions for quiz ${quiz.id}');

      final isPremium = authRepository.isPremiumUser();
      print('Is Premium User: $isPremium');

      emit(
        QuizDetailLoaded(
          quiz: quiz,
          questions: questions,
          isPremiumUser: isPremium,
        ),
      );

      // Automatically load students after quiz is loaded
      add(LoadStudentsEvent(quizId: event.quizId));

      // Load accuracy if premium user
      if (isPremium) {
        add(LoadAccuracyResultsEvent(quizId: event.quizId));
      }
    } catch (e) {
      emit(QuizDetailError(message: 'Failed to load quiz: ${e.toString()}'));
    }
  }

  /// Load students who attended the quiz
  Future<void> _onLoadStudents(
    LoadStudentsEvent event,
    Emitter<QuizDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! QuizDetailLoaded) return;

    emit(currentState.copyWith(isLoadingStudents: true));

    try {
      // TODO: Replace with actual backend call
      // Use the getQuizResult endpoint: GET /api/teacher/quiz/:quiz_id/result
      // final response = await http.get('/api/teacher/quiz/${event.quizId}/result');
      // final students = response.results;

      // Simulated delay
      await Future.delayed(const Duration(milliseconds: 500));

      // TODO: Replace with actual data
      final students = <Map<String, dynamic>>[
        {
          'student': 'John Doe',
          'score': 85,
          'started_at': '2024-12-10T10:00:00',
          'ended_at': '2024-12-10T10:30:00',
        },
        {
          'student': 'Jane Smith',
          'score': 92,
          'started_at': '2024-12-10T11:00:00',
          'ended_at': '2024-12-10T11:25:00',
        },
        {
          'student': 'Bob Johnson',
          'score': 78,
          'started_at': '2024-12-10T14:00:00',
          'ended_at': '2024-12-10T14:35:00',
        },
      ];

      emit(currentState.copyWith(students: students, isLoadingStudents: false));
    } catch (e) {
      emit(currentState.copyWith(isLoadingStudents: false));
      // Optionally emit error or show snackbar
    }
  }

  /// Load accuracy results (premium feature)
  Future<void> _onLoadAccuracyResults(
    LoadAccuracyResultsEvent event,
    Emitter<QuizDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! QuizDetailLoaded) return;

    emit(currentState.copyWith(isLoadingAccuracy: true));

    try {
      // TODO: Replace with actual backend call
      // Use the getQuizAccuracy endpoint: GET /api/teacher/quiz/:quiz_id/accuracy
      // final response = await http.get('/api/teacher/quiz/${event.quizId}/accuracy');
      // final results = response.question_stats;

      // Simulated delay
      await Future.delayed(const Duration(milliseconds: 500));

      // TODO: Replace with actual data
      final accuracyResults = <Map<String, dynamic>>[
        {
          'question_id': 'Q001',
          'question': 'What is 2 + 2?',
          'total_answered': 10,
          'correct_answers': 9,
          'accuracy': 90,
        },
        {
          'question_id': 'Q002',
          'question': 'What is the capital of France?',
          'total_answered': 10,
          'correct_answers': 7,
          'accuracy': 70,
        },
        {
          'question_id': 'Q003',
          'question': 'What is H2O?',
          'total_answered': 10,
          'correct_answers': 10,
          'accuracy': 100,
        },
      ];

      emit(
        currentState.copyWith(
          accuracyResults: accuracyResults,
          isLoadingAccuracy: false,
        ),
      );
    } catch (e) {
      emit(currentState.copyWith(isLoadingAccuracy: false));
    }
  }

  /// Change the current tab
  void _onChangeTab(ChangeTabEvent event, Emitter<QuizDetailState> emit) {
    final currentState = state;
    if (currentState is QuizDetailLoaded) {
      emit(currentState.copyWith(selectedTabIndex: event.tabIndex));
    }
  }

  /// Delete the quiz
  Future<void> _onDeleteQuiz(
    DeleteQuizEvent event,
    Emitter<QuizDetailState> emit,
  ) async {
    try {
      // TODO: Replace with actual backend call
      // await quizRepository.delete(event.quizId);

      await Future.delayed(const Duration(milliseconds: 500));

      emit(QuizDetailDeleted());
    } catch (e) {
      emit(QuizDetailError(message: 'Failed to delete quiz: ${e.toString()}'));
    }
  }

  /// Refresh all data
  Future<void> _onRefresh(
    RefreshQuizDetailEvent event,
    Emitter<QuizDetailState> emit,
  ) async {
    add(LoadQuizDetailEvent(quizId: event.quizId));
  }
}
