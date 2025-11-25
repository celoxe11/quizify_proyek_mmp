import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/pages/auth/login/login_desktop.dart';
import 'package:quizify_proyek_mmp/pages/auth/login/login_mobile.dart';

// a responsive login page that switches between mobile and desktop layouts
class LoginPage extends StatelessWidget{
  const LoginPage({super.key});
  
  // Define the common breakpoint for the application
  static const double _kMobileBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < _kMobileBreakpoint;

    // Use the mobile design if the width is less than the breakpoint
    if (isMobile) {
      return const LoginMobile();
    } 
    // Otherwise, use the desktop design
    else {
      return const LoginDesktop();
    }
  }
}
