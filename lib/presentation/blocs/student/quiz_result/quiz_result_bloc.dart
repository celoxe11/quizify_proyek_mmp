import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/data/repositories/student_repository.dart';
import 'quiz_result_event.dart';
import 'quiz_result_state.dart';

class QuizResultBloc extends Bloc<QuizResultEvent, QuizResultState> {
  final StudentRepository _repository;

  QuizResultBloc(this._repository) : super(const QuizResultInitial()) {
    on<LoadQuizResultEvent>(_onLoadQuizResult);
    on<LoadQuizHistoryEvent>(_onLoadQuizHistory);
    on<ResetQuizResultEvent>(_onResetQuizResult);
  }

  Future<void> _onLoadQuizResult(
    LoadQuizResultEvent event,
    Emitter<QuizResultState> emit,
  ) async {
    emit(const QuizResultLoading());

    try {
      final result = await _repository.getQuizResult(event.sessionId);
      final submissionAnswers = await _repository.getSubmissionAnswers(
        event.sessionId,
      );

      final score = result['score'] as int? ?? 0;
      final totalQuestions =
          result['total_questions'] as int? ?? submissionAnswers.length;
      final correctAnswers =
          result['correct_answers'] as int? ??
          submissionAnswers.where((answer) => answer.isCorrect).length;
      final incorrectAnswers =
          result['incorrect_answers'] as int? ??
          submissionAnswers.where((answer) => !answer.isCorrect).length;

      emit(
        QuizResultLoaded(
          score: score,
          totalQuestions: totalQuestions,
          correctAnswers: correctAnswers,
          incorrectAnswers: incorrectAnswers,
          submissionAnswers: submissionAnswers,
          sessionId: event.sessionId,
        ),
      );
    } catch (e) {
      emit(QuizResultError('Gagal memuat hasil quiz: ${e.toString()}'));
    }
  }

  Future<void> _onLoadQuizHistory(
    LoadQuizHistoryEvent event,
    Emitter<QuizResultState> emit,
  ) async {
    emit(const QuizResultLoading());

    try {
      final sessions = await _repository.getMyQuizHistory();
      emit(QuizHistoryLoaded(sessions));
    } catch (e) {
      emit(QuizResultError('Gagal memuat riwayat quiz: ${e.toString()}'));
    }
  }

  void _onResetQuizResult(
    ResetQuizResultEvent event,
    Emitter<QuizResultState> emit,
  ) {
    emit(const QuizResultInitial());
  }
}
