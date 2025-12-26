import 'dart:convert'; 
import '../../domain/entities/question.dart';
import '../../domain/entities/question_image.dart';
import 'question_image_model.dart';

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
    super.correctCount,
    super.incorrectCount,
    super.image,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    // Parse question image if exists
    QuestionImage? questionImage;
    if (json['image_url'] != null) {
      try {
        final imageData = json['image_url'];
        
        // Case 1: Backend returns string URL directly
        if (imageData is String && imageData.isNotEmpty) {
          questionImage = QuestionImageModel(
            id: 0, // Placeholder since backend doesn't return full object
            userId: json['created_by']?.toString() ?? '',
            questionId: json['id']?.toString() ?? '',
            imageUrl: imageData,
            uploadedAt: null,
          );
        }
        // Case 2: Backend returns object with image details
        else if (imageData is Map<String, dynamic>) {
          questionImage = QuestionImageModel.fromJson(imageData);
        }
        // Case 3: Backend returns array with image object
        else if (imageData is List && imageData.isNotEmpty) {
          if (imageData[0] is String) {
            questionImage = QuestionImageModel(
              id: 0,
              userId: json['created_by']?.toString() ?? '',
              questionId: json['id']?.toString() ?? '',
              imageUrl: imageData[0] as String,
              uploadedAt: null,
            );
          } else if (imageData[0] is Map<String, dynamic>) {
            questionImage = QuestionImageModel.fromJson(imageData[0]);
          }
        }
      } catch (e) {
        print('Error parsing questionimage: $e');
      }
    }
    
    return QuestionModel(
      id: json['id']?.toString() ?? '',
      quizId: json['quiz_id']?.toString(),
      type: json['type']?.toString() ?? 'multiple',
      difficulty: json['difficulty']?.toString() ?? 'medium',
      questionText: json['question_text']?.toString() ?? '',
      correctAnswer: json['correct_answer']?.toString() ?? '',
      options: _parseOptions(json['options']),
      isGenerated: _parseBool(json['is_generated']),

      // Statistics (handle null)
      correctCount: int.tryParse(json['correct_answers']?.toString() ?? '0') ?? 0,
      incorrectCount: int.tryParse(json['incorrect_answers']?.toString() ?? '0') ?? 0,

      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      
      image: questionImage,
    );
  }

  /// Factory for parsing generated question response from backend
  /// Expected format: {"question": {...}}
  factory QuestionModel.fromGeneratedResponse(Map<String, dynamic> response) {
    final questionData = response['question'] as Map<String, dynamic>;
    
    return QuestionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Generate temp ID
      type: questionData['type']?.toString() ?? 'multiple',
      difficulty: questionData['difficulty']?.toString() ?? 'easy',
      questionText: questionData['question_text']?.toString() ?? '',
      correctAnswer: questionData['correct_answer']?.toString() ?? '',
      options: _parseOptions(questionData['options']),
      isGenerated: true, // Always true for AI-generated questions
    );
  }

  static List<String> _parseOptions(dynamic value) {
    if (value == null) return [];

    // Case 1: Backend sends String "["a", "b", ...]"
    if (value is String) {
      try {
        final decoded = jsonDecode(value); 
        
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } catch (e) {
        print("Failed to decode options JSON: $e");
        return [];
      }
    }

    // Case 2: Backend sends List directly
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }

    return [];
  }

  static bool _parseBool(dynamic value) {
    if (value == 1 || value == '1' || value == true || value == 'true') {
      return true;
    }
    return false;
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
      image: question.image,
    );
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
    QuestionImage? image,
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
      image: image ?? this.image,
    );
  }
}

extension on JsonCodec {
  operator [](String other) {}
}
