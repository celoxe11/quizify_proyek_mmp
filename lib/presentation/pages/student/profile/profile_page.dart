import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/data/repositories/auth_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/profile/profile_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/profile/profile_desktop.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/profile/profile_mobile.dart';

class StudentProfilePage extends StatelessWidget {
  const StudentProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        authRepository: context.read<AuthenticationRepositoryImpl>(),
      )..add(const LoadProfileEvent()),
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
    );
  }
}
