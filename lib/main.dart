import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:quizify_proyek_mmp/core/theme/app_theme.dart';
import 'package:quizify_proyek_mmp/pages/auth/landing_page.dart';
import 'package:quizify_proyek_mmp/pages/auth/login/login_page.dart';
import 'package:quizify_proyek_mmp/pages/auth/register/register_page.dart';
import 'package:quizify_proyek_mmp/pages/student/home/home_page.dart';
import 'package:quizify_proyek_mmp/pages/teacher/home/home_page.dart';
import 'package:quizify_proyek_mmp/widgets/shells.dart';

// --- Global Navigator Keys (REQUIRED for ShellRoute) ---
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _studentShellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'studentShell',
);
final _teacherShellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'teacherShell',
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final initialRoute = kIsWeb ? '/' : '/login';

    final router = GoRouter(
      initialLocation: initialRoute,
      navigatorKey: _rootNavigatorKey,
      routes: [
        GoRoute(path: '/', builder: (context, state) => const LandingPage()),
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),

        // ------------------------------------------------
        // Student Shell Route
        // ------------------------------------------------
        // Student shell with bottom nav (mobile) or navbar+drawer (desktop)
        ShellRoute(
          navigatorKey: _studentShellNavigatorKey,
          builder: (context, state, child) => StudentShell(child: child),
          routes: [
            GoRoute(
              path: '/student',
              redirect: (context, state) => '/student/home',
            ),
            GoRoute(
              path: '/student/home',
              builder: (context, state) => const StudentHomePage(),
            ),
          ],
        ),

        // ------------------------------------------------
        // Teacher Shell Route
        // ------------------------------------------------
        ShellRoute(
          navigatorKey: _teacherShellNavigatorKey,
          builder: (context, state, child) => TeacherShell(child: child),
          routes: [
            GoRoute(
              path: '/teacher',
              redirect: (context, state) => '/teacher/home',
            ),
            GoRoute(
              path: '/teacher/home',
              builder: (context, state) => const TeacherHomePage(),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Quizify',
      theme: AppTheme.mainTheme,
      routerConfig: router,
    );
  }
}
