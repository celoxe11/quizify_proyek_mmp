import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/core/config/firebase_config.dart';
import 'package:quizify_proyek_mmp/core/theme/app_theme.dart';
import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';

// Import Bloc and Repository
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_state.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/quiz_detail/quiz_detail_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/quiz_detail/quiz_detail_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/edit_quiz/edit_quiz_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/quizzes/quizzes_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/quizzes/quizzes_event.dart';
import 'package:quizify_proyek_mmp/presentation/pages/admin/create_quiz/create_quiz_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/admin/quizzes/quiz_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/auth/landing_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/auth/login/login_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/auth/register/register_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/auth/role_selection/role_selection_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/home/home_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/join_quiz_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/teacher/create_quiz/create_quiz_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/teacher/create_quiz/enter_quiz_name_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/teacher/home/home_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/teacher/quiz_detail/answer_detail_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/teacher/quiz_detail/edit_quiz_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/teacher/quiz_detail/quiz_detail_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/teacher/quizzes/quiz_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/admin/home/home.dart';
import 'package:quizify_proyek_mmp/presentation/widgets/teacher_shell.dart';
import 'package:quizify_proyek_mmp/presentation/widgets/student_shell.dart';
import 'package:quizify_proyek_mmp/presentation/widgets/admin_shell.dart';
import 'package:quizify_proyek_mmp/core/services/admin/admin_api_service.dart';
import 'package:quizify_proyek_mmp/data/repositories/admin_repository.dart';

// import repository
import 'package:quizify_proyek_mmp/data/repositories/auth_repository.dart';
import 'package:quizify_proyek_mmp/core/services/auth/auth_service.dart';
import 'package:quizify_proyek_mmp/core/services/auth/auth_api_service.dart';

import 'package:dio/dio.dart'; 


// --- Global Navigator Keys (REQUIRED for ShellRoute) ---
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _studentShellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'studentShell',
);
final _teacherShellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'teacherShell',
);
final _adminShellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'adminShell',
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
    return BlocProvider(
      create: (context) => AuthBloc(
        authRepository: AuthenticationRepositoryImpl(
          firebaseAuthService: AuthService(),
          apiService: AuthApiService(),
        ),
      )..add(const AppStarted()), // Trigger auth check on app start
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    final initialRoute = kIsWeb ? '/' : '/login';

    final router = GoRouter(
      initialLocation: initialRoute,
      navigatorKey: _rootNavigatorKey,
      // Redirect based on auth state
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        final isOnAuthPage =
            state.matchedLocation == '/' ||
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register' ||
            state.matchedLocation == '/role-selection';

        // If user is authenticated
        if (authState is AuthAuthenticated) {
          // If on auth page, redirect to appropriate home based on role
          if (isOnAuthPage) {
            if (authState.user.role == 'teacher') {
              return '/teacher/home';
            } else if (authState.user.role == 'student') {
              return '/student/home';
            } else if (authState.user.role == 'admin') {
              return '/admin/home';
            }
          }
          return null; // Stay on current page
        }

        // If user is not authenticated and not on auth page, go to login
        if (authState is AuthUnauthenticated && !isOnAuthPage) {
          return '/login';
        }

        return null; // No redirect needed
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const LandingPage()),
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/role-selection',
          builder: (context, state) =>
              RoleSelectionPage(userData: state.extra as Map<String, dynamic>?),
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
            GoRoute(
              path: '/student/join-quiz',
              builder: (context, state) => const JoinQuizPage(),
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
            // Quizzes Page with BLoC Provider
            GoRoute(
              path: '/teacher/quizzes',
              builder: (context, state) {
                return BlocProvider(
                  create: (context) => QuizzesBloc()..add(LoadQuizzesEvent()),
                  child: const TeacherQuizPage(),
                );
              },
            ),
            // Quiz Detail Page with BLoC Provider
            GoRoute(
              path: '/teacher/quiz-detail',
              builder: (context, state) {
                final quiz = state.extra as QuizModel;
                return BlocProvider(
                  create: (context) =>
                      QuizDetailBloc()
                        ..add(LoadQuizDetailEvent(quizId: quiz.id)),
                  child: TeacherQuizDetailPage(quiz: quiz),
                );
              },
            ),
            GoRoute(
              path: "/teacher/quiz-detail/edit",
              builder: (context, state) {
                final data = state.extra as Map<String, dynamic>;
                final quiz = data['quiz'] as QuizModel;
                final questions = data['questions'] as List<QuestionModel>;
                return BlocProvider(
                  create: (context) => EditQuizBloc()
                    ..add(
                      InitializeEditQuizEvent(quiz: quiz, questions: questions),
                    ),
                  child: TeacherEditQuizPage(quiz: quiz, questions: questions),
                );
              },
            ),
            GoRoute(
              path: "/teacher/quiz-detail/answers",
              builder: (context, state) =>
                  TeacherAnswerDetailPage(quiz: state.extra as QuizModel),
            ),
            GoRoute(
              path: "/teacher/new-quiz",
              builder: (context, state) => const TeacherEnterQuizNamePage(),
            ),
            GoRoute(
              path: "/teacher/create-quiz",
              builder: (context, state) => const TeacherCreateQuizPage(),
            ),
            GoRoute(
              path: '/teacher/profile',
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Teacher Profile Page')),
              ),
            ),
          ],
        ),

        // ------------------------------------------------
        // Admin Shell Route
        // ------------------------------------------------
        ShellRoute(
          navigatorKey: _adminShellNavigatorKey,
          builder: (context, state, child) => AdminShell(child: child),
          routes: [
            GoRoute(
              path: '/admin',
              redirect: (context, state) => '/admin/dashboard',
            ),
            GoRoute(
              path: '/admin/dashboard',
              builder: (context, state) => const AdminHomePage(),
            ),
            GoRoute(
              path: '/admin/users',
              builder: (context, state) {
                // Bungkus Page dengan BlocProvider agar Page bisa akses Bloc
                return BlocProvider(
                  create: (context) => AdminUsersBloc(
                    // Ambil repository yang sudah di-inject di atas
                    adminRepository: context.read<AdminRepositoryImpl>(),
                  ),
                  child: const AdminUsersPage(),
                );
              },
            ),

            GoRoute(
              path: '/admin/quizzes',
              builder: (context, state) => const AdminQuizPage(),
            ),
            GoRoute(
              path: '/admin/quizz/create',
              builder: (context, state) => const AdminCreateQuizPage(),
            ),
            GoRoute(
              path: '/admin/analytics',
              builder: (context, state) =>
                  // TODO: Replace with actual Analytics Page
                  const Scaffold(body: Center(child: Text('Analytics'))),
            ),
            GoRoute(
              path: '/admin/settings',
              builder: (context, state) =>
                  // TODO: Replace with actual Settings Page
                  const Scaffold(body: Center(child: Text('Settings'))),
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
        RepositoryProvider(
          create: (context)  {
             // Sebaiknya gunakan instance Dio yang sama dengan Auth (Singleton)
             // Tapi untuk sekarang new Dio() dulu tidak apa-apa asalkan diatur BaseURL-nya
             final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000')); 
             
             return AdminRepositoryImpl(
               apiService: AdminApiService(dio),
             );
          },
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
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              // Navigate to login page when logged out
              router.go('/login');
            } else if (state is AuthAuthenticated) {
              // Auto-navigate to appropriate home after login
              final currentLocation = router.routeInformationProvider.value.uri
                  .toString();
              if (currentLocation == '/' ||
                  currentLocation == '/login' ||
                  currentLocation == '/register') {
                if (state.user.role == 'teacher') {
                  router.go('/teacher/home');
                } else if (state.user.role == 'student') {
                  router.go('/student/home');
                } else if (state.user.role == 'admin') {
                  router.go('/admin/home');
                }
              }
              }
          },
          child: MaterialApp.router(
            title: 'Quizify',
            theme: AppTheme.mainTheme,
            routerConfig: router,
          ),
        ),
      ),
    );
  }
}
