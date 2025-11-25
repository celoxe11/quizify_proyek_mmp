import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../../../presentation/blocs/auth/auth_event.dart';

class LoginMobile extends StatefulWidget {
  const LoginMobile({super.key});

  @override
  State<LoginMobile> createState() => _LoginMobileState();
}

class _LoginMobileState extends State<LoginMobile> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    String email = _usernameController.text.trim();
    String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    context.read<AuthBloc>().add(
      LoginRequested(
        email: email,
        password: password,
      ),
    );
  }

  void _handleGoogleLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please register first if you don\'t have an account'),
        duration: Duration(seconds: 2),
      ),
    );
    // Google Sign-In for login will fetch existing user from database
    // Role selection is only needed during registration
    context.read<AuthBloc>().add(
      GoogleSignInRequested(role: 'student'), // Default, will be ignored if user exists
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.darkAzure,
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  const Text(
                    'Quizify',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pureWhite,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 60),
        
                  // Login Container
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.dirtyCyan,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Login Heading
                        Center(
                          child: const Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkAzure
                            ),
                            // We can remove the redundant 'textAlign: TextAlign.center' now
                          ),
                        ),
                        const SizedBox(height: 24),
        
                        // Email Field
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkAzure,
                          )
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _usernameController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            filled: true,
                            fillColor: AppColors.pureWhite,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
        
                        // Password Field
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkAzure,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            filled: true,
                            fillColor: AppColors.pureWhite,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.darkAzure,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
        
                        // Divider
                        Container(height: 1, color: AppColors.darkAzure),
                        const SizedBox(height: 24),
        
                        // Login Button with loading state
                        BlocConsumer<AuthBloc, AuthState>(
                          listener: (context, state) {
                            if (state is AuthAuthenticated) {
                              // Navigate based on user role
                              if (state.user.role == 'student') {
                                context.go('/student/home');
                              } else {
                                context.go('/teacher/home');
                              }
                            } else if (state is AuthFailure) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.message)),
                              );
                            }
                          },
                          builder: (context, state) {
                            if (state is AuthLoading) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.darkAzure,
                                ),
                              );
                            }
                            return Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.darkAzure,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.pureWhite,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                
                                // Google Login Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _handleGoogleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.pureWhite,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // Google Icon
                                        Image.asset(
                                          "assets/icons/google_icon.png",
                                          height: 20,
                                          width: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        // Button Text
                                        const Text(
                                          'Login with Google',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.darkAzure,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
        
                  // Register Link
                  GestureDetector(
                    onTap: () => context.push('/register'),
                    child: const Text(
                      "Don't have an account? Register",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.pureWhite,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
