part of 'edit_profile_bloc.dart';

abstract class EditProfileState extends Equatable {
  const EditProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class EditProfileInitial extends EditProfileState {
  const EditProfileInitial();
}

/// State ketika form sedang diisi
class EditProfileFormState extends EditProfileState {
  final String initialName;
  final String initialUsername;
  final String initialEmail;
  final String name;
  final String username;
  final String email;
  final bool isNameValid;
  final bool isUsernameValid;
  final bool isEmailValid;

  const EditProfileFormState({
    required this.initialName,
    required this.initialUsername,
    required this.initialEmail,
    required this.name,
    required this.username,
    required this.email,
    required this.isNameValid,
    required this.isUsernameValid,
    required this.isEmailValid,
  });

  bool get isFormValid => isNameValid && isUsernameValid && isEmailValid;
  
  // Check mana field yang berubah
  bool get isNameChanged => initialName != name;
  bool get isUsernameChanged => initialUsername != username;
  bool get isEmailChanged => initialEmail != email;

  EditProfileFormState copyWith({
    String? initialName,
    String? initialUsername,
    String? initialEmail,
    String? name,
    String? username,
    String? email,
    bool? isNameValid,
    bool? isUsernameValid,
    bool? isEmailValid,
  }) {
    return EditProfileFormState(
      initialName: initialName ?? this.initialName,
      initialUsername: initialUsername ?? this.initialUsername,
      initialEmail: initialEmail ?? this.initialEmail,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      isNameValid: isNameValid ?? this.isNameValid,
      isUsernameValid: isUsernameValid ?? this.isUsernameValid,
      isEmailValid: isEmailValid ?? this.isEmailValid,
    );
  }

  @override
  List<Object?> get props =>
      [initialName, initialUsername, initialEmail, name, username, email, isNameValid, isUsernameValid, isEmailValid];
}

/// State ketika sedang menyimpan
class EditProfileSaving extends EditProfileState {
  const EditProfileSaving();
}

/// State ketika berhasil disimpan
class EditProfileSuccess extends EditProfileState {
  final String message;

  const EditProfileSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// State ketika ada error
class EditProfileError extends EditProfileState {
  final String message;

  const EditProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
