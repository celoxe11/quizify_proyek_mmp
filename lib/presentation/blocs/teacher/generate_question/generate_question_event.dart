abstract class GenerateQuestionEvent {
  const GenerateQuestionEvent();

  List<Object> get props => [];
}

final class GenerateQuestionWithAIEvent extends GenerateQuestionEvent {
  final String? type;
  final String? difficulty;
  final String? category;
  final String? topic;
  final String? language;
  final String? context;
  final String? ageGroup;
  final List<String>? avoidTopics;
  final bool? includeExplanation;
  final String? questionStyle;

  const GenerateQuestionWithAIEvent({
    this.type,
    this.difficulty,
    this.category,
    this.topic,
    this.language,
    this.context,
    this.ageGroup,
    this.avoidTopics,
    this.includeExplanation,
    this.questionStyle,
  });

  @override
  List<Object> get props => [
    if (type != null) type!,
    if (difficulty != null) difficulty!,
    if (category != null) category!,
    if (topic != null) topic!,
    if (language != null) language!,
    if (context != null) context!,
    if (ageGroup != null) ageGroup!,
    if (avoidTopics != null) avoidTopics!,
    if (includeExplanation != null) includeExplanation!,
    if (questionStyle != null) questionStyle!,
  ];
}
