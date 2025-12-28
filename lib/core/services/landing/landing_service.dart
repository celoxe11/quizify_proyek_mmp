import 'package:quizify_proyek_mmp/core/api/api_client.dart';

class LandingService {
  final ApiClient _client;
  LandingService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<List<Map<String, dynamic>>> getLandingQuizzes() async {
    final response = await _client.get('/users/landing/get_public_quiz');
    print("Landing Quiz: ${response.toString()}");
    return List<Map<String, dynamic>>.from(
      (response as List).map((item) => Map<String, dynamic>.from(item as Map)),
    );
  }
}
