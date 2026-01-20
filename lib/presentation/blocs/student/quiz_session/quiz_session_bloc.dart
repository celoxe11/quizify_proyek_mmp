import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_session_model.dart';
import 'package:quizify_proyek_mmp/data/repositories/student_repository.dart';
import 'quiz_session_event.dart';
import 'quiz_session_state.dart';

class QuizSessionBloc extends Bloc<QuizSessionEvent, QuizSessionState> {
  final StudentRepository _repository;

  QuizSessionBloc(this._repository) : super(const QuizSessionInitial()) {
    on<LoadQuizSessionEvent>(_onLoadQuizSession);
    on<SelectAnswerEvent>(_onSelectAnswer);
    on<SubmitAnswerEvent>(_onSubmitAnswer);
    on<NextQuestionEvent>(_onNextQuestion);
    on<PreviousQuestionEvent>(_onPreviousQuestion);
    on<GoToQuestionEvent>(_onGoToQuestion);
    on<EndQuizSessionEvent>(_onEndQuizSession);
    on<ResetQuizSessionEvent>(_onResetQuizSession);
  }

  Future<void> _onLoadQuizSession(
    LoadQuizSessionEvent event,
    Emitter<QuizSessionState> emit,
  ) async {
    emit(const QuizSessionLoading());

    try {
      // Get questions using session_id
      final questions = await _repository.getQuizQuestions(event.sessionId);

      if (questions.isEmpty) {
        emit(const QuizSessionError('Quiz tidak memiliki soal'));
        return;
      }

      // Create a basic session model with available data
      final session = QuizSessionModel(
        id: event.sessionId,
        quizId: event.quizId,
        userId: '', // Will be set by backend
        startedAt: DateTime.now(),
        status: 'in_progress',
      );

      // Prepare submitted questions map from answered questions
      final submittedQuestions = <String, bool>{};
      for (var questionId in event.answeredQuestions.keys) {
        submittedQuestions[questionId] = true;
      }

      // If resuming, start from the question after last answered, or first unanswered
      int startIndex = event.startingQuestionIndex;
      if (event.answeredQuestions.isNotEmpty && startIndex == 0) {
        // Find first unanswered question
        for (int i = 0; i < questions.length; i++) {
          if (!event.answeredQuestions.containsKey(questions[i].id)) {
            startIndex = i;
            break;
          }
        }
      }

      // Make sure index is within bounds
      if (startIndex >= questions.length) {
        startIndex = questions.length - 1;
      }

      print(
        '📚 [QuizSessionBloc] Loading session - Total questions: ${questions.length}',
      );
      print(
        '✅ [QuizSessionBloc] Already answered: ${event.answeredQuestions.length}',
      );
      print('🎯 [QuizSessionBloc] Starting at question index: $startIndex');

      emit(
        QuizSessionLoaded(
          session: session,
          questions: questions,
          currentQuestionIndex: startIndex,
          selectedAnswers: Map<String, String>.from(event.answeredQuestions),
          submittedQuestions: submittedQuestions,
        ),
      );
    } catch (e) {
      emit(QuizSessionError('Gagal memuat quiz session: ${e.toString()}'));
    }
  }

  void _onSelectAnswer(
    SelectAnswerEvent event,
    Emitter<QuizSessionState> emit,
  ) {
    if (state is! QuizSessionLoaded) return;

    final currentState = state as QuizSessionLoaded;
    final newSelectedAnswers = Map<String, String>.from(
      currentState.selectedAnswers,
    );
    newSelectedAnswers[event.questionId] = event.answer;

    emit(currentState.copyWith(selectedAnswers: newSelectedAnswers));
  }

  Future<void> _onSubmitAnswer(
    SubmitAnswerEvent event,
    Emitter<QuizSessionState> emit,
  ) async {
    if (state is! QuizSessionLoaded) return;

    final currentState = state as QuizSessionLoaded;

    // Update selected answer
    final newSelectedAnswers = Map<String, String>.from(
      currentState.selectedAnswers,
    );
    newSelectedAnswers[event.questionId] = event.answer;

    emit(currentState.copyWith(selectedAnswers: newSelectedAnswers));
    emit(const QuizSessionSubmitting());

    try {
      await _repository.submitAnswer(
        sessionId: currentState.session.id,
        questionId: event.questionId,
        selectedAnswer: event.answer,
      );

      // Mark question as submitted
      final newSubmittedQuestions = Map<String, bool>.from(
        currentState.submittedQuestions,
      );
      newSubmittedQuestions[event.questionId] = true;

      emit(
        currentState.copyWith(
          selectedAnswers: newSelectedAnswers,
          submittedQuestions: newSubmittedQuestions,
        ),
      );
    } catch (e) {
      emit(QuizSessionError('Gagal submit jawaban: ${e.toString()}'));
      // Restore previous state
      emit(currentState.copyWith(selectedAnswers: newSelectedAnswers));
    }
  }

  void _onNextQuestion(
    NextQuestionEvent event,
    Emitter<QuizSessionState> emit,
  ) {
    if (state is! QuizSessionLoaded) return;

    final currentState = state as QuizSessionLoaded;
    if (currentState.isLastQuestion) return;

    emit(
      currentState.copyWith(
        currentQuestionIndex: currentState.currentQuestionIndex + 1,
      ),
    );
  }

  void _onPreviousQuestion(
    PreviousQuestionEvent event,
    Emitter<QuizSessionState> emit,
  ) {
    if (state is! QuizSessionLoaded) return;

    final currentState = state as QuizSessionLoaded;
    if (currentState.isFirstQuestion) return;

    emit(
      currentState.copyWith(
        currentQuestionIndex: currentState.currentQuestionIndex - 1,
      ),
    );
  }

  void _onGoToQuestion(
    GoToQuestionEvent event,
    Emitter<QuizSessionState> emit,
  ) {
    if (state is! QuizSessionLoaded) return;

    final currentState = state as QuizSessionLoaded;
    if (event.index < 0 || event.index >= currentState.questions.length) return;

    emit(currentState.copyWith(currentQuestionIndex: event.index));
  }

  Future<void> _onEndQuizSession(
    EndQuizSessionEvent event,
    Emitter<QuizSessionState> emit,
  ) async {
    if (state is! QuizSessionLoaded) {
      print(
        '⚠️ [QuizSessionBloc] Cannot end quiz - state is not QuizSessionLoaded',
      );
      return;
    }

    final currentState = state as QuizSessionLoaded;
    print(
      '🔄 [QuizSessionBloc] Ending quiz session: ${currentState.session.id}',
    );
    emit(const QuizSessionEnding());

    try {
      print('📡 [QuizSessionBloc] Calling repository.endQuizSession...');
      final response = await _repository.endQuizSession(
        currentState.session.id,
      );
      print('✅ [QuizSessionBloc] Response received: $response');

      // Backend uses 'score_akhir' instead of 'score'
      final score =
          response['score_akhir'] as int? ?? response['score'] as int?;
      print('📊 [QuizSessionBloc] Extracted score: $score');

      // Extract points from response
      final points = response['points'] as int?;
      print('⭐ [QuizSessionBloc] Extracted points: $points');

      emit(
        QuizSessionEnded(
          sessionId: currentState.session.id,
          score: score,
          points: points,
          message: response['message'] as String? ?? 'Quiz selesai',
        ),
      );
      print('🎉 [QuizSessionBloc] QuizSessionEnded state emitted');
    } catch (e) {
      print('❌ [QuizSessionBloc] Error ending quiz: $e');
      emit(QuizSessionError('Gagal mengakhiri quiz: ${e.toString()}'));
    }
  }

  void _onResetQuizSession(
    ResetQuizSessionEvent event,
    Emitter<QuizSessionState> emit,
  ) {
    emit(const QuizSessionInitial());
  }
}
