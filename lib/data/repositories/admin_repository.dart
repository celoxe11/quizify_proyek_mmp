import 'package:quizify_proyek_mmp/core/local/quiz_storage.dart';
import 'package:quizify_proyek_mmp/core/services/admin/admin_service.dart';
import 'package:quizify_proyek_mmp/data/models/admin_analytics_model.dart';
import 'package:quizify_proyek_mmp/data/models/subscription_model.dart';
import 'package:quizify_proyek_mmp/data/models/transaction_model.dart';
import 'package:quizify_proyek_mmp/data/models/user_log_model.dart';
import 'package:quizify_proyek_mmp/data/responses/quiz_detail_response.dart';
import 'package:quizify_proyek_mmp/domain/entities/question.dart';

import '../../domain/repositories/admin_repository.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/quiz.dart';
import '../models/user_model.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';
import '../../core/services/admin/admin_api_service.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminApiService apiService;
  final QuizStorage? _localDataSource;
  final AdminService _adminService;

  AdminRepositoryImpl({
    required this.apiService,
    QuizStorage? localDataSource,
    required AdminService adminService,
  }) : _localDataSource = localDataSource,
       _adminService = adminService;

  @override
  Future<List<User>> fetchAllUsers() async {
    try {
      // Jika kosong

      // 1. Ambil data mentah (List dynamic) dari Service
      final rawData = await apiService.getAllUsers();
      print("✅ DEBUG: Data mentah diterima: ${rawData.length} items.");
      // 2. Map ke UserModel, lalu otomatis dianggap sebagai User karena Inheritance
      // Dart akan otomatis mengizinkan List<UserModel> menjadi List<User>
      // KARENA UserModel extends User.
      List<UserModel> users = [];

      for (var i = 0; i < rawData.length; i++) {
        final item = rawData[i];
        try {
          // Coba konversi
          final user = UserModel.fromJson(item);
          users.add(user);
        } catch (e) {
          throw Exception("Gagal parsing user ke-$i: $e");
        }
      }

      print("✅ DEBUG: Berhasil parsing ${users.length} users.");
      return users;
    } catch (e, stackTrace) {
      throw Exception("Repository Error: $e");
    }
  }

  @override
  Future<AdminAnalyticsModel> fetchAnalytics() async {
    try {
      final rawResponse = await apiService.getAnalytics();
      return AdminAnalyticsModel.fromJson(rawResponse);
    } catch (e) {
      throw Exception("Repo Error Analytics: $e");
    }
  }

  @override
  Future<void> toggleUserBlockStatus(String userId, bool newStatus) async {
    try {
      await apiService.toggleUserStatus(userId, newStatus);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Quiz>> fetchAllQuizzes() async {
    try {
      final rawData = await apiService.getAllQuizzes();

      if (rawData.isEmpty) {
        return [];
      }

      final List<QuizModel> quizModels = [];
      for (var i = 0; i < rawData.length; i++) {
        try {
          final quiz = QuizModel.fromJson(rawData[i]);
          quizModels.add(quiz);
        } catch (e) {
          print("Error parsing quiz at index $i: $e");
          print("Quiz data: ${rawData[i]}");
          // Continue parsing other quizzes
        }
      }

      return quizModels;
    } catch (e) {
      throw Exception("Repository Error: $e");
    }
  }

  Future<void> _cacheQuizzes(List<QuizModel> quizzes) async {
    if (_localDataSource == null || quizzes.isEmpty) return;

    try {
      await _localDataSource.insertQuizzes(quizzes);
    } catch (e) {
      print('Cache failed: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> saveQuizWithQuestions({
    String? quizId,
    required String title,
    String? description,
    String? category,
    String? status,
    String? quizCode,
    required List<QuestionModel> questions,
  }) async {
    try {
      final response = await _adminService.saveQuizWithQuestions(
        quizId: quizId,
        title: title,
        description: description,
        category: category,
        status: status,
        quizCode: quizCode,
        questions: questions,
      );

      // Refresh quiz list cache after save
      syncQuizzes();

      return response;
    } catch (e) {
      throw Exception('Failed to save quiz: $e');
    }
  }

  Future<void> syncQuizzes() async {
    try {
      final serverQuizzes = await _adminService.getAllQuizzes();
      await _cacheQuizzes(serverQuizzes);
    } catch (e) {
      // Silently fail sync - local data remains
      print('Sync failed: $e');
    }
  }

  void _syncQuizDetailInBackground(String quizId) {
    _adminService
        .getQuizDetail(quizId)
        .then((apiResponse) {
          final response = QuizDetailResponse.fromApi(apiResponse);
          _cacheQuiz(response.quiz);
        })
        .catchError((e) {
          print('Background sync quiz detail failed: $e');
        });
  }

  @override
  Future<QuizDetailResponse> fetchQuizDetail(String quizId) async {
    try {
      print('🔍 Fetching quiz detail for ID: $quizId');

      // Try local first for offline support
      if (_localDataSource != null) {
        final localQuiz = await _localDataSource.getQuizById(quizId);
        if (localQuiz != null) {
          _syncQuizDetailInBackground(quizId);
        }
      }

      // Step 1: Get quiz metadata from all quizzes endpoint
      print('📥 Step 1: Getting quiz metadata');
      final allQuizzes = await _adminService.getAllQuizzes();
      final quiz = allQuizzes.firstWhere(
        (q) => q.id == quizId,
        orElse: () => throw Exception('Quiz not found with ID: $quizId'),
      );
      print('✅ Quiz found: ${quiz.title}');

      // Step 2: Get questions from detail endpoint
      print('📥 Step 2: Getting questions');
      final detailResponse = await _adminService.getQuizDetail(quizId);
      print('🔍 Detail response keys: ${detailResponse.keys.toList()}');

      // Parse questions from response
      final questionsData = detailResponse['questions'] as List?;
      if (questionsData == null) {
        print('⚠️ No questions found in response');
      } else {
        print('✅ Found ${questionsData.length} questions');
      }

      final questions = (questionsData ?? [])
          .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
          .toList();

      // Create response with combined data
      final response = QuizDetailResponse(
        message: detailResponse['message'] ?? 'Success',
        quiz: quiz,
        questions: questions,
      );

      // Cache the quiz metadata
      await _cacheQuiz(quiz);

      return response;
    } catch (e) {
      print('❌ Error fetching quiz detail: $e');

      // Fallback to local if server fails
      if (_localDataSource != null) {
        final localQuiz = await _localDataSource.getQuizById(quizId);
        if (localQuiz != null) {
          print('📦 Using cached quiz data');
          return QuizDetailResponse(
            message: 'Loaded from cache',
            quiz: localQuiz,
            questions: [], // No questions in cache
          );
        }
      }
      rethrow;
    }
  }

  Future<void> _cacheQuiz(QuizModel quiz) async {
    if (_localDataSource == null) return;

    try {
      await _localDataSource.insertQuiz(quiz);
    } catch (e) {
      print('Failed to cache quiz: $e');
    }
  }

  @override
  Future<List<UserLogModel>> fetchLogs({String? userId}) async {
    try {
      final rawData = await apiService.getLogs(userId: userId);
      return rawData.map((e) => UserLogModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Repo Error Logs: $e");
    }
  }

  @override
  Future<void> deleteQuestion(String questionId) async {
    try {
      await apiService.deleteQuestion(questionId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteQuiz(String quizId) async {
    try {
      // Delete from server
      await _adminService.deleteQuiz(quizId);

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

  @override
  Future<List<Map<String, dynamic>>> fetchStudents(String quizId) async {
    try {
      return await _adminService.getQuizResults(quizId);
    } catch (e) {
      throw Exception('Failed to fetch students: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> fetchAccuracyResults(String quizId) async {
    try {
      return await _adminService.getQuizAccuracy(quizId);
    } catch (e) {
      throw Exception('Failed to fetch accuracy results: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> fetchStudentAnswers({
    required String studentId,
    required String quizId,
  }) async {
    try {
      return await _adminService.getQuizAnswers(quizId, studentId);
    } catch (e) {
      throw Exception('Failed to fetch student answers: $e');
    }
  }

  // Implementation
  @override
  Future<List<SubscriptionModel>> fetchSubscriptions() async {
    
    final raw = await apiService.getSubscriptions();
    return raw.map((e) => SubscriptionModel.fromJson(e)).toList();
  }

  @override
  Future<void> updateUser(String userId, String role, int subscriptionId) async {
    await apiService.updateUser(userId, role: role, subscriptionId: subscriptionId);
  }

  @override
  Future<void> addSubscriptionTier(String name, double price) async {
    await apiService.createSubscription(name, price: price);
  }

  @override
  Future<void> updateSubscriptionTier(int id, String name, double price) async {
    await apiService.updateSubscription(id, name, price);
  }

  @override
  Future<List<TransactionModel>> fetchAllTransactions() async {
    try {
      final rawData = await apiService.getAllTransactions();
      return rawData.map((e) => TransactionModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Repo Error Transactions: $e");
    }
  }
}
