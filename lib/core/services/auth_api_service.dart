import '../api/api_client.dart';
import '../../data/models/user_model.dart';

class AuthApiService {
  final ApiClient _client = ApiClient();

  // Matches POST /api/register
  Future<UserModel> registerUser({
    required String name,
    required String username,
    required String email,
    required String firebaseUid,
    required String role,
  }) async {
    final response = await _client.post('/register', {
      'name': name,
      'username': username,
      'email': email,
      'firebase_uid': firebaseUid,
      'role': role,
    }, requiresAuth: false);

    // The backend returns { message: "...", user: {...} }
    return UserModel.fromJson(response['user']);
  }

  // Matches GET /api/me (requires Authorization token)
  Future<UserModel> getUserProfile() async {
    final response = await _client.get('/me');
    return UserModel.fromJson(response);
  }
}
