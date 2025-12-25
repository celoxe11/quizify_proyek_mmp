import '../entities/user.dart';
import '../entities/quiz.dart';
import '../entities/question.dart';

abstract class AdminRepository {
  Future<List<User>> fetchAllUsers();
  Future<List<Quiz>> fetchAllQuizzes();
  Future<List<Question>> fetchQuizDetail(String quizId);
}