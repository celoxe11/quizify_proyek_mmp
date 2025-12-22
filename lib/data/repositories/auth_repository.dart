import 'dart:async';

import '../../core/services/auth/auth_service.dart';
import '../../core/services/auth/auth_api_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

// Exception thrown when Google user needs to select a role
class NeedsRoleSelectionException implements Exception {
  final String firebaseUid;
  final String name;
  final String email;

  NeedsRoleSelectionException({
    required this.firebaseUid,
    required this.name,
    required this.email,
  });

  @override
  String toString() => 'User needs to select a role';
}

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final AuthService _firebaseAuthService;
  final AuthApiService _apiService;

  // Stream controller to broadcast User Entity updates to the app
  final _controller = StreamController<User>.broadcast();

  // Cache the current user
  User _currentUser = User.empty;

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
          _currentUser = userModel;
          _controller.add(userModel);
        } catch (_) {
          // If API fetch fails but Firebase is logged in, you might want to
          // emit User.empty or a cached user.
          _currentUser = User.empty;
          _controller.add(User.empty);
        }
      } else {
        _currentUser = User.empty;
        _controller.add(User.empty);
      }
    });
  }

  @override
  Stream<User> get user => _controller.stream;

  @override
  User get currentUser => _currentUser;

  Future<void> _refreshAuthToken() async {
    // Passing 'true' forces the token to be refreshed from Firebase
    await _firebaseAuthService.currentUser?.getIdTokenResult(true);
  }

  @override
  Future<User> login({required String email, required String password}) async {

    if (email == 'admin') {
      print("🚀 MODE ADMIN BYPASS AKTIF");

      // 1. Buat User Admin Palsu (Mock)
      // Ini datanya pura-pura, tidak diambil dari database
      const mockAdmin = User(
        id: 'ADMIN_BYPASS_001',
        name: 'Super Admin',
        username: 'admin',
        email: 'admin@quizify.com',
        role: 'admin',          // <--- PENTING: Role harus 'admin'
        subscriptionId: 1,      // 1 = Free, 2 = Premium
        isActive: true,
      );

      // 2. Simpan ke variabel lokal agar aplikasi tahu sedang login
      _currentUser = mockAdmin;
      
      // 3. Kabari Bloc/Listener bahwa user berhasil login
      _controller.add(mockAdmin);

      // 4. Langsung return user palsu ini (Login Berhasil)
      return mockAdmin;
    }



    try {
      // 1. Authenticate with Firebase
      await _firebaseAuthService.signInWithEmailPassword(
        email: email,
        password: password,
      );

      // REFRESH TOKEN to get any custom claims
      await _refreshAuthToken();

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

      //REFRESH TOKEN to get the newly set custom claims
      await _refreshAuthToken();

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
  Future<User> signInWithGoogle({String? role}) async {
    try {
      // 1. Sign in with Google via Firebase FIRST (no role needed yet)
      final credential = await _firebaseAuthService.signInWithGoogle(
        role: role ?? '', // Pass empty string if no role
      );

      if (credential == null) {
        throw Exception('Google sign in was cancelled');
      }

      final firebaseUser = credential.user!;

      // REFRESH TOKEN to get any custom claims
      await _refreshAuthToken();

      // 2. Check if user exists in MySQL
      final existingUser = await _apiService.checkGoogleUserExists(
        firebaseUser.uid,
      );

      if (existingUser != null) {
        // User exists - return them directly (existing user logging in)
        return existingUser;
      }

      // 3. New user - they need to select a role
      // Throw a special exception that the bloc will catch
      throw NeedsRoleSelectionException(
        firebaseUid: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'User',
        email: firebaseUser.email ?? '',
      );
    } catch (e) {
      // Don't rollback if user needs role selection
      if (e is NeedsRoleSelectionException) {
        rethrow;
      }
      // Rollback: Sign out from Firebase if it fails
      try {
        await _firebaseAuthService.signOut();
      } catch (_) {}
      rethrow;
    }
  }

  // New method for completing Google sign-in with role (called from role selection)
  Future<User> completeGoogleSignInWithRole({
    required String firebaseUid,
    required String name,
    required String email,
    required String role,
  }) async {
    try {
      // User already authenticated with Firebase, just create in MySQL
      final userModel = await _apiService.googleSignIn(
        name: name,
        email: email,
        firebaseUid: firebaseUid,
        role: role,
      );

      // REFRESH TOKEN to get the newly set custom claims
      await _refreshAuthToken();

      return userModel;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuthService.signOut();
    _controller.add(User.empty);
  }

  // Important: Close the stream when the repo is disposed
  void dispose() => _controller.close();

  @override
  bool isPremiumUser() {
    return _currentUser.subscriptionId == 1;
  }
}
