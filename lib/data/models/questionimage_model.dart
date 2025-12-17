import '../../domain/entities/questionimage.dart';

class QuestionImageModel extends QuestionImage {
	const QuestionImageModel({
		required super.id,
		required super.userId,
		required super.questionId,
		required super.imageUrl,
		super.uploadedAt,
	});

	factory QuestionImageModel.fromJson(Map<String, dynamic> json) {
		DateTime? parseDate(Object? val) {
			if (val == null) return null;
			if (val is DateTime) return val;
			try {
				return DateTime.parse(val.toString());
			} catch (_) {
				return null;
			}
		}

		return QuestionImageModel(
			id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
			userId: json['user_id'] as String,
			questionId: json['question_id'] as String,
			imageUrl: json['image_url'] as String,
			uploadedAt: parseDate(json['uploaded_at']),
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'user_id': userId,
			'question_id': questionId,
			'image_url': imageUrl,
			'uploaded_at': uploadedAt?.toIso8601String(),
		}..removeWhere((k, v) => v == null);
	}

  // copy with method
  QuestionImageModel copyWith({
    int? id,
    String? userId,
    String? questionId,
    String? imageUrl,
    DateTime? uploadedAt,
  }) {
    return QuestionImageModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      questionId: questionId ?? this.questionId,
      imageUrl: imageUrl ?? this.imageUrl,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }
}

