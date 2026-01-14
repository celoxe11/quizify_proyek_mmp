import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/data/repositories/student_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/home/home_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/home/home_event.dart';
import 'home_mobile.dart';
import 'home_desktop.dart';

/// Responsive wrapper for Student Home page
///
/// Routes to mobile or desktop layout based on screen width
class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  late StudentHomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    // Create BLoC once and reuse it
    _homeBloc = StudentHomeBloc(
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
            return const StudentHomeMobile();
          } else {
            return const StudentHomeDesktop();
          }
        },
      ),
    );
  }
}
