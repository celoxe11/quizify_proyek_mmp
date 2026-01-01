part of 'create_quiz_bloc.dart';

sealed class CreateQuizState extends Equatable {
  const CreateQuizState();
  
  @override
  List<Object> get props => [];
}

final class CreateQuizInitial extends CreateQuizState {}

final class CreateQuizLoading extends CreateQuizState {}

final class CreateQuizSuccess extends CreateQuizState {
  final QuizModel quiz;

  const CreateQuizSuccess({required this.quiz});

  @override
  List<Object> get props => [quiz];
}

final class CreateQuizFailure extends CreateQuizState {
  final String error;

  const CreateQuizFailure(this.error);

  @override
  List<Object> get props => [error];
}

final class CreateQuizValidationError extends CreateQuizState {
  final String message;

  const CreateQuizValidationError(this.message);

  @override
  List<Object> get props => [message];
}
