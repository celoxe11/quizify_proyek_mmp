import 'dart:convert';

import '../../api/api_client.dart';
import '../../../data/models/user_model.dart';

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

  // Matches PUT /api/users/profile/:id (requires Authorization token)
  Future<UserModel> updateUserProfile({
    required String userId,
    String? name,
    String? username,
    String? email,
  }) async {
    try {
      // Build payload dengan hanya field yang ada (tidak null)
      final payload = <String, dynamic>{};
      if (name != null) payload['name'] = name;
      if (username != null) payload['username'] = username;
      if (email != null) payload['email'] = email;

      final response = await _client.put('/users/profile/$userId', payload);

      // Backend returns updated user object
      final userModel = UserModel.fromJson(response);

      return userModel;
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  Future<void> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    final response = await _client.put('/users/profile/$userId/password', {
      'old_password': oldPassword,
      'new_password': newPassword,
    });
    // Optional: cek response jika backend mengirim pesan error
    // If backend returns an error structure, throw
    if (response is Map<String, dynamic> && response.containsKey('error')) {
      throw Exception(response['error'] ?? 'Gagal mengubah password');
    }
  }

  // Matches GET /auth/check-google-user/:firebaseUid
  // Checks if a Google user exists in MySQL (returns user or null)
  Future<UserModel?> checkGoogleUserExists(String firebaseUid) async {
    try {
      print("Checking if Google user exists with UID: $firebaseUid");

      final response = await _client.get(
        '/check-google-user/$firebaseUid',
        requiresAuth: false, // No auth needed for existence check
      );

      print("Response from check-google-user: $response");
      print("Response type: ${response.runtimeType}");

      // Handle null or empty response
      if (response == null) {
        print("Response is null - user doesn't exist");
        return null;
      }

      // Ensure response is a Map
      if (response is! Map<String, dynamic>) {
        print("Response is not a Map - user doesn't exist");
        return null;
      }

      // Check if user exists
      final exists = response['exists'];
      print("exists field value: $exists (type: ${exists.runtimeType})");

      if (exists == true) {
        final userData = response['user'];
        if (userData != null) {
          print("Google user exists. Creating UserModel from: $userData");
          try {
            return UserModel.fromJson(userData as Map<String, dynamic>);
          } catch (e) {
            print("Error parsing UserModel: $e");
            return null;
          }
        }
      }

      print("Google user does not exist (exists: $exists)");
      return null;
    } catch (e, stackTrace) {
      print("Error checking Google user existence: $e");
      print("Stack trace: $stackTrace");
      return null;
    }
  } // Matches POST /api/google-signin

  // Creates user in MySQL if new, or returns existing user
  Future<UserModel> googleSignIn({
    required String name,
    required String email,
    required String firebaseUid,
    required String role,
  }) async {
    final username = email.split('@')[0]; // Generate username from email
    final response = await _client.post('/google-signin', {
      'name': name,
      'email': email,
      'firebase_uid': firebaseUid,
      'username': username,
      'role': role,
    }, requiresAuth: true);

    // Backend should return { user: {...} } or just the user object
    if (response.containsKey('user')) {
      return UserModel.fromJson(response['user']);
    }
    return UserModel.fromJson(response);
  }
}
