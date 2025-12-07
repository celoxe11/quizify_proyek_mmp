import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/presentation/pages/admin/quizzes/quiz_mobile.dart';
import 'quiz_desktop.dart';

class AdminQuizPage extends StatelessWidget {
  const AdminQuizPage({super.key});

  static const double _kMobileBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < _kMobileBreakpoint;

    if (isMobile) {
      return const AdminQuizMobilePage();
    } else {
      return const AdminQuizDesktopPage();
    }
  }
}
