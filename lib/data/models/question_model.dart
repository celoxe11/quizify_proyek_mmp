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
    // Parse question image if exists (backend includes questionimage relation)
    QuestionImage? questionImage;
    if (json['questionimage'] != null) {
      try {
        // Backend returns single object or array with 1 item
        final imageData = json['questionimage'] is List 
            ? (json['questionimage'] as List).isNotEmpty 
                ? json['questionimage'][0] 
                : null
            : json['questionimage'];
            
        if (imageData != null) {
          questionImage = QuestionImageModel.fromJson(imageData);
        }
      } catch (e) {
        print('Error parsing questionimage: $e');
      }
    }
    
    return QuestionModel(
      id: json['id']?.toString() ?? '',
      // ... field lain sama ...
      quizId: json['quiz_id']?.toString(),
      type: json['type']?.toString() ?? 'multiple',
      difficulty: json['difficulty']?.toString() ?? 'medium',
      questionText: json['question_text']?.toString() ?? '',
      correctAnswer: json['correct_answer']?.toString() ?? '',
      options: _parseOptions(json['options']),
      isGenerated: _parseBool(json['is_generated']),

      // [TAMBAHAN BARU] Baca statistik (antisipasi null)
      correctCount: int.tryParse(json['correct_answers']?.toString() ?? '0') ?? 0,
      incorrectCount: int.tryParse(json['incorrect_answers']?.toString() ?? '0') ?? 0,

      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      
      image: questionImage,
    );
  }


  static List<String> _parseOptions(dynamic value) {
    if (value == null) return [];

    // KASUS 1: Backend mengirim String "[...]" (Ini yang terjadi sekarang)
    if (value is String) {
      try {
        // Kita ubah String JSON menjadi List asli
        final decoded = jsonDecode(value); 
        
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } catch (e) {
        print("Gagal decode options JSON: $e");
        return [];
      }
    }

    // KASUS 2: Backend mengirim List asli (Untuk jaga-jaga kalau backend diperbaiki)
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
      options: _parseOptions(json['options']),
      isGenerated: _parseBool(json['is_generated']),
      createdAt: question.createdAt,
      updatedAt: question.updatedAt,
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
