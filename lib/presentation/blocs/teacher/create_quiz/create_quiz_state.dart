part of 'create_quiz_bloc.dart';

sealed class CreateQuizState extends Equatable {
  const CreateQuizState();
  
  @override
  List<Object> get props => [];
}

final class CreateQuizInitial extends CreateQuizState {}
