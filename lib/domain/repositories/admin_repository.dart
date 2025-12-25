import 'package:quizify_proyek_mmp/data/models/admin_analytics_model.dart';
import 'package:quizify_proyek_mmp/data/models/user_log_model.dart';

import '../entities/user.dart';
import '../entities/quiz.dart';
import '../entities/question.dart';

abstract class AdminRepository {
  Future<List<User>> fetchAllUsers();
  Future<List<Quiz>> fetchAllQuizzes();
  Future<List<Question>> fetchQuizDetail(String quizId);
  Future<void> deleteQuestion(String questionId); 
  Future<AdminAnalyticsModel> fetchAnalytics();
  Future<void> toggleUserBlockStatus(String userId, bool isActive);
  Future<List<UserLogModel>> fetchLogs({String? userId});
}