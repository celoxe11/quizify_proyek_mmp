part of 'admin_quiz_detail_bloc.dart';

abstract class AdminQuizDetailState extends Equatable {
  const AdminQuizDetailState();
  @override
  List<Object> get props => [];
}

class AdminQuizDetailInitial extends AdminQuizDetailState {}
class AdminQuizDetailLoading extends AdminQuizDetailState {}

class AdminQuizDetailLoaded extends AdminQuizDetailState {
  final List<Question> questions; // Menggunakan Entity Question
  const AdminQuizDetailLoaded(this.questions);
  @override
  List<Object> get props => [questions];
}

class AdminQuizDetailError extends AdminQuizDetailState {
  final String message;
  const AdminQuizDetailError(this.message);
  @override
  List<Object> get props => [message];
}