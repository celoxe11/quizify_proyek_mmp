import 'package:equatable/equatable.dart';

class QuestionImage extends Equatable {
  final int id;
  final String userId;
  final String questionId;
  final String imageUrl;
  final DateTime? uploadedAt;

  const QuestionImage({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.imageUrl,
    this.uploadedAt,
  });

  /// Empty image for initial states
  static const empty = QuestionImage(
    id: 0,
    userId: '',
    questionId: '',
    imageUrl: '',
  );

  bool get isEmpty => this == QuestionImage.empty;
  bool get isNotEmpty => this != QuestionImage.empty;

  QuestionImage copyWith({
    int? id,
    String? userId,
    String? questionId,
    String? imageUrl,
    DateTime? uploadedAt,
  }) {
    return QuestionImage(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      questionId: questionId ?? this.questionId,
      imageUrl: imageUrl ?? this.imageUrl,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        questionId,
        imageUrl,
        uploadedAt,
      ];
}