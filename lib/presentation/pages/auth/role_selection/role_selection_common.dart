import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_event.dart';
import '../../../blocs/auth/auth_state.dart';

/// Shared role selection actions used by mobile/desktop implementations
class RoleSelectionActions {
  /// Handle role selection for email/password registration
  static void handleRegistrationWithRole(
    BuildContext context, {
    required Map<String, dynamic> userData,
    required String role,
  }) {
    context.read<AuthBloc>().add(
      RegisterRequested(
        name: userData['name'],
        email: userData['email'],
        password: userData['password'],
        username: userData['username'],
        role: role,
      ),
    );
  }

  /// Handle role selection for Google Sign-In (completes registration with role)
  static void handleGoogleSignInWithRole(
    BuildContext context, {
    required Map<String, dynamic> userData,
    required String role,
  }) {
    context.read<AuthBloc>().add(
      CompleteGoogleSignInRequested(
        firebaseUid: userData['firebaseUid'],
        name: userData['name'],
        email: userData['email'],
        role: role,
      ),
    );
  }
}

/// Wraps UI and listens for auth state changes to show loading, navigate, and handle errors
class RoleSelectionListener extends StatelessWidget {
  final Widget child;

  const RoleSelectionListener({Key? key, required this.child})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Navigate based on user role
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Welcome!')));

          if (state.user.role == 'student') {
            context.go('/student/home');
          } else {
            context.go('/teacher/home');
          }
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        // Show loading overlay when processing
        if (state is AuthLoading) {
          return Stack(
            children: [
              child,
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
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
