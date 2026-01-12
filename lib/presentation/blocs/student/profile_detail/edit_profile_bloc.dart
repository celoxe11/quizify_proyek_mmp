import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/domain/repositories/auth_repository.dart';

part 'edit_profile_event.dart';
part 'edit_profile_state.dart';

/// BLoC untuk manage edit profile form
class EditProfileBloc extends Bloc<FormEditProfileEvent, EditProfileState> {
  final AuthenticationRepository authRepository;

  EditProfileBloc({required this.authRepository}) : super(const EditProfileInitial()) {
    on<InitializeEditProfileEvent>(_onInitialize);
    on<NameChangedEvent>(_onNameChanged);
    on<UsernameChangedEvent>(_onUsernameChanged);
    on<EmailChangedEvent>(_onEmailChanged);
    on<SaveProfileEvent>(_onSaveProfile);
  }

  /// Initialize form dengan data yang ada
  Future<void> _onInitialize(
    InitializeEditProfileEvent event,
    Emitter<EditProfileState> emit,
  ) async {
    emit(EditProfileFormState(
      initialName: event.name,
      initialUsername: event.username,
      initialEmail: event.email,
      name: event.name,
      username: event.username,
      email: event.email,
      isNameValid: _isNameValid(event.name),
      isUsernameValid: _isUsernameValid(event.username),
      isEmailValid: _isEmailValid(event.email),
    ));
  }

  /// Handle name change
  Future<void> _onNameChanged(
    NameChangedEvent event,
    Emitter<EditProfileState> emit,
  ) async {
    if (state is EditProfileFormState) {
      final currentState = state as EditProfileFormState;
      emit(currentState.copyWith(
        name: event.name,
        isNameValid: _isNameValid(event.name),
      ));
    }
  }

  /// Handle username change
  Future<void> _onUsernameChanged(
    UsernameChangedEvent event,
    Emitter<EditProfileState> emit,
  ) async {
    if (state is EditProfileFormState) {
      final currentState = state as EditProfileFormState;
      emit(currentState.copyWith(
        username: event.username,
        isUsernameValid: _isUsernameValid(event.username),
      ));
    }
  }

  /// Handle email change
  Future<void> _onEmailChanged(
    EmailChangedEvent event,
    Emitter<EditProfileState> emit,
  ) async {
    if (state is EditProfileFormState) {
      final currentState = state as EditProfileFormState;
      emit(currentState.copyWith(
        email: event.email,
        isEmailValid: _isEmailValid(event.email),
      ));
    }
  }

  /// Save profile
  Future<void> _onSaveProfile(
    SaveProfileEvent event,
    Emitter<EditProfileState> emit,
  ) async {
    try {
      // Get current state to check which fields have changed
      if (state is! EditProfileFormState) {
        emit(const EditProfileError('Form is not initialized'));
        return;
      }

      final currentState = state as EditProfileFormState;
      
      // Use current state values untuk validation (bukan event values)
      final name = currentState.name;
      final username = currentState.username;
      final email = currentState.email;

      // Validate semua field
      if (!_isNameValid(name)) {
        emit(const EditProfileError('Name is not valid'));
        return;
      }

      if (!_isUsernameValid(username)) {
        emit(const EditProfileError('Username is not valid'));
        return;
      }

      if (!_isEmailValid(email)) {
        emit(const EditProfileError('Email is not valid'));
        return;
      }

      emit(const EditProfileSaving());

      // Only send field yang berubah
      final changedName = currentState.isNameChanged ? name : null;
      final changedUsername = currentState.isUsernameChanged ? username : null;
      final changedEmail = currentState.isEmailChanged ? email : null;

      await authRepository.updateUserProfile(
        userId: event.userId,
        name: changedName,
        username: changedUsername,
        email: changedEmail,
      );

      emit(const EditProfileSuccess('Successfully saved profile'));
    } catch (e) {
      emit(EditProfileError('Failed to save profile: ${e.toString()}'));
    }
  }

  /// Validate name (minimum 2 characters)
  bool _isNameValid(String name) {
    return name.isNotEmpty && name.length >= 2;
  }

  /// Validasi username (minimal 3 karakter, hanya alfanumerik dan underscore)
  bool _isUsernameValid(String username) {
    if (username.isEmpty || username.length < 3) return false;
    return RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username);
  }

  /// Validasi email
  bool _isEmailValid(String email) {
    return email.isNotEmpty &&
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
            .hasMatch(email);
  }
}
