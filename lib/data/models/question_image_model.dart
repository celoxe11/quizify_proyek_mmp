import '../../domain/entities/question_image.dart';

class QuestionImageModel extends QuestionImage {
  const QuestionImageModel({
    required super.id,
    required super.userId,
    required super.questionId,
    required super.imageUrl,
    super.uploadedAt,
  });

  factory QuestionImageModel.fromJson(Map<String, dynamic> json) {
    return QuestionImageModel(
      // ID di DB adalah INT, pastikan handle konversinya
      id: json['id'] is int 
          ? json['id'] 
          : int.parse(json['id'].toString()),
      userId: json['user_id'] as String,
      questionId: json['question_id'] as String,
      imageUrl: json['image_url'] as String,
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.parse(json['uploaded_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'question_id': questionId,
      'image_url': imageUrl,
      'uploaded_at': uploadedAt?.toIso8601String(),
    };
  }

  factory QuestionImageModel.fromEntity(QuestionImage image) {
    return QuestionImageModel(
      id: image.id,
      userId: image.userId,
      questionId: image.questionId,
      imageUrl: image.imageUrl,
      uploadedAt: image.uploadedAt,
    );
  }
}