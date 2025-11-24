import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';
import 'auth_service.dart';
import 'database_service.dart';

class UserService {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  // Register new user with email/password
  Future<UserModel> registerWithEmailPassword({
    required String name,
    required String username,
    required String email,
    required String password,
    required String role,
    int subscriptionId = 1, // Default subscription
  }) async {
    try {
      // 1. Create user in Firebase
      final userCredential = await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
      );

      // 2. Generate user ID for MySQL
      final userId = await _dbService.generateUserId();

      // 3. Create user object
      final user = UserModel(
        id: userId,
        name: name,
        username: username,
        email: email,
        firebaseUid: userCredential.user!.uid,
        role: role,
        subscriptionId: subscriptionId,
        isActive: true,
      );

      // 4. Save to MySQL
      final savedUser = await _dbService.createUser(user);

      // 5. Update Firebase profile
      await _authService.updateProfile(displayName: name);

      return savedUser;
    } catch (e) {
      // Rollback: Delete Firebase user if MySQL fails
      try {
        await _authService.deleteAccount();
      } catch (_) {}
      
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Sign in with email/password
  Future<UserModel> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Sign in to Firebase
      final userCredential = await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );

      // 2. Get user from MySQL
      final user = await _dbService.getUserByFirebaseUid(
        userCredential.user!.uid,
      );

      if (user == null) {
        throw Exception('User not found in database');
      }

      if (!user.isActive) {
        throw Exception('User account is inactive');
      }

      return user;
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  // Sign in with Google
  Future<UserModel> signInWithGoogle({
    required String role,
    int subscriptionId = 1,
  }) async {
    try {
      // 1. Sign in with Google (AuthService may return null if cancelled)
      final userCredential = await _authService.signInWithGoogle(role: role);

      // Safety: handle cancelled/failed Google sign-in
      if (userCredential == null || userCredential.user == null) {
        throw Exception('Google sign in was cancelled or failed');
      }

      final firebaseUser = userCredential.user!;

      // Safety: ensure we have a valid UID
      final firebaseUid = firebaseUser.uid;
      if (firebaseUid.isEmpty) {
        throw Exception('Firebase user has no UID');
      }

      // 2. Check if user exists in MySQL
      UserModel? existingUser;
      try {
        existingUser = await _dbService.getUserByFirebaseUid(firebaseUid);
      } catch (e) {
        throw Exception('Failed to query user by firebase UID: ${e.toString()}');
      }

      if (existingUser != null) {
        // User exists, return it
        if (!existingUser.isActive) {
          throw Exception('User account is inactive');
        }
        return existingUser;
      }

      // 3. New user - create in MySQL
      final userId = await _dbService.generateUserId();

      // Extract username safely from email or fallback
      final email = firebaseUser.email ?? '';
      String username;
      if (email.isNotEmpty && email.contains('@')) {
        username = email.split('@')[0];
      } else if (firebaseUser.displayName != null && firebaseUser.displayName!.isNotEmpty) {
        username = firebaseUser.displayName!
            .toLowerCase()
            .replaceAll(RegExp(r'\s+'), '_')
            .replaceAll(RegExp(r'[^a-z0-9_\.]'), '');
      } else {
        username = 'user$userId';
      }

      // Ensure role fallback if empty
      final finalRole = (role.isNotEmpty) ? role : 'student';

      final newUser = UserModel(
        id: userId,
        name: firebaseUser.displayName ?? username,
        username: username,
        email: firebaseUser.email ?? '',
        firebaseUid: firebaseUser.uid,
        role: finalRole,
        subscriptionId: subscriptionId,
        isActive: true,
      );

      return await _dbService.createUser(newUser);
    } catch (e) {
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  // Get current user from MySQL
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _authService.currentUser;
      if (firebaseUser == null) return null;

      return await _dbService.getUserByFirebaseUid(firebaseUser.uid);
    } catch (e) {
      throw Exception('Failed to get current user: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _authService.signOut();
  }

  // Update user profile
  Future<UserModel> updateUserProfile({
    required String userId,
    String? name,
    String? username,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (username != null) updates['username'] = username;

      // Update MySQL
      final updatedUser = await _dbService.updateUser(userId, updates);

      // Update Firebase profile if name changed
      if (name != null) {
        await _authService.updateProfile(displayName: name);
      }

      return updatedUser;
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Delete account (both Firebase and MySQL)
  Future<void> deleteAccount(String userId) async {
    try {
      // Delete from MySQL
      await _dbService.deleteUser(userId);
      
      // Delete from Firebase
      await _authService.deleteAccount();
    } catch (e) {
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }
}
