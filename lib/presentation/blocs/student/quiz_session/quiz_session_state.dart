import 'package:equatable/equatable.dart';
import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_session_model.dart';

abstract class QuizSessionState extends Equatable {
  const QuizSessionState();

  @override
  List<Object?> get props => [];
}

class QuizSessionInitial extends QuizSessionState {
  const QuizSessionInitial();
}

class QuizSessionLoading extends QuizSessionState {
  const QuizSessionLoading();
}

class QuizSessionLoaded extends QuizSessionState {
  final QuizSessionModel session;
  final List<QuestionModel> questions;
  final int currentQuestionIndex;
  final Map<String, String> selectedAnswers; // questionId -> answer
  final Map<String, bool> submittedQuestions; // questionId -> isSubmitted

  const QuizSessionLoaded({
    required this.session,
    required this.questions,
    this.currentQuestionIndex = 0,
    this.selectedAnswers = const {},
    this.submittedQuestions = const {},
  });

  QuestionModel get currentQuestion => questions[currentQuestionIndex];

  String? get currentSelectedAnswer => selectedAnswers[currentQuestion.id];

  bool get isCurrentQuestionSubmitted =>
      submittedQuestions[currentQuestion.id] ?? false;

  int get totalQuestions => questions.length;

  int get answeredCount => submittedQuestions.length;

  bool get isLastQuestion => currentQuestionIndex == questions.length - 1;

  bool get isFirstQuestion => currentQuestionIndex == 0;

  bool get allQuestionsAnswered =>
      submittedQuestions.length == questions.length;

  QuizSessionLoaded copyWith({
    QuizSessionModel? session,
    List<QuestionModel>? questions,
    int? currentQuestionIndex,
    Map<String, String>? selectedAnswers,
    Map<String, bool>? submittedQuestions,
  }) {
    return QuizSessionLoaded(
      session: session ?? this.session,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      submittedQuestions: submittedQuestions ?? this.submittedQuestions,
    );
  }

  @override
  List<Object?> get props => [
    session,
    questions,
    currentQuestionIndex,
    selectedAnswers,
    submittedQuestions,
  ];
}

class QuizSessionSubmitting extends QuizSessionState {
  const QuizSessionSubmitting();
}

class QuizSessionEnding extends QuizSessionState {
  const QuizSessionEnding();
}

class QuizSessionEnded extends QuizSessionState {
  final String sessionId;
  final int? score;
  final int? points;
  final String message;

  const QuizSessionEnded({
    required this.sessionId,
    this.score,
    this.points,
    this.message = 'Quiz selesai',
  });

  @override
  List<Object?> get props => [sessionId, score, points, message];
}

class QuizSessionError extends QuizSessionState {
  final String message;

  const QuizSessionError(this.message);

  @override
  List<Object?> get props => [message];
}
