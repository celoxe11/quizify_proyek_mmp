import 'package:equatable/equatable.dart';

class Question extends Equatable {
	final String id;
	final String? quizId;
	final String type; // 'multiple' or 'boolean'
	final String difficulty; // 'easy', 'medium', 'hard'
	final String questionText;
	final String correctAnswer;
	final List<String> options;
	final bool isGenerated;
	final DateTime? createdAt;
	final DateTime? updatedAt;

	const Question({
		required this.id,
		this.quizId,
		required this.type,
		required this.difficulty,
		required this.questionText,
		required this.correctAnswer,
		this.options = const [],
		this.isGenerated = false,
		this.createdAt,
		this.updatedAt,
	});

	static const empty = Question(
		id: '',
		type: 'multiple',
		difficulty: 'easy',
		questionText: '',
		correctAnswer: '',
		options: [],
		isGenerated: false,
	);

	bool get isEmpty => this == Question.empty;
	bool get isNotEmpty => this != Question.empty;

	@override
	List<Object?> get props => [
				id,
				quizId,
				type,
				difficulty,
				questionText,
				correctAnswer,
				options,
				isGenerated,
				createdAt,
				updatedAt,
			];
}

