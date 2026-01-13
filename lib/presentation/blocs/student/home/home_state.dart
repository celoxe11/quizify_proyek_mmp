import 'package:equatable/equatable.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';

abstract class StudentHomeState extends Equatable {
  const StudentHomeState();

  @override
  List<Object?> get props => [];
}

class StudentHomeInitial extends StudentHomeState {
  const StudentHomeInitial();
}

class StudentHomeLoading extends StudentHomeState {
  const StudentHomeLoading();
}

class StudentHomeLoaded extends StudentHomeState {
  final List<QuizModel> quizzes;
  final List<QuizModel> filteredQuizzes;
  final String? searchQuery;
  final String? selectedCategory;
  final String? selectedDifficulty;

  const StudentHomeLoaded({
    required this.quizzes,
    required this.filteredQuizzes,
    this.searchQuery,
    this.selectedCategory,
    this.selectedDifficulty,
  });

  StudentHomeLoaded copyWith({
    List<QuizModel>? quizzes,
    List<QuizModel>? filteredQuizzes,
    String? searchQuery,
    String? selectedCategory,
    String? selectedDifficulty,
  }) {
    return StudentHomeLoaded(
      quizzes: quizzes ?? this.quizzes,
      filteredQuizzes: filteredQuizzes ?? this.filteredQuizzes,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
    );
  }

  @override
  List<Object?> get props => [
    quizzes,
    filteredQuizzes,
    searchQuery,
    selectedCategory,
    selectedDifficulty,
  ];
}

class StudentHomeError extends StudentHomeState {
  final String message;

  const StudentHomeError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when single quiz is fetched by code
class QuizFetchedByCode extends StudentHomeState {
  final QuizModel quiz;

  const QuizFetchedByCode(this.quiz);

  @override
  List<Object?> get props => [quiz];
}

/// State when quiz session is started
class QuizSessionStarted extends StudentHomeState {
  final String sessionId;
  final String quizId;

  const QuizSessionStarted(this.sessionId, this.quizId);

  @override
  List<Object?> get props => [sessionId, quizId];
}
