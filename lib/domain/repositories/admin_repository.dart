import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:quizify_proyek_mmp/data/models/admin_analytics_model.dart';
import 'package:quizify_proyek_mmp/data/models/avatar_model.dart';
import 'package:quizify_proyek_mmp/data/models/subscription_model.dart';
import 'package:quizify_proyek_mmp/data/models/transaction_model.dart';
import 'package:quizify_proyek_mmp/data/models/user_log_model.dart';
import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/data/responses/quiz_detail_response.dart';
import 'package:quizify_proyek_mmp/domain/entities/transaction.dart';

import '../entities/user.dart';
import '../entities/quiz.dart';
import '../entities/question.dart';

abstract class AdminRepository {
  Future<List<User>> fetchAllUsers();
  Future<List<Quiz>> fetchAllQuizzes();
  Future<QuizDetailResponse> fetchQuizDetail(String quizId);
  Future<void> deleteQuestion(String questionId);
  Future<AdminAnalyticsModel> fetchAnalytics();
  Future<void> toggleUserBlockStatus(String userId, bool isActive);
  Future<List<UserLogModel>> fetchLogs({String? userId});
  Future<void> deleteQuiz(String quizId);
  Future<List<SubscriptionModel>> fetchSubscriptions();
  Future<void> updateUser(String userId, String role, int subscriptionId);
  Future<void> addSubscriptionTier(String name, double price);
  Future<void> updateSubscriptionTier(int id, String name, double price);
  Future<List<TransactionModel>> fetchAllTransactions();
  Future<List<AvatarModel>> fetchAvatars();
  Future<void> createAvatar(
    String name,
    String url,
    double price,
    String rarity, {
    XFile? file,
  });
  Future<void> updateAvatar(
    int id,
    String name,
    String url,
    double price,
    String rarity, {
    XFile? file,
  });
  Future<void> toggleAvatarStatus(int id);

  Future<Map<String, dynamic>> saveQuizWithQuestions({
    String? quizId,
    required String title,
    String? description,
    String? category,
    String? status,
    String? quizCode,
    required List<QuestionModel> questions,
  });

  Future<List<Map<String, dynamic>>> fetchStudents(String quizId);
  Future<Map<String, dynamic>> fetchAccuracyResults(String quizId);
  Future<Map<String, dynamic>> fetchStudentAnswers({
    required String studentId,
    required String quizId,
    String? sessionId,
  });
}
