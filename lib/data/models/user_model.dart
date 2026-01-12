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
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id']?.toString() ?? ''),
      name: (json['name']?.toString() ?? ''),
      username: (json['username']?.toString() ?? ''),
      email: (json['email']?.toString() ?? ''),
      firebaseUid: json['firebase_uid']?.toString(),
      role: (json['role']?.toString() ?? 'teacher'),
      subscriptionId: json['subscription_id'] is int 
          ? json['subscription_id'] 
          : int.tryParse(json['subscription_id'].toString()) ?? 1,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
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
    };
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
      isActive: user.isActive,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }
}