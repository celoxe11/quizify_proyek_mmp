import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/core/config/firebase_config.dart';
import 'package:quizify_proyek_mmp/core/theme/app_theme.dart';

// Import Bloc and Repository
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/pages/auth/landing_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/auth/login/login_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/auth/register/register_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/home/home_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/teacher/home/home_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/teacher/quizzes/quiz_page.dart';
import 'package:quizify_proyek_mmp/presentation/widgets/shells.dart';

// import repository
import 'package:quizify_proyek_mmp/data/repositories/auth_repository.dart';
import 'package:quizify_proyek_mmp/core/services/auth_service.dart';
import 'package:quizify_proyek_mmp/core/services/auth_api_service.dart';

// --- Global Navigator Keys (REQUIRED for ShellRoute) ---
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _studentShellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'studentShell',
);
final _teacherShellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'teacherShell',
);

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await FirebaseConfig.initialize();

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
            GoRoute(
              path: '/teacher/quizzes',
              builder: (context, state) => const TeacherQuizPage(),
            ),
            GoRoute(
              path: '/teacher/profile',
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Teacher Profile Page')),
              ),
            ),
          ],
        ),
      ],
    );

    return MultiRepositoryProvider(
      providers: [
        // 1. Initialize the Repository with its dependencies (Services)
        RepositoryProvider(
          create: (context) => AuthenticationRepositoryImpl(
            firebaseAuthService: AuthService(),
            apiService: AuthApiService(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // 2. Inject the Repository into the Bloc
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthenticationRepositoryImpl>(),
            ),
          ),
        ],
        child: MaterialApp.router(
          title: 'Quizify',
          theme: AppTheme.mainTheme,
          routerConfig: router,
        ),
      ),
    );
  }
}
