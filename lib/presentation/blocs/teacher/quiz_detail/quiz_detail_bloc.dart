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

      final quiz = response.quiz;
      final questions = response.questions;

      emit(
        QuizDetailLoaded(
          quiz: quiz,
          questions: questions,
        ),
      );
    } catch (e) {
      emit(QuizDetailError(message: 'Failed to load quiz: ${e.toString()}'));
    }
  }

  /// Load students who attended the quiz
  Future<void> _onLoadStudents(
    LoadStudentsEvent event,
    Emitter<QuizDetailState> emit,
  ) async {
    emit(StudentsLoading());

    try {
      final students = await teacherRepository.getQuizResult(event.quizId);
      print('Students data: $students');
      emit(StudentsLoaded(students: students));
    } catch (e) {
      // if the error is due to no students attended, emit empty list
      if (e.toString().contains(
        'Tidak ada hasil kuis ditemukan untuk kuis ini',
      )) {
        emit(StudentsLoaded(students: []));
        return;
      }

      print('Error loading students: $e');
      emit(StudentsError(message: 'Failed to load students: ${e.toString()}'));
    }
  }

  /// Load accuracy results (premium feature)
  Future<void> _onLoadAccuracyResults(
    LoadAccuracyResultsEvent event,
    Emitter<QuizDetailState> emit,
  ) async {
    emit(AccuracyLoading());

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

      emit(AccuracyLoaded(accuracyResults: accuracyResults));
    } catch (e) {
      if (e.toString().contains(
            'Tidak ada pertanyaan ditemukan untuk kuis ini',
          ) ||
          e.toString().contains('Tidak ada sesi kuis yang selesai ditemukan')) {
        emit(AccuracyLoaded(accuracyResults: []));
        return;
      }

      print('Error loading accuracy results: $e');
      emit(
        AccuracyError(
          message: 'Failed to load accuracy results: ${e.toString()}',
        ),
      );
    }
  }

  /// Delete the quiz
  Future<void> _onDeleteQuiz(
    DeleteQuizEvent event,
    Emitter<QuizDetailState> emit,
  ) async {
    try {
      emit(QuizDetailLoading());

      // Delete quiz through repository
      await teacherRepository.deleteQuiz(event.quizId);

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
