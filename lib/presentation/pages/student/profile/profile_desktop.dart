import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/repositories/auth_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/profile/profile_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/profile_detail/edit_profile_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/profile_detail/edit_profile_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/subscription/subscription_plan_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/profile/payment_history_page.dart';

/// Desktop layout for the Student Profile page
///
/// Uses BLoC pattern for state management.
/// Displays student profile information with edit, change password, and logout options.
class StudentProfileDesktop extends StatefulWidget {
  const StudentProfileDesktop({super.key});

  @override
  State<StudentProfileDesktop> createState() => _StudentProfileDesktopState();
}

class _StudentProfileDesktopState extends State<StudentProfileDesktop> {
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
    // LoadProfileEvent will be triggered from main.dart route
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

  /// Helper function to convert subscription ID to display string
  String _getSubscriptionLevel(int subscriptionId) {
    switch (subscriptionId) {
      case 1:
        return 'Free Tier';
      case 2:
        return 'Premium';
      default:
        return 'Gold';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSuccess) {
            if (state.action == 'logout') {
              // Navigate to login page
              context.go('/login');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
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
                child:
                    CircularProgressIndicator(color: AppColors.darkAzure),
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
              child:
                  CircularProgressIndicator(color: AppColors.darkAzure),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.darkAzure,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Text(
        'Student Profile',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        // Refresh button
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            context.read<ProfileBloc>().add(const RefreshProfileEvent());
          },
          tooltip: 'Refresh',
        ),
        const SizedBox(width: 16),
      ],
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
        padding: const EdgeInsets.all(40),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Side - Profile Photo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProfilePhotoSection(context, state),
                  const SizedBox(height: 32),
                  _buildRoleSubscriptionSection(context, state),
                  const SizedBox(height: 24),
                  if (_getSubscriptionLevel(state.profile.subscriptionId) != 'Premium') ...[
                    _buildSubscribeButton(context),
                    const SizedBox(height: 16),
                    _buildHistoryButton(context, state.profile.id),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 48),
            // Right Side - Profile Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Information',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildProfileInfoSection(context, state),
                  const SizedBox(height: 32),
                  // Buttons Section
                  if (!state.isEditMode && !state.isChangePasswordMode)
                    _buildActionButtons(context, state),
                  // Edit Mode
                  if (state.isEditMode) _buildEditModeControls(context, state),
                  // Change Password Mode
                  if (state.isChangePasswordMode)
                    _buildChangePasswordModeControls(context, state),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePhotoSection(
      BuildContext context, ProfileLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.darkAzure,
              width: 4,
            ),
            image: DecorationImage(
              image: NetworkImage(
                  'https://ui-avatars.com/api/?name=${state.profile.name}&size=200&background=random'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkAzure,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          state.profile.name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.darkAzure,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '@${state.profile.username}',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSubscriptionSection(
      BuildContext context, ProfileLoaded state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          _buildStatusRow('Role', state.profile.role, AppColors.darkAzure),
          const SizedBox(height: 16),
          _buildStatusRow(
            'Subscription',
            _getSubscriptionLevel(state.profile.subscriptionId),
            _getSubscriptionColor(_getSubscriptionLevel(state.profile.subscriptionId)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscribeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Navigate to subscription plan page with current userId (mobile behaviour)
          final state = context.read<ProfileBloc>().state;
          if (state is ProfileLoaded) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SubscriptionPlanPage(userId: state.profile.id),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
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
  }

  Widget _buildHistoryButton(BuildContext context, String userId) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PaymentHistoryPage(userId: userId),
            ),
          );
        },
        icon: const Icon(Icons.history),
        label: const Text(
          'Riwayat Transaksi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkAzure,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoSection(
      BuildContext context, ProfileLoaded state) {
    if (state.isEditMode) {
      return _buildEditFields();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Name', state.profile.name),
          const SizedBox(height: 16),
          _buildInfoRow('Username', state.profile.username),
          const SizedBox(height: 16),
          _buildInfoRow('Email', state.profile.email),
          const SizedBox(height: 16),
          _buildInfoRow('Password', '••••••'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.darkAzure,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEditFields() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEditField('Name', _nameController),
          const SizedBox(height: 16),
          _buildEditField('Username', _usernameController),
          const SizedBox(height: 16),
          _buildEditField('Email', _emailController),
        ],
      ),
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller,
  ) {
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
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  Widget _buildActionButtons(BuildContext context, ProfileLoaded state) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              if (context.mounted) {
                final profileBloc = context.read<ProfileBloc>();
                final state = profileBloc.state;
                if (state is ProfileLoaded) {
                  final authRepository = context.read<AuthenticationRepositoryImpl>();
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
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkAzure,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Expanded(
        //   child: ElevatedButton.icon(
        //     onPressed: () {
        //       if (context.mounted) {
        //         final state = context.read<ProfileBloc>().state;
        //         if (state is ProfileLoaded) {
        //           // Emit event to toggle change password mode
        //           // This is handled by emitting a state that shows password fields
        //           _showChangePasswordDialog(context);
        //         }
        //       }
        //     },
        //     icon: const Icon(Icons.lock),
        //     label: const Text('Change Password'),
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: Colors.orange,
        //       foregroundColor: Colors.white,
        //       padding: const EdgeInsets.symmetric(vertical: 14),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(12),
        //       ),
        //     ),
        //   ),
        // ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              _showLogoutConfirmation(context);
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditModeControls(BuildContext context, ProfileLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.read<ProfileBloc>().add(
                    // TODO: Use EditProfilePage navigation instead
                    const RefreshProfileEvent(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  context.read<ProfileBloc>().add(const RefreshProfileEvent());
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
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkAzure,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChangePasswordModeControls(
      BuildContext context, ProfileLoaded state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEditField('Old Password', _oldPasswordController),
          const SizedBox(height: 16),
          _buildEditField('New Password', _newPasswordController),
          const SizedBox(height: 16),
          _buildEditField('Confirm Password', _confirmPasswordController),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
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
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context
                        .read<ProfileBloc>()
                        .add(const RefreshProfileEvent());
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
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkAzure,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEditField('Old Password', _oldPasswordController),
                const SizedBox(height: 16),
                _buildEditField('New Password', _newPasswordController),
                const SizedBox(height: 16),
                _buildEditField('Confirm Password', _confirmPasswordController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _oldPasswordController.clear();
                _newPasswordController.clear();
                _confirmPasswordController.clear();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<ProfileBloc>().add(
                  ChangePasswordEvent(
                    oldPassword: _oldPasswordController.text,
                    newPassword: _newPasswordController.text,
                    confirmPassword: _confirmPasswordController.text,
                  ),
                );
                Navigator.of(context).pop();
                _oldPasswordController.clear();
                _newPasswordController.clear();
                _confirmPasswordController.clear();
              },
              child: const Text('Change'),
            ),
          ],
        );
      },
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
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 120, color: Colors.red[300]),
          const SizedBox(height: 24),
          Text(
            'Failed to load profile',
            style: TextStyle(
              fontSize: 24,
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

  Color _getSubscriptionColor(String level) {
    if (level == 'Premium') {
      return Colors.amber[700] ?? Colors.amber;
    }
    return Colors.blue;
  }
}
