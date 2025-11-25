import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String username;
  final String email;
  final String password;
  final String role;

  const RegisterRequested({
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [name, username, email, password, role];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class GoogleSignInRequested extends AuthEvent {
  final String role;

  const GoogleSignInRequested({required this.role});

  @override
  List<Object?> get props => [role];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class UpdateProfileRequested extends AuthEvent {
  final String userId;
  final String? name;
  final String? username;

  const UpdateProfileRequested({
    required this.userId,
    this.name,
    this.username,
  });

  @override
  List<Object?> get props => [userId, name, username];
}

class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}
