import 'package:equatable/equatable.dart';

abstract class PracticeQuestionEvent extends Equatable {
  const PracticeQuestionEvent();

  @override
  List<Object?> get props => [];
}

class GeneratePracticeQuestionsEvent extends PracticeQuestionEvent {
  final String? category;
  final String? difficulty;
  final int count;

  const GeneratePracticeQuestionsEvent({
    this.category,
    this.difficulty,
    this.count = 10,
  });

  @override
  List<Object?> get props => [category, difficulty, count];
}

class SelectPracticeAnswerEvent extends PracticeQuestionEvent {
  final String questionId;
  final String answer;

  const SelectPracticeAnswerEvent({
    required this.questionId,
    required this.answer,
  });

  @override
  List<Object?> get props => [questionId, answer];
}

class CheckPracticeAnswerEvent extends PracticeQuestionEvent {
  final String questionId;

  const CheckPracticeAnswerEvent(this.questionId);

  @override
  List<Object?> get props => [questionId];
}

class NextPracticeQuestionEvent extends PracticeQuestionEvent {
  const NextPracticeQuestionEvent();
}

class PreviousPracticeQuestionEvent extends PracticeQuestionEvent {
  const PreviousPracticeQuestionEvent();
}

class GoToPracticeQuestionEvent extends PracticeQuestionEvent {
  final int index;

  const GoToPracticeQuestionEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class ResetPracticeEvent extends PracticeQuestionEvent {
  const ResetPracticeEvent();
}
