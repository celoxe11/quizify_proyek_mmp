import 'package:dio/dio.dart';

class StudentApiService {
  final Dio _dio;
  StudentApiService(this._dio);

  Future<List<dynamic>> getHistory() async {
    try {
      final response = await _dio.get('/api/student/history');
      return response.data['data'];
    } catch (e) {
      throw Exception("Gagal mengambil history: $e");
    }
  }
}