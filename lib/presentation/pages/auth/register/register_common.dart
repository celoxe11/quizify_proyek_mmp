import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_event.dart';
import '../../../blocs/auth/auth_state.dart';

/// Shared registration actions and listener used by mobile/desktop implementations
class RegisterActions {
  static Future<void> handleRegisterSubmit(
    BuildContext context, {
    required String name,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
  }) async {
    // Basic validation (match mobile behaviour)
    if (name.isEmpty ||
        email.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    // Dispatch register event
    context.read<AuthBloc>().add(
      RegisterRequested(
        name: name,
        username: username,
        email: email,
        password: password,
        role: role,
      ),
    );
  }

  static void handleGoogleSignIn(BuildContext context, {required String role}) {
    context.read<AuthBloc>().add(GoogleSignInRequested(role: role));
  }
}

/// Wraps UI and listens for auth state changes to show snackbars and navigate.
class RegisterListener extends StatelessWidget {
  final Widget child;

  const RegisterListener({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );
          final role = state.user.role;
          if (role == 'student') {
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
        // Show loading overlay when registering
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
