import 'dart:convert';

import '../../domain/entities/question.dart';

class QuestionModel extends Question {
  const QuestionModel({
    required super.id,
    super.quizId,
    required super.type,
    required super.difficulty,
    required super.questionText,
    required super.correctAnswer,
    super.options = const [],
    super.isGenerated = false,
    super.createdAt,
    super.updatedAt,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    // parse options which may come as JSON string or List
    final rawOptions = json['options'];
    List<String> optionsList = [];
    if (rawOptions == null) {
      optionsList = [];
    } else if (rawOptions is String) {
      try {
        final decoded = jsonDecode(rawOptions);
        if (decoded is List) {
          optionsList = decoded.map((e) => e.toString()).toList();
        } else {
          optionsList = [decoded.toString()];
        }
      } catch (_) {
        optionsList = [rawOptions];
      }
    } else if (rawOptions is List) {
      optionsList = rawOptions.map((e) => e.toString()).toList();
    } else {
      optionsList = [rawOptions.toString()];
    }

    final isGenerated =
        json['is_generated'] == 1 ||
        json['is_generated'] == '1' ||
        json['is_generated'] == true;

    DateTime? parseDate(Object? val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      try {
        return DateTime.parse(val.toString());
      } catch (_) {
        return null;
      }
    }

    return QuestionModel(
      id: json['id'] as String,
      quizId: json['quiz_id'] as String?,
      type: json['type'] as String,
      difficulty: json['difficulty'] as String,
      questionText: json['question_text'] as String,
      correctAnswer: json['correct_answer'] as String,
      options: optionsList,
      isGenerated: isGenerated,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
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
      'options': jsonEncode(options),
      'is_generated': isGenerated ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    }..removeWhere((key, value) => value == null);
  }

  // copy with method
  QuestionModel copyWith({
    String? id,
    String? quizId,
    String? type,
    String? difficulty,
    String? questionText,
    String? correctAnswer,
    List<String>? options,
    bool? isGenerated,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      questionText: questionText ?? this.questionText,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      options: options ?? this.options,
      isGenerated: isGenerated ?? this.isGenerated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
