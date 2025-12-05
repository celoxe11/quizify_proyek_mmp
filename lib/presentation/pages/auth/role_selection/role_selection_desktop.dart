import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'role_selection_common.dart';

class RoleSelectionDesktop extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const RoleSelectionDesktop({Key? key, this.userData}) : super(key: key);

  @override
  State<RoleSelectionDesktop> createState() => _RoleSelectionDesktopState();
}

class _RoleSelectionDesktopState extends State<RoleSelectionDesktop> {
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
      body: RoleSelectionListener(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Back button (top left)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.darkAzure),
                    onPressed: () => context.pop(),
                  ),
                ),

                // Title
                Text(
                  'Choose Your Role',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkAzure,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Are you a Teacher or a Student?',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.darkTurquoise,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Role Cards (side by side)
                Row(
                  children: [
                    Expanded(
                      child: _buildRoleCard(
                        role: 'teacher',
                        title: 'Teacher',
                        description:
                            'Create and manage quizzes for your students',
                        icon: Icons.school,
                        isSelected: _selectedRole == 'teacher',
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildRoleCard(
                        role: 'student',
                        title: 'Student',
                        description: 'Join and participate in quizzes',
                        icon: Icons.person,
                        isSelected: _selectedRole == 'student',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Continue Button
                SizedBox(
                  width: 400,
                  child: FilledButton(
                    onPressed: _handleContinue,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 18,
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.darkTurquoise,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.pureWhite.withOpacity(0.2)
                    : AppColors.lightCyan,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 64,
                color: isSelected ? AppColors.pureWhite : AppColors.darkAzure,
              ),
            ),
            const SizedBox(height: 24),
            // Text content
            Text(
              title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.pureWhite : AppColors.darkAzure,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: isSelected
                    ? AppColors.pureWhite.withOpacity(0.9)
                    : AppColors.darkTurquoise,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Checkmark
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.pureWhite, size: 32),
          ],
        ),
      ),
    );
  }
}
