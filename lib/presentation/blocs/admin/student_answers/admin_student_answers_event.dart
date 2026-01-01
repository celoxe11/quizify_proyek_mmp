part of 'admin_student_answers_bloc.dart';

abstract class AdminStudentAnswersEvent {
  const AdminStudentAnswersEvent();
}

class LoadAdminStudentAnswersEvent extends AdminStudentAnswersEvent {
  final String studentId;
  final String quizId;

  const LoadAdminStudentAnswersEvent({
    required this.studentId,
    required this.quizId,
  });
}
