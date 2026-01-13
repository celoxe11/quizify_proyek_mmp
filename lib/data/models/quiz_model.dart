import '../../domain/entities/quiz.dart';

class QuizModel extends Quiz {
  const QuizModel({
    required super.id,
    required super.title,
    super.description,
    super.quizCode,
    required super.status, // 'private' or 'public'
    super.category,
    super.createdBy,
    super.creatorName, // Tambahan untuk Admin (Nama Guru)
    super.createdAt,
    super.updatedAt,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Quiz',
      description: json['description'] as String?,
      quizCode: json['quiz_code'] as String?,
      status: json['status'] as String? ?? 'private',
      category: json['category'] as String?,
      createdBy: json['created_by'] as String?,
      // Backend mungkin mengirim field ini jika melakukan JOIN user
      creatorName: json['creator_name'] as String?,
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
      'title': title,
      'description': description,
      'quiz_code': quizCode,
      'status': status,
      'category': category,
      'created_by': createdBy,
      'creator_name': creatorName,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory QuizModel.fromEntity(Quiz quiz) {
    return QuizModel(
      id: quiz.id,
      title: quiz.title,
      description: quiz.description,
      quizCode: quiz.quizCode,
      status: quiz.status,
      category: quiz.category,
      createdBy: quiz.createdBy,
      creatorName: quiz.creatorName,
      createdAt: quiz.createdAt,
      updatedAt: quiz.updatedAt,
    );
  }

  // copy with method
  QuizModel copyWith({
    String? id,
    String? title,
    String? description,
    String? quizCode,
    String? status,
    String? category,
    String? createdBy,
    String? creatorName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuizModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      quizCode: quizCode ?? this.quizCode,
      status: status ?? this.status,
      category: category ?? this.category,
      createdBy: createdBy ?? this.createdBy,
      creatorName: creatorName ?? this.creatorName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
