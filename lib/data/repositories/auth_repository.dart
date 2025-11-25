import 'dart:async';

import '../../core/services/auth_service.dart';
import '../../core/services/auth_api_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final AuthService _firebaseAuthService;
  final AuthApiService _apiService;

  // Stream controller to broadcast User Entity updates to the app
  final _controller = StreamController<User>();

  AuthenticationRepositoryImpl({
    AuthService? firebaseAuthService,
    AuthApiService? apiService,
  }) : _firebaseAuthService = firebaseAuthService ?? AuthService(),
       _apiService = apiService ?? AuthApiService() {
    // Listen to Firebase Auth changes and sync with our backend data
    _firebaseAuthService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        try {
          // If firebase user exists, fetch full profile from MySQL (Node.js)
          final userModel = await _apiService.getUserProfile();
          _controller.add(userModel);
        } catch (_) {
          // If API fetch fails but Firebase is logged in, you might want to
          // emit User.empty or a cached user.
          _controller.add(User.empty);
        }
      } else {
        _controller.add(User.empty);
      }
    });
  }

  @override
  Stream<User> get user => _controller.stream;

  @override
  User get currentUser {
    // Note: In a real app, you might want to cache the last known user in a variable
    // inside this class to return it synchronously.
    return User.empty;
  }

  @override
  Future<User> logIn({required String email, required String password}) async {
    try {
      // 1. Authenticate with Firebase
      await _firebaseAuthService.signInWithEmailPassword(
        email: email,
        password: password,
      );

      // 2. Fetch MySQL Data (The stream listener above will also trigger,
      // but returning it here allows the UI to await the specific login action)
      final userModel = await _apiService.getUserProfile();
      return userModel;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<User> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // 1. Create User in Firebase
      final credential = await _firebaseAuthService.signUpWithEmailPassword(
        email: email,
        password: password,
      );

      // 2. Send to Backend (MySQL)
      final userModel = await _apiService.registerUser(
        name: name,
        username: username,
        email: email,
        firebaseUid: credential.user!.uid,
        role: role,
      );

      // 3. Update Firebase Display Name
      await _firebaseAuthService.updateProfile(displayName: name);

      return userModel;
    } catch (e) {
      // Rollback: If API fails, delete Firebase user to prevent ghost accounts
      try {
        await _firebaseAuthService.deleteAccount();
      } catch (_) {}
      rethrow;
    }
  }

  @override
  Future<void> logOut() async {
    await _firebaseAuthService.signOut();
    _controller.add(User.empty);
  }

  // Important: Close the stream when the repo is disposed
  void dispose() => _controller.close();
}
