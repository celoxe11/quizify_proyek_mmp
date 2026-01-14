import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/core/api/api_client.dart';
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
      // First, check if student has an active session for this quiz
      print(
        '🔍 [JoinQuizBloc] Checking for active session with code: ${event.code}',
      );
      final activeSession = await _repository.getActiveSessionByCode(
        event.code,
      );

      if (activeSession != null) {
        // Student has active session, resume it
        print('✅ [JoinQuizBloc] Found active session, resuming...');

        final sessionId = activeSession['session_id'] as String;
        final quizId = activeSession['quiz_id'] as String;
        final answeredQuestions =
            (activeSession['answered_questions'] as Map?)?.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ) ??
            <String, String>{};
        final currentQuestionIndex =
            activeSession['current_question_index'] as int? ?? 0;
        final message =
            activeSession['message'] as String? ?? 'Melanjutkan quiz';

        emit(
          JoinQuizSuccess(
            sessionId: sessionId,
            quizId: quizId,
            message: message,
            isResuming: true,
            answeredQuestions: answeredQuestions,
            currentQuestionIndex: currentQuestionIndex,
          ),
        );
        return;
      }

      // No active session, try to start a new one
      print('🆕 [JoinQuizBloc] No active session found, starting new quiz...');
      try {
        final response = await _repository.startQuizByCode(event.code);

        final sessionId =
            response['session_id'] as String? ??
            response['sessionId'] as String?;

        if (sessionId == null) {
          emit(
            const JoinQuizError(
              'Gagal memulai quiz: Session ID tidak ditemukan',
            ),
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
            isResuming: false,
          ),
        );
      } catch (startError) {
        // Backend might return error saying session already exists
        // Backend returns: {message: "Anda memiliki sesi kuis yang aktif", session_id: "S005"}
        print('⚠️ [JoinQuizBloc] Error from startQuizByCode: $startError');

        // Try to extract session_id from error data
        if (startError is ApiException && startError.data != null) {
          final errorData = startError.data!;
          print('📦 [JoinQuizBloc] Error data: $errorData');

          final sessionId = errorData['session_id'] as String?;
          if (sessionId != null && sessionId.isNotEmpty) {
            print(
              '✅ [JoinQuizBloc] Found session_id in error response: $sessionId',
            );

            // Get questions to extract quiz_id
            try {
              final questions = await _repository.getQuizQuestions(sessionId);
              if (questions.isNotEmpty) {
                final quizId = questions.first.quizId;
                if (quizId != null) {
                  // Get existing answers for this session
                  final answers = await _repository.getSubmissionAnswers(
                    sessionId,
                  );

                  final answeredQuestionsMap = <String, String>{};
                  for (var answer in answers) {
                    if (answer.questionId != null &&
                        answer.questionId.isNotEmpty &&
                        answer.selectedAnswer != null &&
                        answer.selectedAnswer.isNotEmpty) {
                      answeredQuestionsMap[answer.questionId] =
                          answer.selectedAnswer;
                    }
                  }

                  print(
                    '✅ [JoinQuizBloc] Resuming with ${answeredQuestionsMap.length} answered questions',
                  );

                  emit(
                    JoinQuizSuccess(
                      sessionId: sessionId,
                      quizId: quizId,
                      message: 'Melanjutkan quiz yang sedang berjalan',
                      isResuming: true,
                      answeredQuestions: answeredQuestionsMap,
                      currentQuestionIndex: answeredQuestionsMap.length,
                    ),
                  );
                  return;
                }
              }
            } catch (e) {
              print('⚠️ [JoinQuizBloc] Error getting session details: $e');
            }
          }
        }

        // Fallback: check error message for session conflict
        final errorMessage = startError.toString().toLowerCase();
        if (errorMessage.contains('sesi') ||
            errorMessage.contains('session') ||
            errorMessage.contains('aktif') ||
            errorMessage.contains('active')) {
          print(
            '⚠️ [JoinQuizBloc] Backend reports active session, retrying getActiveSessionByCode...',
          );
          // Try to get active session again (it might exist but wasn't found before)
          final retrySession = await _repository.getActiveSessionByCode(
            event.code,
          );

          if (retrySession != null) {
            final sessionId = retrySession['session_id'] as String;
            final quizId = retrySession['quiz_id'] as String;
            final answeredQuestions =
                (retrySession['answered_questions'] as Map?)?.map(
                  (key, value) => MapEntry(key.toString(), value.toString()),
                ) ??
                <String, String>{};
            final currentQuestionIndex =
                retrySession['current_question_index'] as int? ?? 0;
            final message =
                retrySession['message'] as String? ??
                'Melanjutkan quiz yang sedang berjalan';

            emit(
              JoinQuizSuccess(
                sessionId: sessionId,
                quizId: quizId,
                message: message,
                isResuming: true,
                answeredQuestions: answeredQuestions,
                currentQuestionIndex: currentQuestionIndex,
              ),
            );
            return;
          }
        }
        // Re-throw if it's a different error
        rethrow;
      }
    } catch (e) {
      print('❌ [JoinQuizBloc] Error: $e');
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
