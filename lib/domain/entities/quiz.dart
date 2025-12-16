import 'package:equatable/equatable.dart';

class Quiz extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? quizCode;
  final String status; // 'private' or 'public'
  final String? category;
  final String? createdBy;
  final String? creatorName; // Field tambahan untuk UI/Admin (hasil join)
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Quiz({
    required this.id,
    required this.title,
    this.description,
    this.quizCode,
    required this.status,
    this.category,
    this.createdBy,
    this.creatorName,
    this.createdAt,
    this.updatedAt,
  });

  /// Empty quiz for initial states
  static const empty = Quiz(
    id: '',
    title: '',
    status: 'private',
    description: '',
    quizCode: '',
    category: '',
    createdBy: '',
    creatorName: '',
  );

  bool get isEmpty => this == Quiz.empty;
  bool get isNotEmpty => this != Quiz.empty;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        quizCode,
        status,
        category,
        createdBy,
        creatorName,
        createdAt,
        updatedAt,
      ];
}