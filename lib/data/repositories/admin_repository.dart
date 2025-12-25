import 'package:quizify_proyek_mmp/data/models/admin_analytics_model.dart';
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

  AdminRepositoryImpl({required this.apiService});

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
      final List<QuizModel> quizModels = rawData.map((json) => QuizModel.fromJson(json)).toList();
      return quizModels;
    } catch (e) {
      throw Exception("Repository Error: $e");
    }
  }

  @override
  Future<List<Question>> fetchQuizDetail(String quizId) async { // <--- Future disini
    try {
      // 1. Request API (Async/Future)
      final rawData = await apiService.getQuizDetail(quizId);
      
      // 2. Parsing JSON ke Model (Sync/Langsung)
      // Tidak perlu 'await' di dalam map
      return rawData.map((json) => QuestionModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception("Gagal ambil soal: $e");
    }
  }

}