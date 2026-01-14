import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/data/repositories/student_repository.dart';
import 'quiz_detail_event.dart';
import 'quiz_detail_state.dart';

class QuizDetailBloc extends Bloc<QuizDetailEvent, QuizDetailState> {
  final StudentRepository _repository;

  QuizDetailBloc(this._repository) : super(const QuizDetailInitial()) {
    on<LoadQuizDetailEvent>(_onLoadQuizDetail);
    on<StartQuizDetailEvent>(_onStartQuiz);
  }

  /// Load quiz detail by ID
  Future<void> _onLoadQuizDetail(
    LoadQuizDetailEvent event,
    Emitter<QuizDetailState> emit,
  ) async {
    emit(const QuizDetailLoading());

    try {
      print('🔄 [QuizDetailBloc] Loading quiz detail for ID: ${event.quizId}');
      final quiz = await _repository.getQuizDetail(event.quizId);
      print('✅ [QuizDetailBloc] Successfully loaded quiz: ${quiz.title}');
      emit(QuizDetailLoaded(quiz));
    } catch (e, stackTrace) {
      print('❌ [QuizDetailBloc] Error loading quiz detail: $e');
      print('Stack trace: $stackTrace');
      emit(QuizDetailError('Failed to load quiz: ${e.toString()}'));
    }
  }

  /// Start quiz by code to get session
  Future<void> _onStartQuiz(
    StartQuizDetailEvent event,
    Emitter<QuizDetailState> emit,
  ) async {
    emit(const QuizDetailLoading());

    try {
      final response = await _repository.startQuizByCode(event.quizCode);

      // Extract session ID from response
      final sessionId = response['session_id'] ?? response['id'] ?? '';

      if (sessionId.isEmpty) {
        throw Exception('Session ID not found in response');
      }

      emit(QuizSessionStarted(sessionId, event.quizId));
    } catch (e) {
      emit(QuizDetailError('Failed to start quiz: ${e.toString()}'));
    }
  }
}
