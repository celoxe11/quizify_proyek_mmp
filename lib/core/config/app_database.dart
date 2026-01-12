import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static const String _databaseName = "Quizify.db";
  static const int _databaseVersion = 3;

  // Table names
  static const String quizTable = 'quiz';
  static const String questionTable = 'question';
  static const String questionImageTable = 'questionimage';

  // Singleton pattern
  AppDatabase._privateConstructor();
  static final AppDatabase instance = AppDatabase._privateConstructor();

  static Database? _database;

  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Create tables
  Future<void> _onCreate(Database db, int version) async {
    // Create quiz table
    await db.execute('''
      CREATE TABLE $quizTable (
        id TEXT PRIMARY KEY NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        quiz_code TEXT UNIQUE,
        status TEXT DEFAULT 'private',
        category TEXT,
        created_by TEXT,
        creator_name TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create question table
    await db.execute('''
      CREATE TABLE $questionTable (
        id TEXT PRIMARY KEY NOT NULL,
        quiz_id TEXT,
        type TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        question_text TEXT NOT NULL,
        correct_answer TEXT NOT NULL,
        options TEXT NOT NULL,
        is_generated INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (quiz_id) REFERENCES $quizTable (id) ON DELETE CASCADE
      )
    ''');

    // Create questionimage table
    await db.execute('''
      CREATE TABLE $questionImageTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        question_id TEXT NOT NULL,
        image_url TEXT NOT NULL,
        uploaded_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (question_id) REFERENCES $questionTable (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better query performance
    await db.execute(
      'CREATE INDEX idx_question_quiz_id ON $questionTable (quiz_id)',
    );
    await db.execute(
      'CREATE INDEX idx_questionimage_question_id ON $questionImageTable (question_id)',
    );
    await db.execute(
      'CREATE INDEX idx_quiz_code ON $quizTable (quiz_code)',
    );
  }

  // Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations here when database version changes
    if (oldVersion < 2 && newVersion >= 2) {
      // Migration from v1 to v2: Add created_by and creator_name columns
      await db.execute('ALTER TABLE $quizTable ADD COLUMN created_by TEXT');
      await db.execute('ALTER TABLE $quizTable ADD COLUMN creator_name TEXT');
    }
    
    if (oldVersion < 3 && newVersion >= 3) {
      // Migration from v2 to v3: Add user_id to questionimage table
      await db.execute('ALTER TABLE $questionImageTable ADD COLUMN user_id TEXT NOT NULL DEFAULT ""');
    }
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  // Clear all tables
  Future<void> clearAllTables() async {
    final db = await database;
    await db.delete(questionImageTable);
    await db.delete(questionTable);
    await db.delete(quizTable);
  }

  // Delete database (useful for testing or complete reset)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
