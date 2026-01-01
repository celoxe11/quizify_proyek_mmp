import 'package:equatable/equatable.dart';
import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';

/// Base class for all QuizDetail states
abstract class QuizDetailState extends Equatable {
  const QuizDetailState();

  @override
  List<Object?> get props => [];
}

// === Quiz Detail States ===
/// Initial state before any data is loaded
class QuizDetailInitial extends QuizDetailState {}

/// Loading state while fetching quiz data
class QuizDetailLoading extends QuizDetailState {}

/// State when quiz data is successfully loaded
class QuizDetailLoaded extends QuizDetailState {
  final QuizModel quiz;
  final List<QuestionModel> questions;

  const QuizDetailLoaded({
    required this.quiz,
    this.questions = const [],
  });

  /// Create a copy with updated values
  QuizDetailLoaded copyWith({
    QuizModel? quiz,
    List<QuestionModel>? questions,
    int? selectedTabIndex,
    bool? isPremiumUser,
  }) {
    return QuizDetailLoaded(
      quiz: quiz ?? this.quiz,
      questions: questions ?? this.questions,
    );
  }

  @override
  List<Object?> get props => [
    quiz,
    questions,
  ];
}

/// Error state when something goes wrong
class QuizDetailError extends QuizDetailState {
  final String message;

  const QuizDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State when quiz is successfully deleted
class QuizDetailDeleted extends QuizDetailState {}

// === Students States ===
class StudentsLoading extends QuizDetailState {}

class StudentsLoaded extends QuizDetailState {
  final List<Map<String, dynamic>>
  students; // List of students who took the quiz and their scores

  const StudentsLoaded({required this.students});

  @override
  List<Object?> get props => [students];
}

class StudentsError extends QuizDetailState {
  final String message;

  const StudentsError({required this.message});

  @override
  List<Object?> get props => [message];
}

// === Accuracy States ===
class AccuracyLoading extends QuizDetailState {}

class AccuracyLoaded extends QuizDetailState {
  final List<Map<String, dynamic>> accuracyResults; // Accuracy results data

  const AccuracyLoaded({required this.accuracyResults});

  @override
  List<Object?> get props => [accuracyResults];
}

class AccuracyError extends QuizDetailState {
  final String message;

  const AccuracyError({required this.message});

  @override
  List<Object?> get props => [message];
}
