import '../../domain/entities/quiz.dart';

class QuizModel extends Quiz {
  const QuizModel({
    required super.id,
    required super.title,
    super.description,
    super.code,
    super.status = 'private',
    super.category,
    super.createdBy,
    super.createdAt,
    super.updatedAt,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(Object? val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      try {
        return DateTime.parse(val.toString());
      } catch (_) {
        return null;
      }
    }

    return QuizModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      code: json['code'] as String?,
      status: (json['status'] as String?) ?? 'private',
      category: json['category'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'code': code,
      'status': status,
      'category': category,
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    }..removeWhere((k, v) => v == null);
  }

  // copy with method
  QuizModel copyWith({
    String? id,
    String? title,
    String? description,
    String? code,
    String? status,
    String? category,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuizModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      code: code ?? this.code,
      status: status ?? this.status,
      category: category ?? this.category,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
