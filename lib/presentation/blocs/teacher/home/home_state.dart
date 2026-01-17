import 'package:equatable/equatable.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';

abstract class TeacherHomeState extends Equatable {
  const TeacherHomeState();

  @override
  List<Object?> get props => [];
}

class TeacherHomeInitial extends TeacherHomeState {
  const TeacherHomeInitial();
}

class TeacherHomeLoading extends TeacherHomeState {
  const TeacherHomeLoading();
}

class TeacherHomeLoaded extends TeacherHomeState {
  final List<QuizModel> quizzes;
  final List<QuizModel> filteredQuizzes;
  final String? searchQuery;
  final String? selectedCategory;
  final String? selectedDifficulty;

  const TeacherHomeLoaded({
    required this.quizzes,
    required this.filteredQuizzes,
    this.searchQuery,
    this.selectedCategory,
    this.selectedDifficulty,
  });

  TeacherHomeLoaded copyWith({
    List<QuizModel>? quizzes,
    List<QuizModel>? filteredQuizzes,
    String? searchQuery,
    String? selectedCategory,
    String? selectedDifficulty,
  }) {
    return TeacherHomeLoaded(
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

class TeacherHomeError extends TeacherHomeState {
  final String message;

  const TeacherHomeError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when single quiz is fetched by code
class QuizFetchedByCode extends TeacherHomeState {
  final QuizModel quiz;

  const QuizFetchedByCode(this.quiz);

  @override
  List<Object?> get props => [quiz];
}

/// State when quiz session is started
class QuizSessionStarted extends TeacherHomeState {
  final String sessionId;
  final String quizId;

  const QuizSessionStarted(this.sessionId, this.quizId);

  @override
  List<Object?> get props => [sessionId, quizId];
}
