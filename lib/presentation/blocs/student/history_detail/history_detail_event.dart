abstract class HistoryDetailEvent {}
class LoadHistoryDetail extends HistoryDetailEvent {
  final String sessionId;
  LoadHistoryDetail(this.sessionId);
}