import 'package:quizify_proyek_mmp/data/models/history_detail_model.dart';

abstract class HistoryDetailState {}
class HistoryDetailInitial extends HistoryDetailState {}
class HistoryDetailLoading extends HistoryDetailState {}
class HistoryDetailLoaded extends HistoryDetailState {
  final HistoryDetailModel data;
  HistoryDetailLoaded(this.data);
}
class HistoryDetailError extends HistoryDetailState {
  final String message;
  HistoryDetailError(this.message);
}