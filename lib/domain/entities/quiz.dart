import 'package:equatable/equatable.dart';
import 'question.dart';

class Quiz extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? code; // Quiz code for joining
  final String status; // 'private' or 'public'
  final String? category;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Quiz({
    required this.id,
    required this.title,
    this.description,
    this.code,
    this.status = 'private',
    this.category,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  static const empty = Quiz(id: '', title: '');

  bool get isEmpty => this == Quiz.empty;
  bool get isNotEmpty => this != Quiz.empty;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    code,
    status,
    category,
    createdBy,
    createdAt,
    updatedAt,
  ];
}
