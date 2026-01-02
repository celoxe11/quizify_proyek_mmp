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
  }
}