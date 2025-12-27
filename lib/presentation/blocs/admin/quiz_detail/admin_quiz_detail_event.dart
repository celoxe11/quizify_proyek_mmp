part of 'admin_quiz_detail_bloc.dart';

/// Base class for all AdminQuizDetail events
abstract class AdminQuizDetailEvent extends Equatable {
  const AdminQuizDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load quiz details including questions
class LoadAdminQuizDetail extends AdminQuizDetailEvent {
  final String quizId;

  const LoadAdminQuizDetail(this.quizId);

  @override
  List<Object?> get props => [quizId];
}

class LoadAdminStudentsEvent extends AdminQuizDetailEvent {
  final String quizId;

  const LoadAdminStudentsEvent({required this.quizId});

  @override
  List<Object?> get props => [quizId];
}

class LoadAdminAccuracyResultsEvent extends AdminQuizDetailEvent {
  final String quizId;

  const LoadAdminAccuracyResultsEvent({required this.quizId});

  @override
  List<Object?> get props => [quizId];
}

/// Event to delete the quiz
class DeleteAdminQuizEvent extends AdminQuizDetailEvent {
  final String quizId;

  const DeleteAdminQuizEvent({required this.quizId});
  @override
  List<Object?> get props => [quizId];
}

/// Event to delete a question from the quiz
class DeleteQuestionEvent extends AdminQuizDetailEvent {
  final String questionId;
  final String quizId; // Needed for refreshing data after deletion

  const DeleteQuestionEvent({required this.questionId, required this.quizId});

  @override
  List<Object> get props => [questionId, quizId];
}

/// Event to refresh quiz detail
class RefreshAdminQuizDetailEvent extends AdminQuizDetailEvent {
  final String quizId;

  const RefreshAdminQuizDetailEvent({required this.quizId});

  @override
  List<Object?> get props => [quizId];
}