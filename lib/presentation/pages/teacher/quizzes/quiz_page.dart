import 'package:flutter/material.dart';
import 'quiz_mobile.dart';
import 'quiz_desktop.dart';

class TeacherQuizPage extends StatelessWidget {
  const TeacherQuizPage({super.key});

  static const double _kMobileBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < _kMobileBreakpoint;

    if (isMobile) {
      return const TeacherQuizMobile();
    } else {
      return const TeacherQuizDesktop();
    }
  }
}
