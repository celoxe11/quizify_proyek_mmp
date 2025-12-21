import '../entities/user.dart';
import '../entities/quiz.dart';

abstract class AdminRepository {
  // Mengembalikan List Entity User
  Future<List<User>> fetchAllUsers();
  
  // Aksi Block User
  Future<void> toggleUserBlockStatus(String userId, bool newStatus);

  // Mengembalikan List Entity Quiz
  Future<List<Quiz>> fetchAllQuizzes();
}