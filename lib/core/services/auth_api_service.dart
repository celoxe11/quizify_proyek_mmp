import '../api/api_client.dart';
import '../../data/models/user_model.dart';

class AuthApiService {
  final ApiClient _client = ApiClient();

  // Matches POST /api/auth/register
  Future<UserModel> registerUser({
    required String name,
    required String username,
    required String email,
    required String firebaseUid,
    required String role,
  }) async {
    final response = await _client.post('/auth/register', {
      'name': name,
      'username': username,
      'email': email,
      'firebase_uid': firebaseUid,
      'role': role,
    });

    // The backend returns { message: "...", user: {...} }
    return UserModel.fromJson(response['user']);
  }

  // Matches GET /api/auth/me
  Future<UserModel> getUserProfile() async {
    final response = await _client.get('/auth/me');
    return UserModel.fromJson(response);
  }
}