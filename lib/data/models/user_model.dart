import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.username,
    required super.email,
    super.firebaseUid,
    required super.role,
    required super.subscriptionId,
    super.subscriptionStatus,
    super.isActive = true,
    super.currentAvatarId,
    super.currentAvatarUrl,
    super.points = 0,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'No Name',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firebaseUid: json['firebase_uid']?.toString(),
      role: json['role']?.toString() ?? 'student',

      subscriptionId: _parseInt(json['subscription_id']) ?? 1,
      subscriptionStatus: json['subscription_status']?.toString() ?? 'Free',
      isActive: _parseBool(json['is_active']),

      // [BARU] Parsing current_avatar_id
      currentAvatarId: _parseInt(json['current_avatar_id']),

      currentAvatarUrl: json['current_avatar_url']?.toString(),

      // [BARU] Parsing points
      points: _parseInt(json['points']) ?? 0,

      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      username: user.username,
      email: user.email,
      firebaseUid: user.firebaseUid,
      role: user.role,
      subscriptionId: user.subscriptionId,
      subscriptionStatus: user.subscriptionStatus,
      isActive: user.isActive,
      // Mapping field baru
      currentAvatarId: user.currentAvatarId,
      currentAvatarUrl: user.currentAvatarUrl,
      points: user.points,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  // --- HELPER SAKTI ---
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString()); // Ubah String ke Int
  }

  static bool _parseBool(dynamic value) {
    if (value == 1 || value == '1' || value == true || value == 'true') {
      return true;
    }
    return false;
  }

  // ... toJson dan fromEntity ...
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'firebase_uid': firebaseUid,
      'role': role,
      'subscription_id': subscriptionId,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'current_avatar_id': currentAvatarId.toString(),
      'points': points,
    };
  }
}
