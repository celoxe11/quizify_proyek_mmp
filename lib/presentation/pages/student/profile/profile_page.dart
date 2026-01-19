import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/data/repositories/auth_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_bloc.dart'; // Import AuthBloc
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_state.dart'; // Import AuthState
import 'package:quizify_proyek_mmp/presentation/blocs/student/profile/profile_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/profile/profile_desktop.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/profile/profile_mobile.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        authRepository: context.read<AuthenticationRepositoryImpl>(),
      )..add(const LoadProfileEvent()), // Load awal
      
      // [FIX] Tambahkan BlocListener untuk AuthBloc
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          // Jika AuthBloc mendeteksi perubahan user (misal habis equip avatar),
          // Maka suruh ProfileBloc untuk reload data juga.
          if (authState is AuthAuthenticated) {
            // Ketika AuthBloc terupdate (misal setelah equip avatar),
            // Suruh ProfileBloc ambil data terbaru juga.
            context.read<ProfileBloc>().add(const RefreshProfileEvent());
          }
        },
        child: Builder(
          builder: (context) {
            final size = MediaQuery.of(context).size;
            final isMobile = size.width < 600;

            if (isMobile) {
              return const StudentProfileMobile();
            } else {
              return const StudentProfileDesktop();
            }
          },
        ),
      ),
    );
  }
}