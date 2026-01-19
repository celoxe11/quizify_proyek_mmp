import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/core/api/api_client.dart';
import 'package:quizify_proyek_mmp/core/api/dio_client.dart';
import 'package:quizify_proyek_mmp/core/config/firebase_config.dart';
import 'package:quizify_proyek_mmp/core/services/admin/admin_service.dart';
import 'package:quizify_proyek_mmp/core/services/landing/landing_service.dart';
import 'package:quizify_proyek_mmp/core/theme/app_theme.dart';
import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';
// Import App Database
import 'package:quizify_proyek_mmp/core/config/app_database.dart';
import 'package:quizify_proyek_mmp/data/repositories/landing_repository.dart';
import 'package:quizify_proyek_mmp/data/repositories/student_repository.dart';
import 'package:quizify_proyek_mmp/data/repositories/payment_repository.dart';
import 'package:quizify_proyek_mmp/domain/repositories/landing_repository.dart';
import 'package:quizify_proyek_mmp/domain/repositories/shop_repository.dart';
import 'package:quizify_proyek_mmp/domain/repositories/teacher_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/avatar/admin_avatar_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/avatar/admin_avatar_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/edit_quiz/admin_edit_quiz_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/quizzes/admin_quizzes_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/quizzes/admin_quizzes_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/transaction/admin_transaction_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/landing/landing_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/landing/landing_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/generate_question/generate_question_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/student_answers/student_answers_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/student_answers/admin_student_answers_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/payment/payment_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/pages/admin/avatar/admin_avatar_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/common/shop/shop_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/admin/logs/admin_logs_page.dart';

// Import Bloc and Repository
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_state.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/create_quiz/create_quiz_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/quiz_detail/quiz_detail_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/quiz_detail/quiz_detail_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/edit_quiz/edit_quiz_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/quizzes/quizzes_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/quizzes/quizzes_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/quiz_detail/admin_quiz_detail_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/create_quiz/admin_create_quiz_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/generate_question/admin_generate_question_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/pages/admin/analytic/analytic_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/admin/quiz_detail/edit_quiz_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/admin/quiz_detail/quiz_detail_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/admin/create_quiz/create_quiz_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/admin/create_quiz/enter_quiz_name_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/admin/quiz_detail/students_answers_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/admin/quizzes/quiz_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/admin/subscriptions/admin_subscriptions_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/admin/transaction/admin_transaction_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/landing_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/auth/login/login_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/auth/register/register_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/auth/role_selection/role_selection_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/history/history_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/history_detail/history_detail_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/home/home_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/profile/profile_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/join_quiz_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/quiz_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz_detail/quiz_detail_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/teacher/create_quiz/create_quiz_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/teacher/create_quiz/enter_quiz_name_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/teacher/home/home_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/teacher/quiz_detail/edit_quiz_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/teacher/quiz_detail/quiz_detail_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/teacher/quiz_detail/students_answers_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/teacher/quizzes/quiz_page.dart';
import 'package:quizify_proyek_mmp/presentation/pages/teacher/other_quiz_detail/other_quiz_detail.dart';
import 'package:quizify_proyek_mmp/presentation/pages/teacher/profile/profile_page.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/profile/profile_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/pages/admin/home/home.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/users/admin_users_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/pages/admin/users/admin_users_page.dart';

import 'package:quizify_proyek_mmp/presentation/widgets/teacher_shell.dart';
import 'package:quizify_proyek_mmp/presentation/widgets/student_shell.dart';
import 'package:quizify_proyek_mmp/presentation/widgets/admin_shell.dart';
import 'package:quizify_proyek_mmp/core/services/admin/admin_api_service.dart';
import 'package:quizify_proyek_mmp/data/repositories/admin_repository.dart';

// import repository
import 'package:quizify_proyek_mmp/data/repositories/auth_repository.dart';
import 'package:quizify_proyek_mmp/data/repositories/teacher_repository.dart';
import 'package:quizify_proyek_mmp/core/services/auth/auth_service.dart';
import 'package:quizify_proyek_mmp/core/services/auth/auth_api_service.dart';
import 'package:quizify_proyek_mmp/core/config/platform_config.dart';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:intl/date_symbol_data_local.dart';

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

  // Initialize local database (only on mobile platforms, not web)
  if (!kIsWeb) {
    final appDatabase = AppDatabase.instance;
  }
  await initializeDateFormatting('id', null);
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
        GoRoute(
          path: '/',
          builder: (context, state) => BlocProvider(
            create: (context) => LandingBloc(
              landingRepository: context.read<LandingRepository>(),
            )..add(FetchLandingQuizzesEvent()),
            child: const LandingPage(),
          ),
        ),
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
              path: '/student/quiz-detail',
              builder: (context, state) {
                final quiz = state.extra as QuizModel;
                return QuizDetailPage(quiz: quiz);
              },
            ),
            GoRoute(
              path: '/student/join-quiz',
              builder: (context, state) => const JoinQuizPage(),
            ),
            GoRoute(
              path: '/student/history',
              builder: (context, state) => const StudentHistoryPage(),
            ),
            GoRoute(
              path: '/student/history/:sessionId',
              builder: (context, state) {
                final sessionId = state.pathParameters['sessionId']!;
                return HistoryDetailPage(sessionId: sessionId);
              },
            ),
            GoRoute(
              path: '/student/quiz/:sessionId/:quizId',
              builder: (context, state) {
                final sessionId = state.pathParameters['sessionId']!;
                final quizId = state.pathParameters['quizId']!;
                return QuizPage(sessionId: sessionId, quizId: quizId);
              },
            ),
            GoRoute(
              path: '/student/profile',
              builder: (context, state) {
                return const StudentProfilePage();
              },
            ),
            GoRoute(
              path: '/student/shop',
              builder: (context, state) => const ShopPage(isTeacher: false),
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
            GoRoute(
              path: '/teacher/shop',
              builder: (context, state) => const ShopPage(isTeacher: true),
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
              path: '/teacher/other-quiz-detail',
              builder: (context, state) {
                final quiz = state.extra as QuizModel;
                return BlocProvider(
                  create: (context) =>
                      QuizDetailBloc()
                        ..add(LoadQuizDetailEvent(quizId: quiz.id)),
                  child: OtherTeacherQuizDetailPage(quiz: quiz),
                );
              },
            ),
            GoRoute(
              path: "/teacher/quiz-detail/edit",
              builder: (context, state) {
                final data = state.extra as Map<String, dynamic>;
                final quiz = data['quiz'] as QuizModel;
                final questions = data['questions'] as List<QuestionModel>;
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) =>
                          EditQuizBloc(
                            teacherRepository: context
                                .read<TeacherRepository>(),
                          )..add(
                            InitializeEditQuizEvent(
                              quiz: quiz,
                              questions: questions,
                            ),
                          ),
                    ),
                    BlocProvider(
                      create: (context) => GenerateQuestionBloc(
                        teacherRepository: context.read<TeacherRepository>(),
                      ),
                    ),
                  ],
                  child: TeacherEditQuizPage(quiz: quiz, questions: questions),
                );
              },
            ),
            GoRoute(
              path: "/teacher/quiz-detail/answers",
              builder: (context, state) {
                final data = state.extra as Map<String, dynamic>;
                final studentId = data['student_id'] as String;
                final studentName = data['student_name'] as String;
                final quizId = data['quiz_id'] as String;
                final quizTitle = data['quiz_title'] as String;

                return BlocProvider(
                  create: (context) => StudentAnswersBloc(
                    teacherRepository: context.read<TeacherRepository>(),
                  ),
                  child: TeacherStudentAnswersPage(
                    studentId: studentId,
                    studentName: studentName,
                    quizId: quizId,
                    quizTitle: quizTitle,
                  ),
                );
              },
            ),
            GoRoute(
              path: "/teacher/new-quiz",
              builder: (context, state) => const TeacherEnterQuizNamePage(),
            ),
            GoRoute(
              path: "/teacher/create-quiz",
              builder: (context, state) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => CreateQuizBloc(
                      teacherRepository: context.read<TeacherRepository>(),
                      authRepository: context
                          .read<AuthenticationRepositoryImpl>(),
                    ),
                  ),
                  BlocProvider(
                    create: (context) => GenerateQuestionBloc(
                      teacherRepository: context.read<TeacherRepository>(),
                    ),
                  ),
                ],
                child: TeacherCreateQuizPage(),
              ),
            ),
            GoRoute(
              path: '/teacher/profile',
              redirect: (context, state) {
                // Check if user is authenticated
                final authRepo = context.read<AuthenticationRepositoryImpl>();
                if (authRepo.currentUser.id.isEmpty) {
                  return '/login';
                }
                return null; // Allow access
              },
              builder: (context, state) {
                return BlocProvider(
                  create: (context) => ProfileBloc(
                    authRepository: context
                        .read<AuthenticationRepositoryImpl>(),
                  ),
                  child: const TeacherProfilePage(),
                );
              },
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
              redirect: (context, state) => '/admin/home',
            ),
            GoRoute(
              path: '/admin/home',
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
              builder: (context, state) {
                return BlocProvider(
                  create: (context) => AdminQuizzesBloc(
                    adminRepository: context.read<AdminRepositoryImpl>(),
                  )..add(LoadAdminQuizzesEvent()),
                  child: const AdminQuizPage(),
                );
              },
            ),
            GoRoute(
              path: '/admin/new-quiz',
              builder: (context, state) => const AdminEnterQuizNamePage(),
            ),
            GoRoute(
              path: '/admin/create-quiz',
              builder: (context, state) {
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => AdminCreateQuizBloc(
                        adminRepository: context.read<AdminRepositoryImpl>(),
                        authRepository: context
                            .read<AuthenticationRepositoryImpl>(),
                      ),
                    ),
                    BlocProvider(
                      create: (context) => AdminGenerateQuestionBloc(
                        adminRepository: context.read<AdminRepositoryImpl>(),
                      ),
                    ),
                  ],
                  child: const AdminCreateQuizPage(),
                );
              },
            ),
            GoRoute(
              path: "/admin/quiz-detail/edit",
              builder: (context, state) {
                final data = state.extra as Map<String, dynamic>;
                final quiz = data['quiz'] as QuizModel;
                final questions = data['questions'] as List<QuestionModel>;
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) =>
                          AdminEditQuizBloc(
                            adminRepository: context
                                .read<AdminRepositoryImpl>(),
                          )..add(
                            AdminInitializeEditQuizEvent(
                              quiz: quiz,
                              questions: questions,
                            ),
                          ),
                    ),
                    BlocProvider(
                      create: (context) => AdminGenerateQuestionBloc(
                        adminRepository: context.read<AdminRepositoryImpl>(),
                      ),
                    ),
                  ],
                  child: AdminEditQuizPage(quiz: quiz, questions: questions),
                );
              },
            ),
            GoRoute(
              path: "/admin/quiz-detail/answers",
              builder: (context, state) {
                final data = state.extra as Map<String, dynamic>;
                final studentId = data['student_id'] as String;
                final studentName = data['student_name'] as String;
                final quizId = data['quiz_id'] as String;
                final quizTitle = data['quiz_title'] as String;
                final sessionId =
                    data['session_id'] as String?; // Get session_id

                return BlocProvider(
                  create: (context) => AdminStudentAnswersBloc(
                    adminRepository: context.read<AdminRepositoryImpl>(),
                  ),
                  child: AdminStudentAnswersPage(
                    studentId: studentId,
                    studentName: studentName,
                    quizId: quizId,
                    quizTitle: quizTitle,
                    sessionId: sessionId,
                  ),
                );
              },
            ),
            GoRoute(
              path: '/admin/analytics',
              builder: (context, state) => const AnalyticPageWrapper(),
            ),
            GoRoute(
              path: '/admin/subscriptions',
              builder: (context, state) {
                // Kita reuse AdminUsersBloc karena dia yang handle subscription
                return BlocProvider(
                  create: (context) => AdminUsersBloc(
                    adminRepository: context.read<AdminRepositoryImpl>(),
                  ),
                  child: const AdminSettingsPage(),
                );
              },
            ),
            GoRoute(
              path: '/admin/logs',
              builder: (context, state) {
                final userId = state.uri.queryParameters['user_id'];

                // Masukkan ke Constructor Page
                return AdminLogsPage(userId: userId);
              },
            ),
            GoRoute(
              path: '/admin/transactions',
              builder: (context, state) {
                return BlocProvider(
                  create: (context) =>
                      AdminTransactionBloc(context.read<AdminRepositoryImpl>())
                        ..add(LoadAdminTransactions()), // Load data saat dibuka
                  child: const AdminTransactionPage(),
                );
              },
            ),

            // 2. ROUTE SUBSCRIPTIONS (SETTINGS)
            GoRoute(
              path: '/admin/subscriptions',
              builder: (context, state) {
                // Kita reuse AdminUsersBloc karena dia yang handle add/edit subscription
                return BlocProvider(
                  create: (context) => AdminUsersBloc(
                    adminRepository: context.read<AdminRepositoryImpl>(),
                  ),
                  // Asumsi nama class di dalam file admin_subscriptions_page.dart adalah AdminSettingsPage
                  child: const AdminSettingsPage(),
                );
              },
            ),
            GoRoute(
              path: '/admin/quiz-detail',
              builder: (context, state) {
                final quiz = state.extra as QuizModel;
                return BlocProvider(
                  create: (context) => AdminQuizDetailBloc(
                    adminRepository: context.read<AdminRepositoryImpl>(),
                  )..add(LoadAdminQuizDetail(quiz.id)),
                  child: AdminQuizDetailPage(quiz: quiz),
                );
              },
            ),
            GoRoute(
              path: '/admin/avatars',
              builder: (context, state) {
                return BlocProvider(
                  create: (context) =>
                      AdminAvatarBloc(context.read<AdminRepositoryImpl>())
                        ..add(LoadAvatarsEvent()), // Load data saat dibuka
                  child: const AdminAvatarPage(),
                );
              },
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
        RepositoryProvider<TeacherRepository>(
          create: (context) => TeacherRepositoryImpl(),
        ),
        RepositoryProvider<LandingRepository>(
          create: (context) =>
              LandingRepositoryImpl(landingService: LandingService()),
        ),
        RepositoryProvider(
          create: (context) => AuthenticationRepositoryImpl(
            firebaseAuthService: AuthService(),
            apiService: AuthApiService(), // Ini pakai ApiClient lama (http)
          ),
        ),

        // ... Repo Teacher, Landing ...

        // STUDENT REPOSITORY (SPESIAL PAKAI DIO)
        RepositoryProvider<StudentRepository>(
          create: (context) {
            // 1. Siapkan Dio (Untuk History & Auth)
            final dio = Dio(
              BaseOptions(
                baseUrl:
                    PlatformConfig.getBaseUrl().replaceAll('/api', '') +
                    '/api', // Sesuaikan URL
                headers: {'Content-Type': 'application/json'},
              ),
            );

            // Pasang Interceptor (Wajib buat History)
            dio.interceptors.add(
              InterceptorsWrapper(
                onRequest: (options, handler) async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    final idToken = await user.getIdToken();
                    options.headers['Authorization'] = 'Bearer $idToken';
                  } else {
                    options.headers['Authorization'] =
                        'Bearer RAHASIA_KITA_BERSAMA';
                  }
                  print("🚀 [REQUEST] METHOD: ${options.method}");
                  print("🔗 [REQUEST] FULL URL: ${options.uri}");
                  return handler.next(options);
                },
              ),
            );

            // 2. Siapkan ApiClient Lama (Untuk Quiz dll)
            // ApiClient ini pakai http biasa di dalamnya
            final apiClient = ApiClient();
            final dioClient = DioClient();

            // 3. Masukkan KEDUANYA ke Repository
            return StudentRepository(apiClient, dio, dioClient);
          },
        ),
        RepositoryProvider<ShopRepository>(
          create: (context) {
            // ... (Gunakan Dio yang sama seperti StudentRepository) ...
            final dio = Dio(
              BaseOptions(
                baseUrl:
                    PlatformConfig.getBaseUrl().replaceAll('/api', '') + '/api',
                headers: {'Content-Type': 'application/json'},
              ),
            );

            // Pasang Interceptor (Wajib buat History)
            dio.interceptors.add(
              InterceptorsWrapper(
                onRequest: (options, handler) async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    final idToken = await user.getIdToken();
                    options.headers['Authorization'] = 'Bearer $idToken';
                  } else {
                    options.headers['Authorization'] =
                        'Bearer RAHASIA_KITA_BERSAMA';
                  }
                  print("🚀 [REQUEST] METHOD: ${options.method}");
                  print("🔗 [REQUEST] FULL URL: ${options.uri}");
                  return handler.next(options);
                },
              ),
            );

            return ShopRepository(dio);
          },
        ),
        RepositoryProvider(
          create: (context) {
            // Sebaiknya gunakan instance Dio yang sama dengan Auth (Singleton)
            // Tapi untuk sekarang new Dio() dulu tidak apa-apa asalkan diatur BaseURL-nya
            final dio = Dio(
              BaseOptions(
                baseUrl: PlatformConfig.getBaseUrl().replaceAll('/api', ''),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            );

            // Ini tugasnya menyisipkan Token otomatis sebelum request dikirim
            dio.interceptors.add(
              InterceptorsWrapper(
                onRequest: (options, handler) async {
                  // Ambil user yang sedang login
                  final user = FirebaseAuth.instance.currentUser;

                  if (user != null) {
                    // Ambil token ID Firebase terbaru
                    final idToken = await user.getIdToken();

                    // Masukkan ke Header: "Authorization: Bearer <token>"
                    options.headers['Authorization'] = 'Bearer $idToken';
                    print(
                      "Token attached: ${idToken?.substring(0, 10)}...",
                    ); // Debugging
                  } else {
                    print("⚠️ Sending Mock Token for Bypass");
                    options.headers['Authorization'] =
                        'Bearer RAHASIA_KITA_BERSAMA';

                    print("User not logged in, no token sent.");
                  }

                  return handler.next(options);
                },
                onError: (error, handler) {
                  print(
                    "Interceptor Error: ${error.response?.statusCode} -> ${error.message}",
                  );
                  return handler.next(error);
                },
              ),
            );

            return AdminRepositoryImpl(
              apiService: AdminApiService(dio),
              adminService: AdminService(client: DioClient()),
            );
          },
        ),
        // PAYMENT REPOSITORY
        RepositoryProvider<PaymentRepository>(
          create: (context) => PaymentRepository(ApiClient()),
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
          // PAYMENT BLOC
          BlocProvider(
            create: (context) => PaymentBloc(context.read<PaymentRepository>()),
          ),
        ],
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) async {
            if (state is AuthUnauthenticated) {
              // Only redirect to login if not on an auth page already
              final currentLocation = router.routeInformationProvider.value.uri
                  .toString();
              final isOnAuthPage =
                  currentLocation == '/' ||
                  currentLocation == '/login' ||
                  currentLocation == '/register' ||
                  currentLocation == '/role-selection';

              // Don't redirect if already on an auth page (prevents override of initial route)
              if (!isOnAuthPage) {
                router.go('/login');
              }
            } else if (state is AuthAuthenticated) {
              final token = await FirebaseAuth.instance.currentUser
                  ?.getIdToken();

              print("ini token setelah login:");
              print(token);

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
