import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// New state: Google user authenticated but needs to select role
class AuthRequiresRoleSelection extends AuthState {
  final String firebaseUid;
  final String name;
  final String email;

  const AuthRequiresRoleSelection({
    required this.firebaseUid,
    required this.name,
    required this.email,
  });

  @override
  List<Object?> get props => [firebaseUid, name, email];
}

class PasswordResetSent extends AuthState {
  const PasswordResetSent();
}
