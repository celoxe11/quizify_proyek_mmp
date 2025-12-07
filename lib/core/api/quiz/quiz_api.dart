import 'package:quizify_proyek_mmp/core/api/api_client.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';

class QuizApi {
  final ApiClient _client;

  List<dynamic> _unwrapList(dynamic json) {
    if (json is List) return json;
    if (json is Map && json['data'] is List) return json['data'] as List;
    throw ApiException('Unexpected list response format from API');
  }

  Map<String, dynamic> _unwrapObject(dynamic json) {
    if (json is Map<String, dynamic>) {
      if (json['data'] is Map<String, dynamic>) {
        return json['data'] as Map<String, dynamic>;
      }
      return json;
    }
    throw ApiException('Unexpected object response format from API');
  }

  static const String _basePath = '/admin/quiz';

  QuizApi(this._client);

  /// GET /admin/quiz
  Future<List<QuizModel>> getAllQuizzes() async {
    final raw = await _client.get('$_basePath' + 'zes');
    final listJson = _unwrapList(raw);
    return listJson
        .map((e) => QuizModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /admin/quiz/:id
  Future<QuizModel> getQuizById(String id) async {
    final raw = await _client.get('$_basePath/$id');
    final map = _unwrapObject(raw);
    return QuizModel.fromJson(map);
  }

  /// POST /admin/quiz
  ///
  /// Biasanya create tidak mengirim field `id`, `created_at`, `updated_at`
  /// karena di-generate backend.
  Future<QuizModel> createQuiz(QuizModel quiz) async {
    final payload = quiz.toJson()
      ..remove('id')
      ..remove('created_at')
      ..remove('updated_at')
      ..remove('questions');

    final raw = await _client.post(_basePath, payload);
    final map = _unwrapObject(raw);
    return QuizModel.fromJson(map);
  }

  /// PUT /admin/quiz/:id
  ///
  /// Bisa kirim full object atau hanya field yang mau di-update.
  Future<QuizModel> updateQuiz(String id, QuizModel quiz) async {
    final payload = quiz.toJson()
      ..remove('id')
      ..remove('created_at')
      ..remove('updated_at')
      ..remove('questions');

    final raw = await _client.put('$_basePath/$id', payload);
    final map = _unwrapObject(raw);
    return QuizModel.fromJson(map);
  }

  /// DELETE /admin/quiz/:id
  Future<void> deleteQuiz(String id) async {
    await _client.delete('$_basePath/$id');
  }
}
