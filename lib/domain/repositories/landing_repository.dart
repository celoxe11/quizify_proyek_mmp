import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';

abstract class LandingRepository {
  Future<List<QuizModel>> fetchLandingQuizzes();
}