part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load the teacher's profile
class LoadProfileEvent extends ProfileEvent {
  const LoadProfileEvent();
}

/// Event to refresh the profile
class RefreshProfileEvent extends ProfileEvent {
  const RefreshProfileEvent();
}

/// Event to update the profile photo
class UpdateProfilePhotoEvent extends ProfileEvent {
  final String photoUrl;

  const UpdateProfilePhotoEvent(this.photoUrl);

  @override
  List<Object?> get props => [photoUrl];
}

/// Event to edit the profile (name, username, email)
class EditProfileEvent extends ProfileEvent {
  final String name;
  final String username;
  final String email;

  const EditProfileEvent({
    required this.name,
    required this.username,
    required this.email,
  });

  @override
  List<Object?> get props => [name, username, email];
}

/// Event to change password
class ChangePasswordEvent extends ProfileEvent {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordEvent({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [oldPassword, newPassword, confirmPassword];
}

/// Event to logout
class LogoutEvent extends ProfileEvent {
  const LogoutEvent();
}

/// Event to subscribe
class SubscribeEvent extends ProfileEvent {
  final String planId;

  const SubscribeEvent(this.planId);

  @override
  List<Object?> get props => [planId];
}
