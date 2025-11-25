import '../api/api_client.dart';
import '../../data/models/user_model.dart';

class UserApiService {
  final ApiClient _client = ApiClient();

  // Matches PUT /api/users/:id
  Future<UserModel> updateProfile(
    String userId, {
    String? name,
    String? username,
  }) async {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (username != null) data['username'] = username;

    final response = await _client.put('/users/$userId', data);

    // The backend returns { message: "...", user: {...} }
    return UserModel.fromJson(response['user']);
  }
}
