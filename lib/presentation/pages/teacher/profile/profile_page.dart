import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/data/repositories/auth_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_state.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/profile/profile_bloc.dart';
import 'profile_mobile.dart';
import 'profile_desktop.dart';

class TeacherProfilePage extends StatefulWidget {
  const TeacherProfilePage({super.key});

  @override
  State<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        authRepository: context.read<AuthenticationRepositoryImpl>(),
      )..add(const LoadProfileEvent()), // Load awal
      // [FIX] Tambahkan BlocListener untuk AuthBloc
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          if (authState is AuthAuthenticated) {
            context.read<ProfileBloc>().add(const RefreshProfileEvent());
          }
        },
        child: Builder(
          builder: (context) {
            final size = MediaQuery.of(context).size;
            final isMobile = size.width < 600;

            if (isMobile) {
              return const TeacherProfileMobile();
            } else {
              return const TeacherProfileDesktop();
            }
          },
        ),
      ),
    );
  }
}
