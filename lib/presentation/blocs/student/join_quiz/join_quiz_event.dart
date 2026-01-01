import 'package:equatable/equatable.dart';

abstract class JoinQuizEvent extends Equatable {
  const JoinQuizEvent();

  @override
  List<Object?> get props => [];
}

class JoinQuizByCodeEvent extends JoinQuizEvent {
  final String code;

  const JoinQuizByCodeEvent(this.code);

  @override
  List<Object?> get props => [code];
}

class GetQuizInfoByCodeEvent extends JoinQuizEvent {
  final String code;

  const GetQuizInfoByCodeEvent(this.code);

  @override
  List<Object?> get props => [code];
}

class ResetJoinQuizEvent extends JoinQuizEvent {
  const ResetJoinQuizEvent();
}
