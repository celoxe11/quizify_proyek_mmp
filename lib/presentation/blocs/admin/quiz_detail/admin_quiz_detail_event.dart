part of 'admin_quiz_detail_bloc.dart';

abstract class AdminQuizDetailEvent extends Equatable {
  const AdminQuizDetailEvent();
}

class LoadAdminQuizDetail extends AdminQuizDetailEvent {
  final String quizId;
  const LoadAdminQuizDetail(this.quizId);
  @override
  List<Object> get props => [quizId];
}

class DeleteQuestionEvent extends AdminQuizDetailEvent {
  final String questionId;
  final String quizId; // Kita butuh quizId untuk refresh data setelah delete

  const DeleteQuestionEvent({required this.questionId, required this.quizId});

  @override
  List<Object> get props => [questionId, quizId];
}
