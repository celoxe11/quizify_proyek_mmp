import 'package:equatable/equatable.dart';
import 'package:quizify_proyek_mmp/data/models/question_model.dart';

abstract class PracticeQuestionState extends Equatable {
  const PracticeQuestionState();

  @override
  List<Object?> get props => [];
}

class PracticeQuestionInitial extends PracticeQuestionState {
  const PracticeQuestionInitial();
}

class PracticeQuestionLoading extends PracticeQuestionState {
  const PracticeQuestionLoading();
}

class PracticeQuestionLoaded extends PracticeQuestionState {
  final List<QuestionModel> questions;
  final int currentQuestionIndex;
  final Map<String, String> selectedAnswers; // questionId -> answer
  final Map<String, bool> checkedAnswers; // questionId -> isCorrect

  const PracticeQuestionLoaded({
    required this.questions,
    this.currentQuestionIndex = 0,
    this.selectedAnswers = const {},
    this.checkedAnswers = const {},
  });

  QuestionModel get currentQuestion => questions[currentQuestionIndex];

  String? get currentSelectedAnswer => selectedAnswers[currentQuestion.id];

  bool? get isCurrentAnswerCorrect => checkedAnswers[currentQuestion.id];

  bool get isCurrentAnswerChecked =>
      checkedAnswers.containsKey(currentQuestion.id);

  int get totalQuestions => questions.length;

  int get answeredCount => checkedAnswers.length;

  int get correctCount =>
      checkedAnswers.values.where((isCorrect) => isCorrect).length;

  int get incorrectCount =>
      checkedAnswers.values.where((isCorrect) => !isCorrect).length;

  bool get isLastQuestion => currentQuestionIndex == questions.length - 1;

  bool get isFirstQuestion => currentQuestionIndex == 0;

  bool get allQuestionsAnswered => checkedAnswers.length == questions.length;

  double get scorePercentage =>
      totalQuestions > 0 ? (correctCount / totalQuestions) * 100 : 0.0;

  PracticeQuestionLoaded copyWith({
    List<QuestionModel>? questions,
    int? currentQuestionIndex,
    Map<String, String>? selectedAnswers,
    Map<String, bool>? checkedAnswers,
  }) {
    return PracticeQuestionLoaded(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      checkedAnswers: checkedAnswers ?? this.checkedAnswers,
    );
  }

  @override
  List<Object?> get props => [
    questions,
    currentQuestionIndex,
    selectedAnswers,
    checkedAnswers,
  ];
}

class PracticeQuestionError extends PracticeQuestionState {
  final String message;

  const PracticeQuestionError(this.message);

  @override
  List<Object?> get props => [message];
}
