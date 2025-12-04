import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'role_selection_common.dart';

class RoleSelectionMobile extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const RoleSelectionMobile({Key? key, this.userData}) : super(key: key);

  @override
  State<RoleSelectionMobile> createState() => _RoleSelectionMobileState();
}

class _RoleSelectionMobileState extends State<RoleSelectionMobile> {
  String? _selectedRole;

  void _selectRole(String role) {
    setState(() {
      _selectedRole = role;
    });
  }

  void _handleContinue() {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your role'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userData = widget.userData;
    final isGoogleSignIn = userData?['isGoogleSignIn'] == true;

    if (isGoogleSignIn) {
      // Complete Google sign-in with role
      RoleSelectionActions.handleGoogleSignInWithRole(
        context,
        userData: userData!,
        role: _selectedRole!,
      );
    } else if (userData != null) {
      // Registration flow with role
      RoleSelectionActions.handleRegistrationWithRole(
        context,
        userData: userData,
        role: _selectedRole!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightCyan,
      appBar: AppBar(
        backgroundColor: AppColors.lightCyan,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.darkAzure),
          onPressed: () => context.pop(),
        ),
      ),
      body: RoleSelectionListener(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Choose Your Role',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkAzure,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select whether you\'re a teacher or student to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.darkTurquoise,
                  ),
                ),
                const SizedBox(height: 40),

                // Role Cards
                Expanded(
                  child: Column(
                    children: [
                      _buildRoleCard(
                        role: 'teacher',
                        title: 'Teacher',
                        description:
                            'Create and manage quizzes for your students',
                        icon: Icons.school,
                        isSelected: _selectedRole == 'teacher',
                      ),
                      const SizedBox(height: 16),
                      _buildRoleCard(
                        role: 'student',
                        title: 'Student',
                        description: 'Join and participate in quizzes',
                        icon: Icons.person,
                        isSelected: _selectedRole == 'student',
                      ),
                    ],
                  ),
                ),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _handleContinue,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String role,
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _selectRole(role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.pureWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.darkTurquoise,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.pureWhite.withOpacity(0.2)
                    : AppColors.lightCyan,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: isSelected ? AppColors.pureWhite : AppColors.darkAzure,
              ),
            ),
            const SizedBox(width: 16),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.pureWhite
                          : AppColors.darkAzure,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected
                          ? AppColors.pureWhite.withOpacity(0.9)
                          : AppColors.darkTurquoise,
                    ),
                  ),
                ],
              ),
            ),
            // Checkmark
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.pureWhite, size: 28),
          ],
        ),
      ),
    );
  }
}
