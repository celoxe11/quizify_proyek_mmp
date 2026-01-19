import 'package:quizify_proyek_mmp/domain/entities/user.dart';

abstract class AuthenticationRepository {
  /// Stream of the current user. Emits [User.empty] if unauthenticated.
  Stream<User> get user;

  /// Returns the current user value synchronously
  User get currentUser;

  Future<User> login({required String email, required String password});

  Future<User> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String role,
  });

  Future<User> signInWithGoogle({required String role});

  Future<void> logout();

  /// Update user profile - only sends fields that have changed
  Future<User> updateUserProfile({
    required String userId,
    String? name,
    String? username,
    String? email,
  });

  Future<void> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  });

  bool isPremiumUser();

  Future<User> getUserProfile(); 
}
