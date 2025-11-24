import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/user_model.dart';

class DatabaseService {
  // Local backend for development.
  // On Android emulator use 10.0.2.2 to reach host machine localhost.
  // For web or running on the host machine use http://localhost:3000/api
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Create user in MySQL
  Future<UserModel> createUser(UserModel user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 201) {
        return UserModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Database error: ${e.toString()}');
    }
  }

  // Get user by Firebase UID
  Future<UserModel?> getUserByFirebaseUid(String firebaseUid) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/firebase/$firebaseUid'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to get user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Database error: ${e.toString()}');
    }
  }

  // Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/email/$email'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to get user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Database error: ${e.toString()}');
    }
  }

  // Update user
  Future<UserModel> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Database error: ${e.toString()}');
    }
  }

  // Link Firebase UID to existing user
  Future<UserModel> linkFirebaseUid(String userId, String firebaseUid) async {
    return await updateUser(userId, {'firebase_uid': firebaseUid});
  }

  // Generate unique user ID (you can implement your own logic)
  Future<String> generateUserId() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/generate-id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['id'] as String;
      } else {
        throw Exception('Failed to generate user ID: ${response.body}');
      }
    } catch (e) {
      throw Exception('Database error: ${e.toString()}');
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Database error: ${e.toString()}');
    }
  }
}
