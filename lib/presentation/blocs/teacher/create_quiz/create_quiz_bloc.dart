import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'create_quiz_event.dart';
part 'create_quiz_state.dart';

class CreateQuizBloc extends Bloc<CreateQuizEvent, CreateQuizState> {
  CreateQuizBloc() : super(CreateQuizInitial()) {
    on<CreateQuizEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
