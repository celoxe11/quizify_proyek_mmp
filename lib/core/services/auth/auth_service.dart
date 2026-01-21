import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Platform-aware GoogleSignIn configuration
  // serverClientId is ONLY for mobile (Android/iOS), NOT for web
  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Only provide serverClientId on mobile platforms
    serverClientId: kIsWeb
        ? null
        : '770798800435-7fck3mg1vsk7rv212u2navj5ksl49aei.apps.googleusercontent.com',
  );

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle({required String role}) async {
    try {
      // Ensure fresh chooser by signing out cached google session
      try {
        await _googleSignIn.signOut();
        await _auth.signOut();
      } catch (_) {}

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Send to your backend: userCredential.user!.uid and role
      // Backend should return existing user if uid exists, or create using supplied role
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // Update user profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
      }
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // Handle Firebase Auth errors
  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
