import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class AdminApiService {
  final Dio _dio;

  AdminApiService(this._dio);

  // GET ALL USERS
  Future<List<dynamic>> getAllUsers() async {
    try {
      // Endpoint ini harus mereturn JSON dengan structure { data: [...] }
      // Query backend harus ada JOIN ke subscription untuk dapat status text
      final response = await _dio.get('/api/admin/users');

      if (response.data is List) {
        return response.data;
      }
      // Atau berupa Map dengan key 'data' (Kurung Kurawal {})
      else if (response.data is Map && response.data['data'] != null) {
        return response.data['data'];
      }

      return [];
    } catch (e) {
      throw Exception("API Error Fetch Users: $e");
    }
  }

  // BLOCK / UNBLOCK USER
  Future<void> toggleUserStatus(String userId, bool isActive) async {
    try {
      await _dio.patch(
        '/api/admin/users/$userId/status',
        data: {'is_active': isActive ? 1 : 0},
      );
    } catch (e) {
      throw Exception("API Error Toggle User: $e");
    }
  }

  // GET ALL QUIZZES
  Future<List<dynamic>> getAllQuizzes() async {
    try {
      final response = await _dio.get('/api/admin/quizzes');

      // Handle different response structures
      if (response.data is List) {
        return response.data;
      } else if (response.data is Map && response.data['data'] != null) {
        if (response.data['data'] is List) {
          return response.data['data'];
        }
      }

      return [];
    } catch (e) {
      throw Exception("API Error Fetch Quizzes: $e");
    }
  }

  Future<List<dynamic>> getQuizDetail(String quizId) async {
    try {
      // Endpoint sesuai request backend kamu: /quiz/detail/:quiz_id
      final response = await _dio.get('/api/admin/quiz/detail/$quizId');

      // Backend return: { message: "...", questions: [...] }
      return response.data['questions'];
    } catch (e) {
      throw Exception("API Error Get Quiz Detail: $e");
    }
  }

  // GET DASHBOARD ANALYTICS
  Future<dynamic> getAnalytics() async {
    try {
      final response = await _dio.get('/api/admin/analytics');
      return response
          .data; // Mengembalikan seluruh JSON { message:..., data:... }
    } catch (e) {
      throw Exception("API Error Analytics: $e");
    }
  }

  // GET LOGS
  Future<List<dynamic>> getLogs({String? userId}) async {
    try {
      // Dio otomatis menyusun query string: /logaccess?user_id=123
      final response = await _dio.get(
        '/api/admin/logaccess',
        queryParameters: userId != null ? {'user_id': userId} : null,
      );
      return response.data;
    } catch (e) {
      throw Exception("API Error Logs: $e");
    }
  }

  // DELETE QUESTION
  Future<void> deleteQuestion(String questionId) async {
    try {
      // Endpoint: /api/admin/question/:question_id
      await _dio.delete('/api/admin/question/$questionId');
    } catch (e) {
      throw Exception("API Error Delete Question: $e");
    }
  }

  // GET SUBSCRIPTIONS
  Future<List<dynamic>> getSubscriptions() async {
    final response = await _dio.get('/api/admin/subscriptions');
    return response.data['data'];
  }

  // UPDATE USER
  Future<void> updateUser(
    String userId, {
    String? role,
    int? subscriptionId,
  }) async {
    try {
      print("📡 Sending Update to Backend: Role=$role, SubID=$subscriptionId");

      await _dio.put(
        '/api/admin/users/$userId',
        data: {
          // Pastikan key-nya persis dengan yang diminta Backend (req.body)
          if (role != null) 'role': role,
          if (subscriptionId != null)
            'subscription_id': subscriptionId, // <--- HARUS subscription_id
        },
      );
      print("✅ Update Success");
    } catch (e) {
      print("❌ Update Failed: $e");
      throw Exception("Gagal update user: $e");
    }
  }

  // CREATE SUBSCRIPTION TIER
  Future<void> createSubscription(
    String statusName, {
    required double price,
  }) async {
    try {
      await _dio.post(
        '/api/admin/subscriptions', // Endpoint backend Anda
        data: {'status': statusName, 'price': price},
      );
    } catch (e) {
      throw Exception("Gagal membuat subscription: $e");
    }
  }

  // UPDATE SUBSCRIPTION TIER
  Future<void> updateSubscription(
    int id,
    String statusName,
    double price,
  ) async {
    try {
      await _dio.put(
        '/api/admin/subscriptions/$id', // Asumsi endpoint backend: PUT /subscriptions/:id
        data: {'status': statusName, 'price': price},
      );
    } catch (e) {
      throw Exception("Gagal update subscription: $e");
    }
  }

  // GET ALL TRANSACTIONS
  Future<List<dynamic>> getAllTransactions() async {
    try {
      final response = await _dio.get('/api/admin/transactions');

      // Handle response structure { data: [...] }
      if (response.data is Map && response.data['data'] != null) {
        return response.data['data'];
      } else if (response.data is List) {
        return response.data;
      }
      return [];
    } catch (e) {
      throw Exception("Gagal mengambil transaksi: $e");
    }
  }

  Future<List<dynamic>> getAvatars() async {
    final response = await _dio.get('/api/admin/avatars');
    return response.data['data'];
  }

  Future<void> createAvatar({
    required String name,
    required String imageUrl,
    required double price,
    required String rarity,
    XFile? imageFile,
  }) async {
    try {
      // 1. Buat FormData
      final formData = FormData.fromMap({
        'name': name,
        'price': price,
        'rarity': rarity,
        // Kirim URL jika ada (dan file tidak ada)
        if (imageFile == null && imageUrl.isNotEmpty) 'image_url': imageUrl,
      });

      // 2. Jika ada File, masukkan ke FormData
      if (imageFile != null) {
        if (kIsWeb) {
          final bytes = await imageFile.readAsBytes();
          formData.files.add(
            MapEntry(
              'image_url',
              MultipartFile.fromBytes(bytes, filename: imageFile.name),
            ),
          );
        } else {
          formData.files.add(
            MapEntry(
              'image_url',
              await MultipartFile.fromFile(
                imageFile.path,
                filename: imageFile.path.split('/').last,
              ),
            ),
          );
        }
      }

      // 3. Kirim ke Backend
      await _dio.post(
        '/api/admin/avatars', // Endpoint
        data: formData,
      );
    } catch (e) {
      throw Exception("Gagal buat avatar: $e");
    }
  }

  Future<void> updateAvatar(
    int id,
    Map<String, dynamic> data, {
    XFile? imageFile,
  }) async {
    try {
      if (imageFile != null) {
        // If updating with a new image file, use FormData
        final formData = FormData.fromMap({
          'name': data['name'],
          'price': data['price'],
          'rarity': data['rarity'],
        });

        // Add the image file
        if (kIsWeb) {
          final bytes = await imageFile.readAsBytes();
          formData.files.add(
            MapEntry(
              'image_url',
              MultipartFile.fromBytes(bytes, filename: imageFile.name),
            ),
          );
        } else {
          formData.files.add(
            MapEntry(
              'image_url',
              await MultipartFile.fromFile(
                imageFile.path,
                filename: imageFile.path.split('/').last,
              ),
            ),
          );
        }

        await _dio.put('/api/admin/avatars/$id', data: formData);
      } else {
        // No file, just send JSON data
        await _dio.put('/api/admin/avatars/$id', data: data);
      }
    } catch (e) {
      throw Exception("Failed to update avatar: $e");
    }
  }

  Future<void> toggleAvatarStatus(int id) async {
    await _dio.patch('/api/admin/avatars/$id/status');
  }
}
