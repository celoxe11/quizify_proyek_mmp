import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/data/repositories/student_repository.dart';
import 'practice_question_event.dart';
import 'practice_question_state.dart';

class PracticeQuestionBloc
    extends Bloc<PracticeQuestionEvent, PracticeQuestionState> {
  final StudentRepository _repository;

  PracticeQuestionBloc(this._repository)
    : super(const PracticeQuestionInitial()) {
    on<GeneratePracticeQuestionsEvent>(_onGeneratePracticeQuestions);
    on<SelectPracticeAnswerEvent>(_onSelectPracticeAnswer);
    on<CheckPracticeAnswerEvent>(_onCheckPracticeAnswer);
    on<NextPracticeQuestionEvent>(_onNextPracticeQuestion);
    on<PreviousPracticeQuestionEvent>(_onPreviousPracticeQuestion);
    on<GoToPracticeQuestionEvent>(_onGoToPracticeQuestion);
    on<ResetPracticeEvent>(_onResetPractice);
  }

  Future<void> _onGeneratePracticeQuestions(
    GeneratePracticeQuestionsEvent event,
    Emitter<PracticeQuestionState> emit,
  ) async {
    emit(const PracticeQuestionLoading());

    try {
      final questions = await _repository.generatePracticeQuestions(
        category: event.category,
        difficulty: event.difficulty,
        count: event.count,
      );

      if (questions.isEmpty) {
        emit(
          const PracticeQuestionError('Tidak ada soal latihan yang tersedia'),
        );
        return;
      }

      emit(
        PracticeQuestionLoaded(
          questions: questions,
          currentQuestionIndex: 0,
          selectedAnswers: const {},
          checkedAnswers: const {},
        ),
      );
    } catch (e) {
      emit(
        PracticeQuestionError('Gagal generate soal latihan: ${e.toString()}'),
      );
    }
  }

  void _onSelectPracticeAnswer(
    SelectPracticeAnswerEvent event,
    Emitter<PracticeQuestionState> emit,
  ) {
    if (state is! PracticeQuestionLoaded) return;

    final currentState = state as PracticeQuestionLoaded;
    final newSelectedAnswers = Map<String, String>.from(
      currentState.selectedAnswers,
    );
    newSelectedAnswers[event.questionId] = event.answer;

    emit(currentState.copyWith(selectedAnswers: newSelectedAnswers));
  }

  void _onCheckPracticeAnswer(
    CheckPracticeAnswerEvent event,
    Emitter<PracticeQuestionState> emit,
  ) {
    if (state is! PracticeQuestionLoaded) return;

    final currentState = state as PracticeQuestionLoaded;
    final selectedAnswer = currentState.selectedAnswers[event.questionId];

    if (selectedAnswer == null) {
      emit(
        const PracticeQuestionError('Silakan pilih jawaban terlebih dahulu'),
      );
      emit(currentState);
      return;
    }

    // Find the question to get the correct answer
    final question = currentState.questions.firstWhere(
      (q) => q.id == event.questionId,
      orElse: () => currentState.currentQuestion,
    );

    final isCorrect = selectedAnswer == question.correctAnswer;
    final newCheckedAnswers = Map<String, bool>.from(
      currentState.checkedAnswers,
    );
    newCheckedAnswers[event.questionId] = isCorrect;

    emit(currentState.copyWith(checkedAnswers: newCheckedAnswers));
  }

  void _onNextPracticeQuestion(
    NextPracticeQuestionEvent event,
    Emitter<PracticeQuestionState> emit,
  ) {
    if (state is! PracticeQuestionLoaded) return;

    final currentState = state as PracticeQuestionLoaded;
    if (currentState.isLastQuestion) return;

    emit(
      currentState.copyWith(
        currentQuestionIndex: currentState.currentQuestionIndex + 1,
      ),
    );
  }

  void _onPreviousPracticeQuestion(
    PreviousPracticeQuestionEvent event,
    Emitter<PracticeQuestionState> emit,
  ) {
    if (state is! PracticeQuestionLoaded) return;

    final currentState = state as PracticeQuestionLoaded;
    if (currentState.isFirstQuestion) return;

    emit(
      currentState.copyWith(
        currentQuestionIndex: currentState.currentQuestionIndex - 1,
      ),
    );
  }

  void _onGoToPracticeQuestion(
    GoToPracticeQuestionEvent event,
    Emitter<PracticeQuestionState> emit,
  ) {
    if (state is! PracticeQuestionLoaded) return;

    final currentState = state as PracticeQuestionLoaded;
    if (event.index < 0 || event.index >= currentState.questions.length) return;

    emit(currentState.copyWith(currentQuestionIndex: event.index));
  }

  void _onResetPractice(
    ResetPracticeEvent event,
    Emitter<PracticeQuestionState> emit,
  ) {
    emit(const PracticeQuestionInitial());
  }
}
