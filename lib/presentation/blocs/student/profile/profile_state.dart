part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Loading state
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Loaded state with profile data
class ProfileLoaded extends ProfileState {
  final UserModel profile;
  final bool isEditMode;
  final bool isChangePasswordMode;

  const ProfileLoaded({
    required this.profile,
    this.isEditMode = false,
    this.isChangePasswordMode = false,
  });

  ProfileLoaded copyWith({
    UserModel? profile,
    bool? isEditMode,
    bool? isChangePasswordMode,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      isEditMode: isEditMode ?? this.isEditMode,
      isChangePasswordMode: isChangePasswordMode ?? this.isChangePasswordMode,
    );
  }

  @override
  List<Object?> get props => [profile, isEditMode, isChangePasswordMode];
}

/// Error state
class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Success state for actions like update, password change, logout
class ProfileSuccess extends ProfileState {
  final String message;
  final String action; // 'update', 'password_change', 'logout', 'subscribe'

  const ProfileSuccess({
    required this.message,
    required this.action,
  });

  @override
  List<Object?> get props => [message, action];
}
