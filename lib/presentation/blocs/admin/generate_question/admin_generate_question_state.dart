import 'package:quizify_proyek_mmp/data/models/question_model.dart';

abstract class AdminGenerateQuestionState {}

final class AdminGenerateQuestionInitial extends AdminGenerateQuestionState {}

final class AdminGenerateQuestionLoading extends AdminGenerateQuestionState {}

final class AdminGenerateQuestionSuccess extends AdminGenerateQuestionState {
  final QuestionModel question;

  AdminGenerateQuestionSuccess({required this.question});
}

final class AdminGenerateQuestionFailure extends AdminGenerateQuestionState {
  final String error;

  AdminGenerateQuestionFailure({required this.error});
}
