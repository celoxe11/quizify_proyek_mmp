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
    createdAt,
    updatedAt,
  ];
}