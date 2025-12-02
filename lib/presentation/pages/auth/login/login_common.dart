import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_event.dart';
import '../../../blocs/auth/auth_state.dart';

/// Shared login actions used by mobile/desktop implementations
class LoginActions {
  static void handleLogin(
    BuildContext context, {
    required String email,
    required String password,
  }) {
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    context.read<AuthBloc>().add(
      LoginRequested(email: email, password: password),
    );
  }

  static void handleGoogleLogin(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please register first if you don\'t have an account'),
        duration: Duration(seconds: 2),
      ),
    );
    // Google Sign-In for login will fetch existing user from database
    // Role selection is only needed during registration
    context.read<AuthBloc>().add(
      GoogleSignInRequested(
        role: 'student',
      ), // Default, will be ignored if user exists
    );
  }
}

/// Wraps UI and listens for auth state changes to show snackbars and navigate.
class LoginListener extends StatelessWidget {
  final Widget child;

  const LoginListener({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Navigate based on user role
          if (state.user.role == 'student') {
            context.go('/student/home');
          } else {
            context.go('/teacher/home');
          }
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        // Show loading overlay when logging in
        if (state is AuthLoading) {
          return Stack(
            children: [
              child,
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
          );
        }
        return child;
      },
    );
  }
}
