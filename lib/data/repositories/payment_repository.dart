import 'package:quizify_proyek_mmp/core/api/api_client.dart';
import 'package:quizify_proyek_mmp/data/models/avatar_model.dart';
import 'package:quizify_proyek_mmp/data/models/payment_snap_model.dart';
import 'package:quizify_proyek_mmp/data/models/payment_status_model.dart';
import 'package:quizify_proyek_mmp/data/models/subscription_model.dart';

class PaymentRepository {
  final ApiClient _client;

  PaymentRepository(this._client);

  Map<String, dynamic> _unwrapObject(dynamic json) {
    if (json is Map<String, dynamic>) {
      if (json['data'] is Map<String, dynamic>) {
        return json['data'] as Map<String, dynamic>;
      }
      return json;
    }
    throw ApiException('Unexpected object response format from API');
  }

  List<dynamic> _unwrapList(dynamic json) {
    try {
      if (json is List) {
        print('Response is a List with ${(json as List).length} items');
        return json;
      }
      if (json is Map) {
        if (json['data'] is List) {
          final list = json['data'] as List;
          print(
            'Response is Map with data property, contains ${list.length} items',
          );
          return list;
        }
        if (json['items'] is List) {
          final list = json['items'] as List;
          print(
            'Response is Map with items property, contains ${list.length} items',
          );
          return list;
        }
      }
      print('Unexpected response format: ${json.runtimeType}');
      throw ApiException(
        'Unexpected list response format from API: ${json.runtimeType}',
      );
    } catch (e) {
      print('Error unwrapping list: $e');
      rethrow;
    }
  }

  /// Create payment snap token untuk subscription atau avatar
  /// Type: 'subscription' atau 'avatar'
  Future<PaymentSnapModel> createPayment({
    required String type, // 'subscription' or 'avatar'
    String? subscriptionPlanId,
    String? avatarId,
    double? amount,
  }) async {
    try {
      if (type == 'subscription' &&
          (subscriptionPlanId == null || subscriptionPlanId.isEmpty)) {
        throw Exception(
          'subscriptionPlanId harus diisi untuk type subscription',
        );
      }

      final payload = {
        'type': type,
        if (type == 'subscription' &&
            subscriptionPlanId != null &&
            subscriptionPlanId.isNotEmpty)
          'subscription_id':
              subscriptionPlanId, // Backend expects subscription_id
        if (type == 'avatar' && avatarId != null) 'avatar_id': avatarId,
        if (amount != null) 'amount': amount, // Kirim amount ke backend
      };

      final raw = await _client.post('/payment/create', payload);
      final map = _unwrapObject(raw);
      final snap = PaymentSnapModel.fromJson(map);
      print('📊 [PaymentRepository] Payment snap created: ${snap.orderId}');

      return snap;
    } catch (e) {
      print('❌ [PaymentRepository] Error creating payment: $e');
      throw Exception('Gagal membuat pembayaran: $e');
    }
  }

  /// Check payment status
  Future<PaymentStatusModel> checkPaymentStatus(String orderId) async {
    try {
      print('📡 [PaymentRepository] Checking payment status: $orderId');

      final raw = await _client.get('/payment/status/$orderId');
      print('✅ [PaymentRepository] Response type: ${raw.runtimeType}');

      final map = _unwrapObject(raw);
      final status = PaymentStatusModel.fromJson(map);
      print('📊 [PaymentRepository] Payment status: ${status.status}');

      return status;
    } catch (e) {
      print('❌ [PaymentRepository] Error checking payment status: $e');
      throw Exception('Gagal mengecek status pembayaran: $e');
    }
  }

  /// Get user's payment history
  Future<List<PaymentStatusModel>> getPaymentHistory({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      print('📡 [PaymentRepository] Fetching payment history...');

      final raw = await _client.get('/payment/history?page=$page&limit=$limit');
      print('✅ [PaymentRepository] Response type: ${raw.runtimeType}');

      final listJson = _unwrapList(raw);
      print('📊 [PaymentRepository] Found ${listJson.length} payment records');

      return listJson
          .map((e) => PaymentStatusModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ [PaymentRepository] Error fetching payment history: $e');

      final message = e.toString();
      if (message.contains('Avatar is not associated') ||
          message.contains('avatar_id')) {
        // Backend bug: Transaction/Subscription model relation issue
        // We throw a cleaner error message
        throw Exception(
          'Kesalahan Data Pembayaran: Beberapa transaksi subscription mengalami masalah data di server. Mohon hubungi admin untuk perbaikan (Missing Avatar Relation).',
        );
      }

      // Clean up generic error message
      if (message.startsWith('Exception: ')) {
        throw Exception(message.replaceAll('Exception: ', ''));
      }

      throw Exception('Gagal mengambil riwayat pembayaran: $message');
    }
  }

  /// Cancel pending payment
  Future<void> cancelPayment(String orderId) async {
    try {
      print('📡 [PaymentRepository] Cancelling payment: $orderId');

      await _client.post('/payment/cancel/$orderId', {});

      print('✅ [PaymentRepository] Payment cancelled successfully');
    } catch (e) {
      print('❌ [PaymentRepository] Error cancelling payment: $e');
      throw Exception('Gagal membatalkan pembayaran: $e');
    }
  }

  /// Get available avatars
  Future<List<AvatarModel>> getAvatars() async {
    try {
      print('📡 [PaymentRepository] Fetching avatars...');

      final raw = await _client.get('/payment/my-avatars');
      print('✅ [PaymentRepository] Response type: ${raw.runtimeType}');

      final listJson = _unwrapList(raw);
      print('📊 [PaymentRepository] Found ${listJson.length} avatars');

      return listJson
          .map((e) => AvatarModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ [PaymentRepository] Error fetching avatars: $e');
      throw Exception('Gagal mengambil daftar avatar: $e');
    }
  }

  /// Set active avatar
  Future<AvatarModel> setActiveAvatar(String avatarId) async {
    try {
      print('📡 [PaymentRepository] Setting active avatar: $avatarId');

      final raw = await _client.post('/payment/set-avatar/$avatarId', {});
      print('✅ [PaymentRepository] Response type: ${raw.runtimeType}');

      final map = _unwrapObject(raw);
      final avatar = AvatarModel.fromJson(map);
      print('📊 [PaymentRepository] Avatar set as active: ${avatar.name}');

      return avatar;
    } catch (e) {
      print('❌ [PaymentRepository] Error setting active avatar: $e');
      throw Exception('Gagal mengatur avatar aktif: $e');
    }
  }

  /// Get available subscription plans dari endpoint /subscription/packages/features
  Future<List<SubscriptionModel>> getSubscriptionPlans() async {
    try {
      print(
        '📡 [PaymentRepository] Fetching subscription plans from /subscription/packages/features...',
      );

      final raw = await _client.get('/payment/subscription/packages/features');
      print('✅ [PaymentRepository] Response type: ${raw.runtimeType}');

      final listJson = _unwrapList(raw);
      print(
        '📊 [PaymentRepository] Found ${listJson.length} subscription plans',
      );

      return listJson
          .map((e) => SubscriptionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ [PaymentRepository] Error fetching subscription plans: $e');
      throw Exception('Gagal mengambil paket berlangganan: $e');
    }
  }
}
