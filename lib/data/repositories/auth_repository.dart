import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
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

  // Timer for periodic token refresh
  Timer? _tokenRefreshTimer;

  // SharedPreferences key for user data
  static const String _userCacheKey = 'cached_user_data';

  AuthenticationRepositoryImpl({
    AuthService? firebaseAuthService,
    AuthApiService? apiService,
  }) : _firebaseAuthService = firebaseAuthService ?? AuthService(),
       _apiService = apiService ?? AuthApiService() {
    // Initialize by loading cached user data first
    _initializeUserFromCache();

    // Listen to Firebase Auth changes and sync with our backend data
    _firebaseAuthService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        try {
          // Refresh token to get latest custom claims
          await _refreshAuthToken();

          // If firebase user exists, fetch full profile from MySQL (Node.js)
          final userModel = await _apiService.getUserProfile();
          _currentUser = userModel;

          // Cache the user data
          await _cacheUserData(userModel);

          _controller.add(userModel);

          // Start periodic token refresh (every 50 minutes)
          _startTokenRefreshTimer();
        } catch (e) {
          print('Error fetching user profile: $e');
          // If API fetch fails but Firebase is logged in, use cached data
          final cachedUser = await _getCachedUser();
          if (cachedUser != null && !cachedUser.isEmpty) {
            _currentUser = cachedUser;
            _controller.add(cachedUser);
            _startTokenRefreshTimer();
          } else {
            _currentUser = User.empty;
            _controller.add(User.empty);
          }
        }
      } else {
        _currentUser = User.empty;
        _controller.add(User.empty);
        await _clearCachedUser();
        _stopTokenRefreshTimer();
      }
    });
  }

  // Initialize user from cache on app start
  Future<void> _initializeUserFromCache() async {
    try {
      final cachedUser = await _getCachedUser();
      if (cachedUser != null && !cachedUser.isEmpty) {
        _currentUser = cachedUser;
        _controller.add(cachedUser);
      }
    } catch (e) {
      print('Error loading cached user: $e');
    }
  }

  // Cache user data to SharedPreferences
  Future<void> _cacheUserData(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode({
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'username': user.username,
        'role': user.role,
        'subscription_id': user.subscriptionId,
        'created_at': user.createdAt?.toIso8601String(),
        'updated_at': user.updatedAt?.toIso8601String(),
      });
      await prefs.setString(_userCacheKey, userJson);
    } catch (e) {
      print('Error caching user data: $e');
    }
  }

  // Get cached user data from SharedPreferences
  Future<User?> _getCachedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userCacheKey);
      if (userJson != null) {
        final Map<String, dynamic> userData = jsonDecode(userJson);
        return User(
          id: userData['id'] ?? '',
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          username: userData['username'] ?? '',
          role: userData['role'] ?? '',
          subscriptionId: userData['subscription_id'] ?? 0,
          createdAt: userData['created_at'] != null
              ? DateTime.parse(userData['created_at'])
              : null,
          updatedAt: userData['updated_at'] != null
              ? DateTime.parse(userData['updated_at'])
              : null,
        );
      }
    } catch (e) {
      print('Error reading cached user: $e');
    }
    return null;
  }

  // Clear cached user data
  Future<void> _clearCachedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userCacheKey);
    } catch (e) {
      print('Error clearing cached user: $e');
    }
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
        role: 'admin', // <--- PENTING: Role harus 'admin'
        subscriptionId: 1, // 1 = Free, 2 = Premium
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

      // Cache the user data
      await _cacheUserData(userModel);

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

      // Cache the user data
      await _cacheUserData(userModel);

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
        await _cacheUserData(existingUser);
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

  @override
  Future<User> getUserProfile() async {
    // Panggil API /me atau endpoint yang mengembalikan data user lengkap
    final userModel = await _apiService.getUserProfile();
    _currentUser = userModel;
    _controller.add(userModel); // Update stream
    return userModel;
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

      // Cache the user data
      await _cacheUserData(userModel);

      return userModel;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User> updateUserProfile({
    required String userId,
    String? name,
    String? username,
    String? email,
  }) async {
    try {
      // Call API to update user profile (only sends changed fields)
      final updatedUser = await _apiService.updateUserProfile(
        userId: userId,
        name: name,
        username: username,
        email: email,
      );

      // Update cached user
      _currentUser = updatedUser;
      _controller.add(updatedUser);

      return updatedUser;
    } catch (e, stackTrace) {
      throw Exception('Gagal memperbarui profil: ${e.toString()}');
    }
  }

  @override
  Future<void> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      // Pastikan user sudah login Firebase
      if (_firebaseAuthService.currentUser == null) {
        throw Exception('User not authenticated. Please login again.');
      }
      // Refresh token agar header Authorization valid
      await _refreshAuthToken();

      // Request ke backend
      await _apiService.changePassword(
        userId: userId,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      // Refresh profile user setelah ganti password
      final refreshed = await _apiService.getUserProfile();
      _currentUser = refreshed;
      await _cacheUserData(refreshed);
      _controller.add(refreshed);
    } catch (e) {
      print('❌ [AuthRepository] Error updating password: $e');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuthService.signOut();
    await _clearCachedUser();
    _controller.add(User.empty);
  }

  // Start periodic token refresh (every 50 minutes)
  void _startTokenRefreshTimer() {
    _stopTokenRefreshTimer(); // Cancel existing timer if any
    _tokenRefreshTimer = Timer.periodic(const Duration(minutes: 50), (
      timer,
    ) async {
      if (_firebaseAuthService.currentUser != null) {
        try {
          await _refreshAuthToken();
          // Optionally refresh user profile from backend
          final userModel = await _apiService.getUserProfile();
          _currentUser = userModel;

          // Update cache
          await _cacheUserData(userModel);

          _controller.add(userModel);
        } catch (_) {
          // Silent fail - token refresh will retry next period
        }
      } else {
        _stopTokenRefreshTimer();
      }
    });
  }

  // Stop token refresh timer
  void _stopTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
  }

  // Important: Close the stream when the repo is disposed
  void dispose() {
    _stopTokenRefreshTimer();
    _controller.close();
  }

  @override
  bool isPremiumUser() {
    print("Current User: ${_currentUser.toString()}");
    print('Subscription ID: ${_currentUser.subscriptionId}');
    return _currentUser.subscriptionId == 2 || _currentUser.subscriptionId == 4;
  }
  
}
