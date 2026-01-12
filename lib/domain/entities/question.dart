import 'package:equatable/equatable.dart';
import 'question_image.dart';

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
  final int correctCount;
  final int incorrectCount;
  final QuestionImage? image; // Question image (stored separately in questionimage table)


  const Question({
    required this.id,
    this.quizId,
    required this.type,
    required this.difficulty,
    required this.questionText,
    required this.correctAnswer,
    required this.options,
    this.isGenerated = false,
    this.correctCount = 0, 
    this.incorrectCount = 0,
    this.createdAt,
    this.updatedAt,
    this.image,
  });

  /// Empty question for initial states
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
    correctCount, 
    incorrectCount,
  ];
}
