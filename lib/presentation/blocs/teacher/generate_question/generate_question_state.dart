import 'package:quizify_proyek_mmp/data/models/question_model.dart';

abstract class GenerateQuestionState {}

final class GenerateQuestionInitial extends GenerateQuestionState {}

final class GenerateQuestionLoading extends GenerateQuestionState {}

final class GenerateQuestionSuccess extends GenerateQuestionState {
  final QuestionModel question;

  GenerateQuestionSuccess({required this.question});
}

final class GenerateQuestionFailure extends GenerateQuestionState {
  final String error;

  GenerateQuestionFailure({required this.error});
}
