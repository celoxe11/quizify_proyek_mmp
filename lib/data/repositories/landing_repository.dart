import 'package:quizify_proyek_mmp/core/services/landing/landing_service.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';
import 'package:quizify_proyek_mmp/domain/repositories/landing_repository.dart';

class LandingRepositoryImpl extends LandingRepository {
  final LandingService _landingService;

  LandingRepositoryImpl({required LandingService landingService})
    : _landingService = landingService;

  @override
  Future<List<QuizModel>> fetchLandingQuizzes() async {
    try {
      final response = await _landingService.getLandingQuizzes();
      final quizData = response.map((quiz) => QuizModel.fromJson(quiz)).toList();
      return quizData;
    } catch (e) {
      print("Error fetching landing quizzes: $e");
      rethrow;
    }
  }
}
