import 'package:equatable/equatable.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';

abstract class LandingState extends Equatable {
  const LandingState();

  @override
  List<Object> get props => [];
}

final class InitialLandingState extends LandingState {}

final class LandingQuizzesInitial extends LandingState {}

final class LandingQuizzesLoading extends LandingState {}

final class LandingQuizzesLoaded extends LandingState {
  final List<QuizModel> quizzes;

  const LandingQuizzesLoaded({required this.quizzes});
}

final class LandingQuizzesError extends LandingState {
  final String error;

  const LandingQuizzesError({required this.error});
}
