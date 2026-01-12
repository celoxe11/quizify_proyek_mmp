import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/data/repositories/student_repository.dart';
import 'join_quiz_event.dart';
import 'join_quiz_state.dart';

class JoinQuizBloc extends Bloc<JoinQuizEvent, JoinQuizState> {
  final StudentRepository _repository;

  JoinQuizBloc(this._repository) : super(const JoinQuizInitial()) {
    on<JoinQuizByCodeEvent>(_onJoinQuizByCode);
    on<GetQuizInfoByCodeEvent>(_onGetQuizInfoByCode);
    on<ResetJoinQuizEvent>(_onResetJoinQuiz);
  }

  Future<void> _onJoinQuizByCode(
    JoinQuizByCodeEvent event,
    Emitter<JoinQuizState> emit,
  ) async {
    emit(const JoinQuizLoading());

    try {
      // Start the quiz session
      final response = await _repository.startQuizByCode(event.code);

      final sessionId =
          response['session_id'] as String? ?? response['sessionId'] as String?;

      if (sessionId == null) {
        emit(
          const JoinQuizError('Gagal memulai quiz: Session ID tidak ditemukan'),
        );
        return;
      }

      // Try to get quiz_id from response
      String? quizId =
          response['quiz_id'] as String? ?? response['quizId'] as String?;

      // If quiz_id not in response, fetch questions to get quiz_id
      if (quizId == null) {
        final questions = await _repository.getQuizQuestions(sessionId);
        if (questions.isEmpty) {
          emit(const JoinQuizError('Quiz tidak memiliki soal'));
          return;
        }
        // Get quiz_id from first question
        quizId = questions.first.quizId;
        if (quizId == null) {
          emit(const JoinQuizError('Gagal mendapatkan Quiz ID'));
          return;
        }
      }

      emit(
        JoinQuizSuccess(
          sessionId: sessionId,
          quizId: quizId,
          message: response['message'] as String? ?? 'Quiz berhasil dimulai',
        ),
      );
    } catch (e) {
      emit(JoinQuizError('Gagal join quiz: ${e.toString()}'));
    }
  }

  Future<void> _onGetQuizInfoByCode(
    GetQuizInfoByCodeEvent event,
    Emitter<JoinQuizState> emit,
  ) async {
    emit(const JoinQuizLoading());

    try {
      final quiz = await _repository.getQuizByCode(event.code);
      emit(QuizInfoLoaded(quiz));
    } catch (e) {
      emit(JoinQuizError('Gagal mengambil info quiz: ${e.toString()}'));
    }
  }

  Future<void> _onResetJoinQuiz(
    ResetJoinQuizEvent event,
    Emitter<JoinQuizState> emit,
  ) async {
    emit(const JoinQuizInitial());
  }
}
