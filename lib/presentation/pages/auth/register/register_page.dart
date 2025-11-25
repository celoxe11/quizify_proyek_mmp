import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/presentation/pages/auth/register/register_desktop.dart';
import 'package:quizify_proyek_mmp/presentation/pages/auth/register/register_mobile.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  // Define the common breakpoint for the application
  static const double _kMobileBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < _kMobileBreakpoint;

    // Use the mobile design if the width is less than the breakpoint
    if (isMobile) {
      return const RegisterMobile();
    }
    // Otherwise, use the desktop design
    else {
      return const RegisterDesktop();
    }
  }
}
