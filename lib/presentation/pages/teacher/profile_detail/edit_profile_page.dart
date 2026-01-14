import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/repositories/auth_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/profile/profile_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/profile_detail/edit_profile_bloc.dart';

/// Edit Profile Page
/// 
/// Halaman untuk edit profile dengan field name, username, dan email
class EditProfilePage extends StatefulWidget {
  final String userId;
  final String initialName;
  final String initialUsername;
  final String initialEmail;
  final ProfileBloc profileBloc;
  final AuthenticationRepositoryImpl authRepository;

  const EditProfilePage({
    super.key,
    required this.userId,
    required this.initialName,
    required this.initialUsername,
    required this.initialEmail,
    required this.profileBloc,
    required this.authRepository,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late EditProfileBloc _editProfileBloc;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _usernameController = TextEditingController(text: widget.initialUsername);
    _emailController = TextEditingController(text: widget.initialEmail);

    // Create BLoC instance directly
    _editProfileBloc = EditProfileBloc(authRepository: widget.authRepository);
    
    // Initialize dengan data awal
    _editProfileBloc.add(
      InitializeEditProfileEvent(
        userId: widget.userId,
        name: widget.initialName,
        username: widget.initialUsername,
        email: widget.initialEmail,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _editProfileBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.darkAzure,
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocProvider<EditProfileBloc>.value(
        value: _editProfileBloc,
        child: BlocListener<EditProfileBloc, EditProfileState>(
          listener: (context, state) {
            if (state is EditProfileSuccess) {
              // Jika sukses, emit event di ProfileBloc untuk update profile
              final profileName = _nameController.text;
              final profileUsername = _usernameController.text;
              final profileEmail = _emailController.text;

              widget.profileBloc.add(
                EditProfileEvent(
                  name: profileName,
                  username: profileUsername,
                  email: profileEmail,
                ),
              );

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profil berhasil diperbarui'),
                  backgroundColor: Colors.green,
                ),
              );

              // Navigate back
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) Navigator.of(context).pop();
              });
            } else if (state is EditProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<EditProfileBloc, EditProfileState>(
            builder: (context, state) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20 : 40,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        'Update Informasi Profil',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkAzure,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Change your profile details below',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Name Field
                      _buildEditField(
                        label: 'Full Name',
                        controller: _nameController,
                        hint: 'Enter your full name',
                        onChanged: (value) {
                          context.read<EditProfileBloc>().add(NameChangedEvent(value));
                        },
                        isValid: state is EditProfileFormState ? state.isNameValid : true,
                        errorMessage: 'Name must be at least 2 characters',
                      ),
                      const SizedBox(height: 20),

                      // Username Field
                      _buildEditField(
                        label: 'Username',
                        controller: _usernameController,
                        hint: 'Enter your username (letters, numbers, underscore)',
                        onChanged: (value) {
                          context.read<EditProfileBloc>().add(UsernameChangedEvent(value));
                        },
                        isValid: state is EditProfileFormState ? state.isUsernameValid : true,
                        errorMessage: 'Username must be at least 3 characters (letters, numbers, underscore)',
                      ),
                      const SizedBox(height: 20),

                      // Email Field
                      _buildEditField(
                        label: 'Email',
                        controller: _emailController,
                        hint: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          context.read<EditProfileBloc>().add(EmailChangedEvent(value));
                        },
                        isValid: state is EditProfileFormState ? state.isEmailValid : true,
                        errorMessage: 'Email is not valid',
                      ),
                      const SizedBox(height: 40),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Back',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkAzure,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: state is EditProfileFormState && state.isFormValid
                                  ? () {
                                      context.read<EditProfileBloc>().add(
                                        SaveProfileEvent(
                                          userId: widget.userId,
                                          name: _nameController.text.trim(),
                                          username: _usernameController.text.trim(),
                                          email: _emailController.text.trim(),
                                        ),
                                      );
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkAzure,
                                disabledBackgroundColor: Colors.grey[300],
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: state is EditProfileSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Save Changes',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEditField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required Function(String) onChanged,
    required bool isValid,
    required String errorMessage,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!isValid && controller.text.isNotEmpty)
              Chip(
                label: const Text('Invalid', style: TextStyle(fontSize: 12)),
                backgroundColor: Colors.red[100],
                labelStyle: const TextStyle(color: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: !isValid && controller.text.isNotEmpty ? Colors.red : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: !isValid && controller.text.isNotEmpty ? Colors.red : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: !isValid && controller.text.isNotEmpty ? Colors.red : AppColors.darkAzure,
                width: 2,
              ),
            ),
            errorText: !isValid && controller.text.isNotEmpty ? errorMessage : null,
          ),
        ),
      ],
    );
  }
}
