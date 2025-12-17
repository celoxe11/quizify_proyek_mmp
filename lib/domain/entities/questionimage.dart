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

	static const empty = QuestionImage(
		id: 0,
		userId: '',
		questionId: '',
		imageUrl: '',
	);

	bool get isEmpty => this == QuestionImage.empty;
	bool get isNotEmpty => this != QuestionImage.empty;

	@override
	List<Object?> get props => [id, userId, questionId, imageUrl, uploadedAt];
}

