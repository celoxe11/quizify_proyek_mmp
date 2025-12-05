// lib/blocs/auth/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart'; // Import Repository
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Dependency is now the Repository
  final AuthenticationRepositoryImpl _authRepository;

  AuthBloc({required AuthenticationRepositoryImpl authRepository})
    : _authRepository = authRepository,
      super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<CompleteGoogleSignInRequested>(_onCompleteGoogleSignInRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = _authRepository.currentUser;
      if (user.isEmpty) {
        emit(const AuthUnauthenticated());
      } else {
        emit(AuthAuthenticated(user));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.register(
        name: event.name,
        username: event.username,
        email: event.email,
        password: event.password,
        role: event.role,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      // Call Google sign-in - it will check if user exists
      final user = await _authRepository.signInWithGoogle(role: event.role);
      emit(AuthAuthenticated(user));
    } catch (e) {
      // Check if user needs role selection (new Google user)
      if (e is NeedsRoleSelectionException) {
        // Emit state requiring role selection with user data
        emit(
          AuthRequiresRoleSelection(
            firebaseUid: e.firebaseUid,
            name: e.name,
            email: e.email,
          ),
        );
      } else {
        emit(AuthFailure(e.toString()));
        emit(const AuthUnauthenticated());
      }
    }
  }

  Future<void> _onCompleteGoogleSignInRequested(
    CompleteGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      // Complete Google sign-in by creating user with selected role
      final user = await _authRepository.completeGoogleSignInWithRole(
        firebaseUid: event.firebaseUid,
        name: event.name,
        email: event.email,
        role: event.role,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.logout();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthAuthenticated) return;

    emit(const AuthLoading());
    try {
      // TODO: Implement update profile in repository
      // final updatedUser = await _authRepository.updateProfile(
      //   userId: event.userId,
      //   name: event.name,
      //   username: event.username,
      // );
      // emit(AuthAuthenticated(updatedUser));
      emit(const AuthFailure('Update profile not yet implemented'));
    } catch (e) {
      emit(AuthFailure(e.toString()));
      // Restore previous authenticated state
      if (state is AuthAuthenticated) {
        emit(state);
      }
    }
  }

  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // TODO: Implement password reset in repository
      // await _authRepository.sendPasswordResetEmail(event.email);
      // emit(const PasswordResetSent());
      // emit(const AuthUnauthenticated());
      emit(const AuthFailure('Password reset not yet implemented'));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
