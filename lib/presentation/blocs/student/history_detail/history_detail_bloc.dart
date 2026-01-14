import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/data/repositories/student_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/history_detail/history_detail_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/history_detail/history_detail_state.dart';
// ... imports event & state ...

class HistoryDetailBloc extends Bloc<HistoryDetailEvent, HistoryDetailState> {
  final StudentRepository repository;

  HistoryDetailBloc(this.repository) : super(HistoryDetailInitial()) {
    on<LoadHistoryDetail>((event, emit) async {
      emit(HistoryDetailLoading());
      try {
        final data = await repository.fetchHistoryDetail(event.sessionId);
        emit(HistoryDetailLoaded(data));
      } catch (e) {
        emit(HistoryDetailError(e.toString()));
      }
    });
    on<LoadGeminiEvaluation>((event, emit) async {
      // Get current data from state
      final currentState = state;
      if (currentState is! HistoryDetailLoaded &&
          currentState is! HistoryDetailGeminiEvaluationLoaded &&
          currentState is! HistoryDetailGeminiEvaluationError) {
        return;
      }

      final data = currentState is HistoryDetailLoaded
          ? currentState.data
          : currentState is HistoryDetailGeminiEvaluationLoaded
          ? currentState.data
          : (currentState as HistoryDetailGeminiEvaluationError).data;

      emit(HistoryDetailGeminiEvaluationLoading(data));
      try {
        final evaluation = await repository.getGeminiEvaluation(
          submissionAnswerId: event.submissionAnswerId,
          language: event.language,
          detailedFeedback: event.detailedFeedback,
          questionType: event.questionType,
        );
        emit(HistoryDetailGeminiEvaluationLoaded(data, evaluation));
      } catch (e) {
        emit(HistoryDetailGeminiEvaluationError(data, e.toString()));
      }
    });
  }
}
