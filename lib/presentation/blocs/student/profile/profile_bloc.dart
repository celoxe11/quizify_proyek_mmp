import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/data/models/user_model.dart';
import 'package:quizify_proyek_mmp/domain/repositories/auth_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// BLoC for managing student profile
///
/// Handles loading, updating, and managing student profile information.
/// This BLoC manages:
/// - Profile data loading
/// - Profile editing (name, username, email)
/// - Password changes
/// - Subscription management
/// - Logout functionality
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthenticationRepository authRepository;

  ProfileBloc({required this.authRepository}) : super(const ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<RefreshProfileEvent>(_onRefreshProfile);
    on<UpdateProfilePhotoEvent>(_onUpdateProfilePhoto);
    on<EditProfileEvent>(_onEditProfile);
    on<ChangePasswordEvent>(_onChangePassword);
    on<SubscribeEvent>(_onSubscribe);
    on<LogoutEvent>(_onLogout);
  }

  /// Load student profile
  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      // Get current logged-in user from repository
      final currentUser = authRepository.currentUser;

      if (currentUser.id.isEmpty) {
        emit(const ProfileError('User not authenticated. Please login again.'));
        return;
      }

      // Convert User entity to UserModel
      final profile = UserModel(
        id: currentUser.id,
        name: currentUser.name,
        username: currentUser.username,
        email: currentUser.email,
        firebaseUid: currentUser.firebaseUid,
        role: currentUser.role,
        subscriptionId: currentUser.subscriptionId,
        isActive: currentUser.isActive,
        currentAvatarId: currentUser.currentAvatarId,
        currentAvatarUrl: currentUser.currentAvatarUrl,
        createdAt: currentUser.createdAt,
        updatedAt: currentUser.updatedAt,
      );


      emit(ProfileLoaded(profile: profile));
    } catch (e) {
      emit(ProfileError('Failed to load profile: ${e.toString()}'));
    }
  }

  /// Refresh student profile
  Future<void> _onRefreshProfile(
    RefreshProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      emit(const ProfileLoading());
      try {
        final updatedUser = await authRepository.getUserProfile(); 

      // Konversi ke UserModel (jika repo mengembalikan Entity)
      final profile = UserModel.fromEntity(updatedUser);


        emit(ProfileLoaded(profile: profile));
      } catch (e) {
        emit(ProfileError('Failed to refresh profile: ${e.toString()}'));
      }
    }
  }

  /// Update profile photo
  Future<void> _onUpdateProfilePhoto(
    UpdateProfilePhotoEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      try {
        // TODO: Replace with actual API call
        // Note: User entity doesn't have photoUrl field
        // This can be extended if needed

        emit(
          const ProfileSuccess(
            message: 'Photo updated successfully',
            action: 'photo_update',
          ),
        );
        // Reload loaded state after success message
        emit(ProfileLoaded(profile: currentState.profile));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    }
  }

  /// Edit profile information
  Future<void> _onEditProfile(
    EditProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      try {
        // TODO: Replace with actual API call
        final updatedProfile = UserModel(
          id: currentState.profile.id,
          name: event.name,
          username: event.username,
          email: event.email,
          firebaseUid: currentState.profile.firebaseUid,
          role: currentState.profile.role,
          subscriptionId: currentState.profile.subscriptionId,
          isActive: currentState.profile.isActive,

          // WAJIB
          currentAvatarId: currentState.profile.currentAvatarId,
          currentAvatarUrl: currentState.profile.currentAvatarUrl,

          createdAt: currentState.profile.createdAt,
          updatedAt: DateTime.now(),
        );


        emit(currentState.copyWith(profile: updatedProfile));
        emit(
          const ProfileSuccess(
            message: 'Profile updated successfully',
            action: 'update',
          ),
        );
        // Reload loaded state after success message
        emit(ProfileLoaded(profile: updatedProfile));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    }
  }

  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(const ProfileLoading()); // Tampilkan loading saat proses

      try {
        // 1. Validasi Client-side
        if (event.newPassword != event.confirmPassword) {
          emit(const ProfileError('Konfirmasi password tidak cocok'));
          emit(ProfileLoaded(profile: currentState.profile));
          return;
        }

        if (event.newPassword.length < 6) {
          emit(const ProfileError('Password minimal 6 karakter'));
          emit(ProfileLoaded(profile: currentState.profile));
          return;
        }

        // 2. Panggil Repository
        await authRepository.changePassword(
          userId: currentState.profile.id,
          oldPassword: event.oldPassword,
          newPassword: event.newPassword,
        );

        // 3. Emit Success
        emit(
          const ProfileSuccess(
            message: 'Password berhasil diperbarui',
            action: 'password_change',
          ),
        );

        // Kembali ke state loaded
        emit(ProfileLoaded(profile: currentState.profile));
      } catch (e) {
        emit(ProfileError(e.toString()));
        emit(ProfileLoaded(profile: currentState.profile));
      }
    }
  }

  /// Subscribe to premium plan
  Future<void> _onSubscribe(
    SubscribeEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      try {
        // TODO: Replace with actual API call
        final updatedProfile = UserModel(
          id: currentState.profile.id,
          name: currentState.profile.name,
          username: currentState.profile.username,
          email: currentState.profile.email,
          firebaseUid: currentState.profile.firebaseUid,
          role: currentState.profile.role,
          subscriptionId: 2, // 2 = Premium subscription
          isActive: currentState.profile.isActive,
          createdAt: currentState.profile.createdAt,
          updatedAt: DateTime.now(),
        );

        emit(currentState.copyWith(profile: updatedProfile));
        emit(
          const ProfileSuccess(
            message: 'Subscription activated',
            action: 'subscribe',
          ),
        );
        // Reload loaded state after success message
        emit(ProfileLoaded(profile: updatedProfile));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    }
  }

  /// Logout
  Future<void> _onLogout(LogoutEvent event, Emitter<ProfileState> emit) async {
    try {
      print('Logging out...');

      // Call actual logout dari repository
      await authRepository.logout();

      print('Logged out successfully');
      emit(
        const ProfileSuccess(
          message: 'Logged out successfully',
          action: 'logout',
        ),
      );
    } catch (e) {
      print('Logout error: $e');
      emit(ProfileError(e.toString()));
    }
  }
}
