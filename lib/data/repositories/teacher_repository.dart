import 'package:quizify_proyek_mmp/core/config/app_database.dart';
import 'package:quizify_proyek_mmp/core/local/quiz_storage.dart';
import 'package:quizify_proyek_mmp/core/services/services.dart';
import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';
import 'package:quizify_proyek_mmp/data/responses/quiz_detail_response.dart';
import 'package:quizify_proyek_mmp/domain/repositories/teacher_repository.dart';

class TeacherRepositoryImpl extends TeacherRepository {
  final TeacherService _teacherService;
  final QuizStorage? _localDataSource;

  // todo: provider lokal bisa ditambahin disini nanti

  TeacherRepositoryImpl({
    TeacherService? teacherService,
    QuizStorage? localDataSource,
  }) : _teacherService = teacherService ?? TeacherService(),
       _localDataSource = localDataSource ?? QuizStorage(AppDatabase.instance);

  @override
  Future<void> endQuiz(String sessionId) {
    // TODO: implement endQuiz
    throw UnimplementedError();
  }

  @override
  Future<QuestionModel> generateQuestion({
    String? type,
    String? difficulty,
    String? category,
    String? topic,
    String? language,
    String? context,
    String? ageGroup,
    List<String>? avoidTopics,
    bool? includeExplanation,
    String? questionStyle,
  }) {
    // TODO: implement generateQuestion
    throw UnimplementedError();
  }

  @override
  Future<List<QuizModel>> getMyQuizzes() async {
    try {
      // Try to get from local storage first (offline-first approach)
      if (_localDataSource != null) {
        final localQuizzes = await _localDataSource!.getAllQuizzes();
        
        // If we have local data, return it immediately
        // and sync in the background
        if (localQuizzes.isNotEmpty) {
          _syncQuizzesInBackground();
          return localQuizzes;
        }
      }

      // If no local data, fetch from server and cache
      final serverQuizzes = await _teacherService.getMyQuizzes();
      await _cacheQuizzes(serverQuizzes);
      return serverQuizzes;
    } catch (e) {
      // If server fails, return local data as fallback
      if (_localDataSource != null) {
        return await _localDataSource!.getAllQuizzes();
      }
      rethrow;
    }
  }

  /// Sync quizzes from server to local storage
  Future<void> syncQuizzes() async {
    try {
      final serverQuizzes = await _teacherService.getMyQuizzes();
      await _cacheQuizzes(serverQuizzes);
    } catch (e) {
      // Silently fail sync - local data remains
      print('Sync failed: $e');
    }
  }

  /// Background sync (non-blocking)
  void _syncQuizzesInBackground() {
    syncQuizzes().catchError((e) {
      // Log error but don't interrupt user experience
      print('Background sync failed: $e');
    });
  }

  /// Cache quizzes to local storage
  Future<void> _cacheQuizzes(List<QuizModel> quizzes) async {
    if (_localDataSource == null) return;
    
    try {
      // Clear old data and insert fresh data
      await _localDataSource.deleteAllQuizzes();
      await _localDataSource.insertQuizzes(quizzes);
    } catch (e) {
      print('Cache failed: $e');
    }
  }

  /// Force refresh from server
  Future<List<QuizModel>> refreshQuizzes() async {
    final serverQuizzes = await _teacherService.getMyQuizzes();
    await _cacheQuizzes(serverQuizzes);
    return serverQuizzes;
  }

  @override
  Future<dynamic> getQuizAccuracy(String quizId) {
    // TODO: implement getQuizAccuracy
    throw UnimplementedError();
  }

  @override
  Future<QuizDetailResponse> getQuizDetail(String quizId) async {
    try {
      // Try local first for offline support
      if (_localDataSource != null) {
        final localQuiz = await _localDataSource.getQuizById(quizId);
        if (localQuiz != null) {
          // Return local data and sync in background
          _syncQuizDetailInBackground(quizId);
          // Note: You'll need to create a method to convert QuizModel to QuizDetailResponse
          // For now, we'll fetch from API if implementation is needed
        }
      }

      // Fetch from API
      final apiResponse = await _teacherService.getQuizDetail(quizId);
      final response = QuizDetailResponse.fromApi(apiResponse);
      
      // Cache the quiz metadata
      await _cacheQuiz(response.quiz);
      
      return response;
    } catch (e) {
      // Fallback to local if server fails
      if (_localDataSource != null) {
        final localQuiz = await _localDataSource.getQuizById(quizId);
        if (localQuiz != null) {
          // Return local data
          // You'll need to handle converting to QuizDetailResponse
        }
      }
      rethrow;
    }
  }

  /// Cache a single quiz
  Future<void> _cacheQuiz(QuizModel quiz) async {
    if (_localDataSource == null) return;
    
    try {
      await _localDataSource.insertQuiz(quiz);
    } catch (e) {
      print('Failed to cache quiz: $e');
    }
  }

  /// Background sync for quiz detail
  void _syncQuizDetailInBackground(String quizId) {
    _teacherService.getQuizDetail(quizId).then((apiResponse) {
      final response = QuizDetailResponse.fromApi(apiResponse);
      _cacheQuiz(response.quiz);
    }).catchError((e) {
      print('Background sync quiz detail failed: $e');
    });
  }

  @override
  Future<dynamic> getQuizResult(String quizId) {
    // TODO: implement getQuizResult
    throw UnimplementedError();
  }

  @override
  Future<dynamic> getStudentsAnswers(String quizId) {
    // TODO: implement getStudentsAnswers
    throw UnimplementedError();
  }

  @override
  Future<QuizModel> saveQuiz({
    String? quizId,
    required String title,
    String? description,
    String? quizCode,
    required List<QuestionModel> questions,
  }) {
    // TODO: implement saveQuiz
    throw UnimplementedError();
  }
}
