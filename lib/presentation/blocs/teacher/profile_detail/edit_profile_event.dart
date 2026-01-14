part of 'edit_profile_bloc.dart';

abstract class FormEditProfileEvent extends Equatable {
  const FormEditProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event untuk memulai edit profile
class InitializeEditProfileEvent extends FormEditProfileEvent {
  final String userId;
  final String name;
  final String username;
  final String email;

  const InitializeEditProfileEvent({
    required this.userId,
    required this.name,
    required this.username,
    required this.email,
  });

  @override
  List<Object?> get props => [userId, name, username, email];
}

/// Event untuk mengubah nama
class NameChangedEvent extends FormEditProfileEvent {
  final String name;

  const NameChangedEvent(this.name);

  @override
  List<Object?> get props => [name];
}

/// Event untuk mengubah username
class UsernameChangedEvent extends FormEditProfileEvent {
  final String username;

  const UsernameChangedEvent(this.username);

  @override
  List<Object?> get props => [username];
}

/// Event untuk mengubah email
class EmailChangedEvent extends FormEditProfileEvent {
  final String email;

  const EmailChangedEvent(this.email);

  @override
  List<Object?> get props => [email];
}

/// Event untuk submit/save profile
class SaveProfileEvent extends FormEditProfileEvent {
  final String userId;
  final String name;
  final String username;
  final String email;

  const SaveProfileEvent({
    required this.userId,
    required this.name,
    required this.username,
    required this.email,
  });

  @override
  List<Object?> get props => [userId, name, username, email];
}
