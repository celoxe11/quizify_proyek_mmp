import 'package:sqflite/sqflite.dart';
import '../config/app_database.dart';
import '../../data/models/quiz_model.dart';

class QuizStorage {
  final AppDatabase _appDatabase;

  QuizStorage(this._appDatabase);

  /// Get all quizzes from local storage
  Future<List<QuizModel>> getAllQuizzes() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppDatabase.quizTable,
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => QuizModel.fromJson(map)).toList();
  }

  /// Get a specific quiz by ID
  Future<QuizModel?> getQuizById(String id) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppDatabase.quizTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return QuizModel.fromJson(maps.first);
  }
  
  /// Insert a new quiz
  Future<void> insertQuiz(QuizModel quiz) async {
    final db = await _appDatabase.database;
    await db.insert(
      AppDatabase.quizTable,
      quiz.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insert multiple quizzes
  Future<void> insertQuizzes(List<QuizModel> quizzes) async {
    final db = await _appDatabase.database;
    final batch = db.batch();
    
    for (final quiz in quizzes) {
      batch.insert(
        AppDatabase.quizTable,
        quiz.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  /// Update an existing quiz
  Future<int> updateQuiz(QuizModel quiz) async {
    final db = await _appDatabase.database;
    return await db.update(
      AppDatabase.quizTable,
      quiz.toJson(),
      where: 'id = ?',
      whereArgs: [quiz.id],
    );
  }

  /// Delete a quiz by ID
  Future<int> deleteQuiz(String id) async {
    final db = await _appDatabase.database;
    return await db.delete(
      AppDatabase.quizTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete all quizzes
  Future<int> deleteAllQuizzes() async {
    final db = await _appDatabase.database;
    return await db.delete(AppDatabase.quizTable);
  }

  /// Check if a quiz exists by ID
  Future<bool> quizExists(String id) async {
    final db = await _appDatabase.database;
    final result = await db.query(
      AppDatabase.quizTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}