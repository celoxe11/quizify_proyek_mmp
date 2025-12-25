import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:quizify_proyek_mmp/core/config/app_database.dart';
import 'package:quizify_proyek_mmp/core/local/quiz_storage.dart';
import 'package:quizify_proyek_mmp/core/services/services.dart';
import 'package:quizify_proyek_mmp/core/services/auth/auth_api_service.dart';
import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';
import 'package:quizify_proyek_mmp/data/responses/quiz_detail_response.dart';
import 'package:quizify_proyek_mmp/domain/repositories/teacher_repository.dart';

class TeacherRepositoryImpl extends TeacherRepository {
  final TeacherService _teacherService;
  final QuizStorage? _localDataSource;
  final AuthApiService _authApiService;

  TeacherRepositoryImpl({
    TeacherService? teacherService,
    QuizStorage? localDataSource,
    AuthApiService? authApiService,
  }) : _teacherService = teacherService ?? TeacherService(),
       // Only use local database on mobile platforms (not web)
       _localDataSource = localDataSource ?? (kIsWeb ? null : QuizStorage(AppDatabase.instance)),
       _authApiService = authApiService ?? AuthApiService();

  /// Get current user's teacher/student ID (not Firebase UID)
  Future<String?> _getCurrentUserId() async {
    try {
      final userProfile = await _authApiService.getUserProfile();
      return userProfile.id; // This is TE001, ST001, etc.
    } catch (e) {
      print('Failed to get user profile: $e');
      return null;
    }
  }

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
      // Get current user's teacher ID (TE001, not Firebase UID)
      final userId = await _getCurrentUserId();
      if (userId == null) {
        throw Exception('User profile not found');
      }
      
      print('Fetching quizzes for teacher ID: $userId');

      // Fetch from server first (server-first approach for quiz list)
      // This ensures we always have fresh data when navigating back
      try {
        final serverQuizzes = await _teacherService.getMyQuizzes();
        await _cacheQuizzes(serverQuizzes);
        return serverQuizzes;
      } catch (serverError) {
        print('Server fetch failed: $serverError');
        
        // Fallback to local cache if server fails
        if (_localDataSource != null) {
          try {
            final localQuizzes = await _localDataSource.getMyQuizzes(userId);
            if (localQuizzes.isNotEmpty) {
              print('Using cached quizzes (${localQuizzes.length} items)');
              return localQuizzes;
            }
          } catch (localError) {
            print('Local fallback also failed: $localError');
          }
        }
        
        // If both fail, rethrow the server error
        rethrow;
      }
    } catch (e) {
      print('Error in getMyQuizzes: $e');
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
    if (_localDataSource == null || quizzes.isEmpty) return;
    
    try {
      // Get current user ID to only clear their quizzes
      final userId = await _getCurrentUserId();
      if (userId == null) return;
      
      // Clear only this user's old data and insert fresh data
      await _localDataSource.deleteAllQuizzes(userId: userId);
      await _localDataSource.insertQuizzes(quizzes);
      print('✓ Cached ${quizzes.length} quizzes for user $userId');
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
    String? category,
    String? status,
    String? quizCode,
    required List<QuestionModel> questions,
  }) async {
    try {
      // Call the service to save quiz (images will be converted to base64 in service)
      final response = await _teacherService.saveQuizWithQuestions(
        quizId: quizId,
        title: title.trim(),
        description: description?.trim(),
        category: category?.trim(),
        status: status?.trim(),
        quizCode: quizCode?.trim(),
        questions: questions,
      );

      // Parse the response
      final savedQuizId = response['quiz_id'] as String;
      final savedQuizCode = response['quiz_code'] as String?;
      final message = response['message'] as String;
      
      print('✓ $message');

      // Fetch the updated quiz details
      final quizDetailResponse = await _teacherService.getQuizDetail(savedQuizId);
      final quizDetailParsed = QuizDetailResponse.fromApi(quizDetailResponse);
      
      // Cache the quiz
      await _cacheQuiz(quizDetailParsed.quiz);
      
      // Also refresh the quiz list cache
      _syncQuizzesInBackground();
      
      return quizDetailParsed.quiz;
    } catch (e) {
      print('Error saving quiz: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> deleteQuiz(String quizId) async {
    try {
      // Delete from server
      await _teacherService.deleteQuiz(quizId);
      
      // Sync with local database
      if (_localDataSource != null) {
        await _localDataSource.deleteQuiz(quizId);
      }
      
      print('✓ Quiz $quizId deleted successfully');
    } catch (e) {
      print('Error deleting quiz: $e');
      rethrow;
    }
  }
}
