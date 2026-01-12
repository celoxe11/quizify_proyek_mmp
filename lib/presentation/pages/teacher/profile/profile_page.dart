import 'package:flutter/material.dart';
import 'profile_mobile.dart';
import 'profile_desktop.dart';

class TeacherProfilePage extends StatelessWidget {
  const TeacherProfilePage({super.key});

  static const double _kMobileBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < _kMobileBreakpoint;

    if (isMobile) {
      return const TeacherProfileMobile();
    } else {
      return const TeacherProfileDesktop();
    }
  }
}
