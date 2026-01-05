part of 'student_history_bloc.dart';

abstract class StudentHistoryState extends Equatable {
  const StudentHistoryState();
  
  @override
  List<Object> get props => [];
}

class StudentHistoryInitial extends StudentHistoryState {}

class StudentHistoryLoading extends StudentHistoryState {}

class StudentHistoryLoaded extends StudentHistoryState {
  final List<StudentHistoryModel> history;

  const StudentHistoryLoaded(this.history);

  @override
  List<Object> get props => [history];
}

class StudentHistoryError extends StudentHistoryState {
  final String message;

  const StudentHistoryError(this.message);

  @override
  List<Object> get props => [message];
}