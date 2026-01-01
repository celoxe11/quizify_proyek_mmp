import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/domain/repositories/landing_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/landing/landing_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/landing/landing_state.dart';

class LandingBloc extends Bloc<LandingEvent, LandingState> {
  final LandingRepository landingRepository;

  LandingBloc({required this.landingRepository})
    : super(InitialLandingState()) {
    on<FetchLandingQuizzesEvent>(_onFetchLandingQuizzes);
  }

  Future<void> _onFetchLandingQuizzes(
    FetchLandingQuizzesEvent event,
    Emitter<LandingState> emit,
  ) async {
    emit(LandingQuizzesLoading());

    try {
      final quizzes = await landingRepository.fetchLandingQuizzes();
      emit(LandingQuizzesLoaded(quizzes: quizzes));
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception: ')) {
        errorMessage = errorMessage.replaceAll('Exception: ', '');
      }
      emit(LandingQuizzesError(error: errorMessage));
    }
  }
}
