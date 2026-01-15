import 'package:dio/dio.dart';
import 'package:quizify_proyek_mmp/data/models/avatar_model.dart';

class ShopRepository {
  final Dio _dio;

  // Constructor menerima Dio yang sudah ada Interceptor-nya
  ShopRepository(this._dio);

  // Helper untuk membersihkan response data
  List<dynamic> _unwrapList(dynamic responseData) {
    if (responseData is List) return responseData;
    if (responseData is Map && responseData['data'] is List) {
      return responseData['data'] as List;
    }
    return [];
  }

  // 1. AMBIL SEMUA ITEM DI TOKO
  Future<List<AvatarModel>> fetchShopAvatars() async {
    try {
      // Endpoint: /api/shop/avatars
      final response = await _dio.get('/shop/avatars'); 
      final list = _unwrapList(response.data);
      return list.map((e) => AvatarModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Gagal load shop: $e");
    }
  }

  // 2. AMBIL INVENTORY SAYA
  Future<List<AvatarModel>> fetchMyInventory() async {
    try {
      // Endpoint: /api/shop/inventory
      final response = await _dio.get('/shop/inventory'); 
      final list = _unwrapList(response.data);
      return list.map((e) => AvatarModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Gagal load inventory: $e");
    }
  }

  // 3. EQUIP AVATAR (Ganti Foto Profil)
  Future<void> equipAvatar(int avatarId) async {
    try {
      await _dio.post('/shop/equip', data: {'avatar_id': avatarId});
    } catch (e) {
      throw Exception("Gagal equip avatar: $e");
    }
  }

  // 4. BUY AVATAR (Beli Item)
  // (Pastikan endpoint ini ada di backend, atau gunakan logic transaction)
  Future<void> buyAvatar(int avatarId) async {
     try {
      // Anda mungkin perlu endpoint /api/shop/buy di backend
      // Atau gunakan endpoint transaction create
      // Contoh sementara:
      // await _dio.post('/shop/buy', data: {'avatar_id': avatarId});
      print("Fitur beli belum diimplementasikan di backend");
    } catch (e) {
      throw Exception("Gagal beli avatar: $e");
    }
  }
}