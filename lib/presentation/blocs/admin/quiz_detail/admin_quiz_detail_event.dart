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