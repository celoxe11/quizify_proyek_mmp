import 'package:dio/dio.dart';
import 'package:quizify_proyek_mmp/data/models/avatar_model.dart';

class ShopRepository {
  final Dio _dio;

  ShopRepository(this._dio);

  List<dynamic> _unwrapList(dynamic responseData) {
    if (responseData is List) return responseData;
    if (responseData is Map && responseData['data'] is List) {
      return responseData['data'] as List;
    }
    return [];
  }

  // [FIX] Hapus '/api' di depan
  Future<List<AvatarModel>> fetchShopAvatars() async {
    try {
      // SALAH: '/api/shop/avatars'
      // BENAR: '/shop/avatars' (karena BaseURL sudah ada /api)
      final response = await _dio.get('/shop/avatars'); 
      final list = _unwrapList(response.data);
      return list.map((e) => AvatarModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Gagal load shop: $e");
    }
  }

  // [FIX] Hapus '/api' di depan
  Future<List<AvatarModel>> fetchMyInventory() async {
    try {
      final response = await _dio.get('/shop/inventory'); 
      final list = _unwrapList(response.data);
      return list.map((e) => AvatarModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Gagal load inventory: $e");
    }
  }

  // [FIX] Hapus '/api' di depan
  Future<void> equipAvatar(int avatarId) async {
    try {
      await _dio.post('/shop/equip', data: {'avatar_id': avatarId});
    } catch (e) {
      throw Exception("Gagal equip avatar: $e");
    }
  }
}