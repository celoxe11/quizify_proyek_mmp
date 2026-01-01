part of 'admin_create_quiz_bloc.dart';

sealed class AdminCreateQuizState extends Equatable {
  const AdminCreateQuizState();

  @override
  List<Object> get props => [];
}

final class AdminCreateQuizInitial extends AdminCreateQuizState {}

final class AdminCreateQuizLoading extends AdminCreateQuizState {}

final class AdminCreateQuizSuccess extends AdminCreateQuizState {
  final QuizModel quiz;

  const AdminCreateQuizSuccess({required this.quiz});

  @override
  List<Object> get props => [quiz];
}

final class AdminCreateQuizFailure extends AdminCreateQuizState {
  final String error;

  const AdminCreateQuizFailure(this.error);

  @override
  List<Object> get props => [error];
}

final class AdminCreateQuizValidationError extends AdminCreateQuizState {
  final String message;

  const AdminCreateQuizValidationError(this.message);

  @override
  List<Object> get props => [message];
}
