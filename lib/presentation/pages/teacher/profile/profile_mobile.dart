import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/repositories/auth_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_state.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/profile/profile_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/pages/teacher/profile/profile_photo.dart';
import 'package:quizify_proyek_mmp/presentation/pages/teacher/profile/payment_history_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/teacher/profile_detail/edit_profile_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/teacher/subscription/subscription_plan_page.dart';

/// Mobile layout for the Teacher Profile page
///
/// Uses BLoC pattern for state management.
/// Displays teacher profile information with edit, change password, and logout options.
class TeacherProfileMobile extends StatefulWidget {
  const TeacherProfileMobile({super.key});

  @override
  State<TeacherProfileMobile> createState() => _TeacherProfileMobileState();
}

class _TeacherProfileMobileState extends State<TeacherProfileMobile> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    context.read<ProfileBloc>().add(const LoadProfileEvent());
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh profile data when page becomes visible
    // This ensures points are updated after completing a quiz
    final currentState = context.read<ProfileBloc>().state;
    if (currentState is ProfileLoaded) {
      context.read<ProfileBloc>().add(const RefreshProfileEvent());
    }
  }

  /// Helper function to convert subscription ID to display string
  String _getSubscriptionLevel(int subscriptionId) {
    switch (subscriptionId) {
      case 1:
      case 3:
        return 'Free Tier';
      case 2:
      case 4:
        return 'Premium';
      default:
        return 'Gold';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.darkAzure,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSuccess) {
            if (state.action == 'logout') {
              // Navigate to login page
              context.go('/login');
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.darkAzure),
              );
            }

            if (state is ProfileError) {
              return _buildErrorState(context);
            }

            if (state is ProfileLoaded) {
              _updateControllers(state);
              return _buildContent(context, state);
            }

            return const Center(
              child: CircularProgressIndicator(color: AppColors.darkAzure),
            );
          },
        ),
      ),
    );
  }

  void _updateControllers(ProfileLoaded state) {
    _nameController.text = state.profile.name;
    _usernameController.text = state.profile.username;
    _emailController.text = state.profile.email;
  }

  Widget _buildContent(BuildContext context, ProfileLoaded state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Photo Section
            _buildProfilePhotoSection(context, state),
            const SizedBox(height: 24),

            // Role and Subscription Section
            _buildRoleSubscriptionSection(context, state),
            const SizedBox(height: 24),

            // Subscribe Button (if not premium)
            if (_getSubscriptionLevel(state.profile.subscriptionId) !=
                'Premium') ...[
              _buildSubscribeButton(context),
              const SizedBox(height: 20),
            ],

            // Transaction History Button
            _buildHistoryButton(context, state.profile.id),
            const SizedBox(height: 20),

            // Profile Information Section
            _buildProfileInfoSection(context, state),
            const SizedBox(height: 20),

            // Edit Profile Button
            if (!state.isEditMode && !state.isChangePasswordMode)
              _buildEditButton(context),

            // Change Password Mode Controls
            if (state.isChangePasswordMode)
              _buildChangePasswordModeControls(context, state),

            const SizedBox(height: 20),

            // Logout Button
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePhotoSection(BuildContext context, ProfileLoaded state) {
    return Column(
      children: [
        // [UPDATE] Gunakan Widget ProfilePhoto
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            BlocBuilder<AuthBloc, AuthState>(
              buildWhen: (prev, curr) =>
                  curr is AuthAuthenticated &&
                  prev is AuthAuthenticated &&
                  prev.user.currentAvatarUrl != curr.user.currentAvatarUrl,
              builder: (context, authState) {
                if (authState is AuthAuthenticated) {
                  return ProfilePhoto(
                    name: authState.user.name,
                    currentAvatarId: authState.user.currentAvatarId,
                    currentAvatarUrl: authState.user.currentAvatarUrl,
                    size: 120,
                  );
                }
                return const SizedBox();
              },
            ),
            // Tombol Edit Kecil
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.darkAzure,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.storefront,
                  color: Colors.white,
                  size: 20,
                ), // Ikon Toko
                onPressed: () {
                  // Shortcut ke Shop buat ganti avatar
                  context.go('/student/shop');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          state.profile.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.darkAzure,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSubscriptionSection(
    BuildContext context,
    ProfileLoaded state,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Role',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkAzure.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      state.profile.role,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkAzure,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Subscription',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getSubscriptionColor(
                        _getSubscriptionLevel(state.profile.subscriptionId),
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getSubscriptionLevel(state.profile.subscriptionId),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getSubscriptionColor(
                          _getSubscriptionLevel(state.profile.subscriptionId),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Points Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade400, Colors.amber.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stars_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  '${state.profile.points} Points',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (state is ProfileLoaded) {
                // Navigate to subscription plan page dengan userId
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        SubscriptionPlanPage(userId: state.profile.id),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Subscribe',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryButton(BuildContext context, String userId) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PaymentHistoryPage(userId: userId),
            ),
          );
        },
        icon: const Icon(Icons.history, color: AppColors.darkAzure),
        label: const Text(
          'Riwayat Transaksi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkAzure,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: AppColors.darkAzure, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoSection(BuildContext context, ProfileLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoField('Name', state.profile.name),
          const SizedBox(height: 12),
          _buildInfoField('Username', state.profile.username),
          const SizedBox(height: 12),
          _buildInfoField('Email', state.profile.email),
          const SizedBox(height: 12),
          _buildInfoField('Password', '••••••'),
        ],
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.darkAzure,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              if (context.mounted) {
                final profileBloc = context.read<ProfileBloc>();
                final state = profileBloc.state;
                if (state is ProfileLoaded) {
                  final authRepository = context
                      .read<AuthenticationRepositoryImpl>();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(
                        userId: state.profile.id,
                        initialName: state.profile.name,
                        initialUsername: state.profile.username,
                        initialEmail: state.profile.email,
                        profileBloc: profileBloc,
                        authRepository: authRepository,
                      ),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkAzure,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        // const SizedBox(width: 8),
        // Expanded(
        //   child: ElevatedButton.icon(
        //     onPressed: () {
        //       _showChangePasswordDialog(context);
        //     },
        //     icon: const Icon(Icons.lock),
        //     label: const Text('Password'),
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: Colors.orange,
        //       padding: const EdgeInsets.symmetric(vertical: 14),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(12),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  // Widget _buildEditModeControls(BuildContext context, ProfileLoaded state) {
  //   return Column(
  //     children: [
  //       _buildEditField('Name', _nameController),
  //       const SizedBox(height: 12),
  //       _buildEditField('Username', _usernameController),
  //       const SizedBox(height: 12),
  //       _buildEditField('Email', _emailController),
  //       const SizedBox(height: 16),
  //       Row(
  //         children: [
  //           Expanded(
  //             child: ElevatedButton(
  //               onPressed: () {
  //                 context.read<ProfileBloc>().add(
  //                   // TODO: Use EditProfilePage navigation instead
  //                   const RefreshProfileEvent(),
  //                 );
  //               },
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.green,
  //                 padding: const EdgeInsets.symmetric(vertical: 14),
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //               ),
  //               child: const Text(
  //                 'Save',
  //                 style: TextStyle(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.white,
  //                 ),
  //               ),
  //             ),
  //           ),
  //           const SizedBox(width: 8),
  //           Expanded(
  //             child: OutlinedButton(
  //               onPressed: () {
  //                 // Cancel edit mode - reload profile
  //                 context.read<ProfileBloc>().add(const RefreshProfileEvent());
  //               },
  //               style: OutlinedButton.styleFrom(
  //                 padding: const EdgeInsets.symmetric(vertical: 14),
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //               ),
  //               child: const Text(
  //                 'Cancel',
  //                 style: TextStyle(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.bold,
  //                   color: AppColors.darkAzure,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget _buildEditField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.darkAzure,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChangePasswordModeControls(
    BuildContext context,
    ProfileLoaded state,
  ) {
    return Column(
      children: [
        _buildEditField('Old Password', _oldPasswordController),
        const SizedBox(height: 12),
        _buildEditField('New Password', _newPasswordController),
        const SizedBox(height: 12),
        _buildEditField('Confirm Password', _confirmPasswordController),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              context.read<ProfileBloc>().add(
                ChangePasswordEvent(
                  oldPassword: _oldPasswordController.text,
                  newPassword: _newPasswordController.text,
                  confirmPassword: _confirmPasswordController.text,
                ),
              );
              // Clear fields
              _oldPasswordController.clear();
              _newPasswordController.clear();
              _confirmPasswordController.clear();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Change Password',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // Cancel change password mode
              context.read<ProfileBloc>().add(const RefreshProfileEvent());
              _oldPasswordController.clear();
              _newPasswordController.clear();
              _confirmPasswordController.clear();
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkAzure,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _showLogoutConfirmation(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    // Get ProfileBloc from context BEFORE creating the dialog
    final profileBloc = context.read<ProfileBloc>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                profileBloc.add(const LogoutEvent());
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // void _showChangePasswordDialog(BuildContext context) {
  //   // Capture parent context so we can read providers located above this widget
  //   final parentContext = context;

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext dialogContext) {
  //       return AlertDialog(
  //         title: const Text('Change Password'),
  //         content: SingleChildScrollView(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               _buildEditField('Old Password', _oldPasswordController),
  //               const SizedBox(height: 12),
  //               _buildEditField('New Password', _newPasswordController),
  //               const SizedBox(height: 12),
  //               _buildEditField('Confirm Password', _confirmPasswordController),
  //             ],
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(dialogContext).pop();
  //               _oldPasswordController.clear();
  //               _newPasswordController.clear();
  //               _confirmPasswordController.clear();
  //             },
  //             child: const Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               // Use parent context to access the ProfileBloc provider
  //               parentContext.read<ProfileBloc>().add(
  //                 ChangePasswordEvent(
  //                   oldPassword: _oldPasswordController.text,
  //                   newPassword: _newPasswordController.text,
  //                   confirmPassword: _confirmPasswordController.text,
  //                 ),
  //               );
  //               Navigator.of(dialogContext).pop();
  //               _oldPasswordController.clear();
  //               _newPasswordController.clear();
  //               _confirmPasswordController.clear();
  //             },
  //             child: const Text('Change'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Failed to load profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<ProfileBloc>().add(const LoadProfileEvent());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkAzure,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // void _submitChangePassword() {
  //   final oldPassword = _oldPasswordController.text.trim();
  //   final newPassword = _newPasswordController.text.trim();
  //   final confirmPassword = _confirmPasswordController.text.trim();

  //   if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text('Harap isi semua kolom')));
  //     return;
  //   }

  //   context.read<ProfileBloc>().add(
  //     ChangePasswordEvent(
  //       oldPassword: oldPassword,
  //       newPassword: newPassword,
  //       confirmPassword: confirmPassword,
  //     ),
  //   );

  //   // Bersihkan controller setelah submit
  //   _oldPasswordController.clear();
  //   _newPasswordController.clear();
  //   _confirmPasswordController.clear();
  // }

  Color _getSubscriptionColor(String level) {
    if (level == 'Premium') return Colors.amber[700] ?? Colors.amber;
    if (level == 'Gold') return Colors.orange[700] ?? Colors.orange;
    return Colors.blue;
  }
}
