import '../../domain/repositories/admin_repository.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/quiz.dart';
import '../models/user_model.dart';
import '../models/quiz_model.dart';
import '../../core/services/admin/admin_api_service.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminApiService apiService;

  AdminRepositoryImpl({required this.apiService});

  @override
  Future<List<User>> fetchAllUsers() async {
    try {
      // 1. Ambil data mentah (List dynamic) dari Service
      final rawData = await apiService.getAllUsers();

      // 2. Map ke UserModel, lalu otomatis dianggap sebagai User karena Inheritance
      // Dart akan otomatis mengizinkan List<UserModel> menjadi List<User> 
      // KARENA UserModel extends User.
      final List<UserModel> userModels = rawData.map((json) => UserModel.fromJson(json)).toList();
      
      return userModels;
    } catch (e) {
      throw Exception("Repository Error: $e");
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
}