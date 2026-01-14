abstract class HistoryDetailEvent {}

class LoadHistoryDetail extends HistoryDetailEvent {
  final String sessionId;
  LoadHistoryDetail(this.sessionId);
}

class LoadGeminiEvaluation extends HistoryDetailEvent {
  final String submissionAnswerId;
  final String language;
  final bool detailedFeedback;
  final String questionType;

  LoadGeminiEvaluation(
    this.submissionAnswerId, {
    this.language = 'id',
    this.detailedFeedback = true,
    this.questionType = 'multiple',
  });
}
