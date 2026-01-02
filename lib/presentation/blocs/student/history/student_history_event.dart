part of 'student_history_bloc.dart';

abstract class StudentHistoryEvent extends Equatable {
  const StudentHistoryEvent();

  @override
  List<Object> get props => [];
}

class LoadStudentHistory extends StudentHistoryEvent {}