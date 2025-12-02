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
    super.isActive = true,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      firebaseUid: json['firebase_uid'] as String?,
      role: json['role'] as String,
      subscriptionId: json['subscription_id'] is int 
          ? json['subscription_id'] 
          : int.tryParse(json['subscription_id'].toString()) ?? 1,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

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
  
  // Method to convert generic Entity back to Model if needed for API calls
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