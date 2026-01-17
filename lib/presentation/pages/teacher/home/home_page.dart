import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/data/repositories/student_repository.dart';
import 'package:quizify_proyek_mmp/domain/repositories/teacher_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/home/home_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/home/home_bloc.dart';
import 'home_mobile.dart';
import 'home_desktop.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  late TeacherHomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    // Create BLoC once and reuse it
    _homeBloc = TeacherHomeBloc(
      context.read<TeacherRepository>(),
      context.read<StudentRepository>(),
    );
    // Load quizzes only once
    _homeBloc.add(const LoadPublicQuizzesEvent());
  }

  @override
  void dispose() {
    _homeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeBloc,
      child: Builder(
        builder: (context) {
          final size = MediaQuery.of(context).size;
          final isMobile = size.width < 600;

          if (isMobile) {
            return const TeacherHomeMobile();
          } else {
            return const TeacherHomeDesktop();
          }
        },
      ),
    );
  }
}