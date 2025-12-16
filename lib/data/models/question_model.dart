import '../../domain/entities/question.dart';

class QuestionModel extends Question {
  const QuestionModel({
    required super.id,
    super.quizId,
    required super.type, // 'multiple' or 'boolean'
    required super.difficulty, // 'easy', 'medium', 'hard'
    required super.questionText,
    required super.correctAnswer,
    required super.options, // List<String>
    super.isGenerated = false,
    super.createdAt,
    super.updatedAt,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      quizId: json['quiz_id'] as String?,
      type: json['type'] as String,
      difficulty: json['difficulty'] as String,
      questionText: json['question_text'] as String,
      correctAnswer: json['correct_answer'] as String,
      // Handle JSON Array dari API
      options: json['options'] != null
          ? List<String>.from(json['options']) 
          : [],
      isGenerated: json['is_generated'] == 1 || json['is_generated'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'type': type,
      'difficulty': difficulty,
      'question_text': questionText,
      'correct_answer': correctAnswer,
      'options': options,
      'is_generated': isGenerated ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory QuestionModel.fromEntity(Question question) {
    return QuestionModel(
      id: question.id,
      quizId: question.quizId,
      type: question.type,
      difficulty: question.difficulty,
      questionText: question.questionText,
      correctAnswer: question.correctAnswer,
      options: question.options,
      isGenerated: question.isGenerated,
      createdAt: question.createdAt,
      updatedAt: question.updatedAt,
    );
  }
}