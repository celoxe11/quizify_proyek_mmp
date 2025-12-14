import 'package:equatable/equatable.dart';
import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';

/// Base class for all QuizDetail states
abstract class QuizDetailState extends Equatable {
  const QuizDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class QuizDetailInitial extends QuizDetailState {}

/// Loading state while fetching quiz data
class QuizDetailLoading extends QuizDetailState {}

/// State when quiz data is successfully loaded
class QuizDetailLoaded extends QuizDetailState {
  final QuizModel quiz;
  final List<QuestionModel> questions;
  final List<Map<String, dynamic>> students;
  final List<Map<String, dynamic>> accuracyResults;
  final int selectedTabIndex;
  final bool isLoadingStudents;
  final bool isLoadingAccuracy;
  final bool isPremiumUser;

  const QuizDetailLoaded({
    required this.quiz,
    this.questions = const [],
    this.students = const [],
    this.accuracyResults = const [],
    this.selectedTabIndex = 0,
    this.isLoadingStudents = false,
    this.isLoadingAccuracy = false,
    this.isPremiumUser = false,
  });

  /// Create a copy with updated values
  QuizDetailLoaded copyWith({
    QuizModel? quiz,
    List<QuestionModel>? questions,
    List<Map<String, dynamic>>? students,
    List<Map<String, dynamic>>? accuracyResults,
    int? selectedTabIndex,
    bool? isLoadingStudents,
    bool? isLoadingAccuracy,
    bool? isPremiumUser,
  }) {
    return QuizDetailLoaded(
      quiz: quiz ?? this.quiz,
      questions: questions ?? this.questions,
      students: students ?? this.students,
      accuracyResults: accuracyResults ?? this.accuracyResults,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      isLoadingStudents: isLoadingStudents ?? this.isLoadingStudents,
      isLoadingAccuracy: isLoadingAccuracy ?? this.isLoadingAccuracy,
      isPremiumUser: isPremiumUser ?? this.isPremiumUser,
    );
  }

  @override
  List<Object?> get props => [
    quiz,
    questions,
    students,
    accuracyResults,
    selectedTabIndex,
    isLoadingStudents,
    isLoadingAccuracy,
    isPremiumUser,
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
