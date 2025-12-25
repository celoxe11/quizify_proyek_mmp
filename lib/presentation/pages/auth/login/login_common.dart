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
    // For login, check if user exists first
    // If user doesn't exist, they'll need to register
    context.read<AuthBloc>().add(GoogleSignInRequested());
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
          print(state.user.role);

          // Navigate based on user role
          if (state.user.role == 'student') {
            context.go('/student/home');
          } else if (state.user.role == 'teacher') {
            context.go('/teacher/home');
          } else if (state.user.role == 'admin') {
            context.go('/admin/home');
          } else {
            // Default fallback
            context.go('/student/home');
          }
        } else if (state is AuthRequiresRoleSelection) {
          // New Google user from login - navigate to role selection
          context.go(
            '/role-selection',
            extra: {
              'isGoogleSignIn': true,
              'firebaseUid': state.firebaseUid,
              'name': state.name,
              'email': state.email,
            },
          );
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
