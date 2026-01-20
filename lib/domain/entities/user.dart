import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String username;
  final String email;
  final String? firebaseUid;
  final String role; // 'teacher' or 'student'
  final int subscriptionId;
  final String? subscriptionStatus;
  final bool isActive;
  final int? currentAvatarId;
  final String? currentAvatarUrl;
  final int points; // App currency for avatar purchases
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.firebaseUid,
    required this.role,
    required this.subscriptionId,
    this.subscriptionStatus,
    this.isActive = true,
    this.currentAvatarId,
    this.currentAvatarUrl,
    this.points = 0,
    this.createdAt,
    this.updatedAt,
  });

  /// Empty user for initial states
  static const empty = User(
    id: '',
    name: '',
    username: '',
    email: '',
    role: '',
    subscriptionId: 0,
    subscriptionStatus: '',
    isActive: false,
    currentAvatarId: null,
    currentAvatarUrl: null,
    points: 0,
  );

  bool get isEmpty => this == User.empty;
  bool get isNotEmpty => this != User.empty;

  @override
  List<Object?> get props => [
    id,
    name,
    username,
    email,
    firebaseUid,
    role,
    subscriptionId,
    subscriptionStatus,
    isActive,
    currentAvatarId,
    currentAvatarUrl,
    points,
    createdAt,
    updatedAt,
  ];

  User copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    String? role,
    int? currentAvatarId,
    String? currentAvatarUrl,
    int? subscriptionId,
    int? points,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      subscriptionId: subscriptionId ?? 0,
      currentAvatarId: currentAvatarId ?? this.currentAvatarId,
      currentAvatarUrl: currentAvatarUrl ?? this.currentAvatarUrl,
      points: points ?? this.points,
    );
  }
}
