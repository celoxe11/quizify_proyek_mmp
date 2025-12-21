/// Core services barrel export.
///
/// This file provides easy access to all service classes.
///
/// ## Usage:
/// ```dart
/// import 'package:quizify_proyek_mmp/core/services/services.dart';
///
/// // Teacher services
/// final teacherQuizService = TeacherQuizService();
/// final teacherQuestionService = TeacherQuestionService();
///
/// // Student services
/// final studentQuizService = StudentQuizService();
///
/// // Admin services
/// final adminService = AdminService();
/// ```
///
/// ## Architecture:
/// - Services use [DioClient] for HTTP requests with Firebase auth
/// - Each role (teacher/student/admin) has its own service folder
/// - Existing [ApiClient] (http) is still available for legacy code
library services;

// Teacher services
export 'teacher/teacher_service.dart';

// Student services
export 'student/student_services.dart';

// Admin services
export 'admin/admin_services.dart';

// Legacy services (using http ApiClient) - keep for backward compatibility
export 'auth/auth_service.dart';
export 'auth/auth_api_service.dart';
