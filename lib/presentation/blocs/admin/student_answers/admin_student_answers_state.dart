part of 'admin_student_answers_bloc.dart';

abstract class AdminStudentAnswersState {
  const AdminStudentAnswersState();
}

class AdminStudentAnswersInitial extends AdminStudentAnswersState {}

class AdminStudentAnswersLoading extends AdminStudentAnswersState {}

class AdminStudentAnswersLoaded extends AdminStudentAnswersState {
  final QuizSessionModel session;
  final List<SubmissionAnswerModel> answers;

  const AdminStudentAnswersLoaded({
    required this.session,
    required this.answers,
  });
}

class AdminStudentAnswersError extends AdminStudentAnswersState {
  final String message;

  const AdminStudentAnswersError({required this.message});
}
