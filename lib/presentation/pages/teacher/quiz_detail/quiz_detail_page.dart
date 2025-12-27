import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';
import 'package:quizify_proyek_mmp/data/repositories/auth_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/quiz_detail/quiz_detail_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/quiz_detail/quiz_detail_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/quiz_detail/quiz_detail_state.dart';
import 'package:quizify_proyek_mmp/presentation/widgets/teacher/quiz_detail/accuracy_list_item.dart';
import 'package:quizify_proyek_mmp/presentation/widgets/teacher/quiz_detail/question_list_item.dart';
import 'package:quizify_proyek_mmp/presentation/widgets/teacher/quiz_detail/quiz_info_card.dart';
import 'package:quizify_proyek_mmp/presentation/widgets/teacher/quiz_detail/student_list_item.dart';

class TeacherQuizDetailPage extends StatefulWidget {
  static const double _kMobileBreakpoint = 600;
  static const double _kDesktopMaxWidth = 900;

  const TeacherQuizDetailPage({super.key, required this.quiz});

  final QuizModel quiz;

  @override
  State<TeacherQuizDetailPage> createState() => _TeacherQuizDetailPageState();
}

class _TeacherQuizDetailPageState extends State<TeacherQuizDetailPage>
    with TickerProviderStateMixin {
  // Tab Controller for Questions/Students/Accuracy tabs
  late TabController _tabController;
  bool _isPremiumUser = false;
  
  // Cache quiz details data to persist across tab changes
  QuizDetailLoaded? _cachedQuizData;

  @override
  void initState() {
    super.initState();
    // We'll update tab length when we know premium status from BLoC
    _tabController = TabController(length: 3, vsync: this); // Max 3 tabs

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPremiumStatus());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    final index = _tabController.index;
    if (index == 0) {
      context.read<QuizDetailBloc>().add(
        LoadQuizDetailEvent(quizId: widget.quiz.id),
      );
    } else if (index == 1) {
      context.read<QuizDetailBloc>().add(
        LoadStudentsEvent(quizId: widget.quiz.id),
      );
    } else if (index == 2) {
      context.read<QuizDetailBloc>().add(
        LoadAccuracyResultsEvent(quizId: widget.quiz.id),
      );
    }
  }

  Future<void> _loadPremiumStatus() async {
    final authRepo = context.read<AuthenticationRepositoryImpl>();
    try {
      final premium = authRepo.isPremiumUser();
      if (mounted) setState(() => _isPremiumUser = premium);
    } catch (e) {
      if (mounted) setState(() => _isPremiumUser = false);
      print('Failed to load premium status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.of(context).size.width >=
        TeacherQuizDetailPage._kMobileBreakpoint;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = isDesktop
        ? TeacherQuizDetailPage._kDesktopMaxWidth
        : double.infinity;

    return Scaffold(
      backgroundColor: AppColors.dirtyCyan,
      appBar: _buildAppBar(context),
      body: BlocConsumer<QuizDetailBloc, QuizDetailState>(
        listener: (context, state) {
          // Handle side effects like navigation after delete
          if (state is QuizDetailDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Quiz deleted successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
            context.go('/teacher/quizzes');
          } else if (state is QuizDetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is QuizDetailLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.darkAzure),
            );
          }

          if (state is QuizDetailError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load quiz',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<QuizDetailBloc>().add(
                        LoadQuizDetailEvent(quizId: widget.quiz.id),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkAzure,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is QuizDetailLoaded ||
              state is StudentsLoading ||
              state is StudentsLoaded ||
              state is StudentsError ||
              state is AccuracyLoading ||
              state is AccuracyLoaded ||
              state is AccuracyError) {
            // Cache quiz data when it's loaded
            if (state is QuizDetailLoaded) {
              _cachedQuizData = state;
            }
            
            // Use cached data or create fallback
            final quizData = _cachedQuizData ??
                QuizDetailLoaded(quiz: widget.quiz, questions: const []);

            return _buildContent(
              context,
              quizData,
              isDesktop,
              screenWidth,
              maxWidth,
            );
          }

          // Initial state - show loading
          return const Center(
            child: CircularProgressIndicator(color: AppColors.darkAzure),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.darkAzure,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.go("/teacher/quizzes"),
      ),
      automaticallyImplyLeading: false,
      title: const Text(
        'Quiz Details',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        // Edit button
        BlocBuilder<QuizDetailBloc, QuizDetailState>(
          builder: (context, state) {
            if (state is! QuizDetailLoaded) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                // Navigate to edit page with quiz and questions
                context.go(
                  '/teacher/quiz-detail/edit',
                  extra: {'quiz': state.quiz, 'questions': state.questions},
                );
              },
              tooltip: 'Edit Quiz',
            );
          },
        ),
        // Delete button
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.white),
          onPressed: () => _showDeleteConfirmation(context),
          tooltip: 'Delete Quiz',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    QuizDetailLoaded state,
    bool isDesktop,
    double screenWidth,
    double maxWidth,
  ) {
    // Determine number of tabs based on premium status
    final tabCount = _isPremiumUser ? 3 : 2;

    // Update tab controller if needed
    if (_tabController.length != tabCount) {
      _tabController.dispose();
      _tabController = TabController(length: tabCount, vsync: this);
    }

    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          width: screenWidth,
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 16.0 : 12.0,
            vertical: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quiz Info Card
              QuizInfoCard(
                quiz: state.quiz,
                questionsCount: state.questions.length,
                isDesktop: isDesktop,
                questions: state.questions,
              ),

              const SizedBox(height: 24.0),

              // Tab Bar
              Container(
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.darkAzure,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.darkAzure,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  onTap: (index) {
                    _onTabChanged();
                  },
                  tabs: [
                    const Tab(
                      icon: Icon(Icons.quiz_outlined),
                      text: 'Questions',
                    ),
                    const Tab(
                      icon: Icon(Icons.people_outline),
                      text: 'Students',
                    ),
                    if (_isPremiumUser)
                      const Tab(
                        icon: Icon(Icons.analytics_outlined),
                        text: 'Accuracy',
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24.0),

              // Tab Content (based on selected tab and current BLoC state)
              BlocBuilder<QuizDetailBloc, QuizDetailState>(
                builder: (context, currentState) {
                  return _buildTabContent(context, currentState, isDesktop);
                },
              ),

              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    QuizDetailState state,
    bool isDesktop,
  ) {
    switch (_tabController.index) {
      case 0:
        return _buildQuestionsTab(context, state, isDesktop);
      case 1:
        return _buildStudentsTab(context, state, isDesktop);
      case 2:
        if (_isPremiumUser) {
          return _buildAccuracyTab(context, state, isDesktop);
        }
        return const SizedBox.shrink();
      default:
        return _buildQuestionsTab(context, state, isDesktop);
    }
  }

  // ============================================================
  // Questions Tab
  // ============================================================
  Widget _buildQuestionsTab(
    BuildContext context,
    QuizDetailState state,
    bool isDesktop,
  ) {
    if (state is QuizDetailLoaded && state.questions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.quiz_outlined,
                size: 64,
                color: AppColors.darkAzure.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No questions yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Edit the quiz to add questions',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textDark.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state is QuizDetailLoaded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Questions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkAzure,
                ),
              ),
              Text(
                '${state.questions.length} total',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textDark.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.questions.length,
            itemBuilder: (context, index) {
              return QuestionListItem(
                question: state.questions[index],
                index: index,
              );
            },
          ),
        ],
      );
    }

    // Default fallback for unexpected states
    return Container(
      padding: const EdgeInsets.all(40),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.darkAzure),
      ),
    );
  }

  // ============================================================
  // Students Tab
  // ============================================================
  Widget _buildStudentsTab(
    BuildContext context,
    QuizDetailState state,
    bool isDesktop,
  ) {
    if (state is StudentsLoading) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.darkAzure),
        ),
      );
    }

    if (state is StudentsLoaded && state.students.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: AppColors.darkAzure.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No students have taken this quiz yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state is StudentsLoaded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${state.students.length} Students Attended',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkAzure,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.students.length,
            itemBuilder: (context, index) {
              return StudentListItem(
                student: state.students[index],
                index: index,
              );
            },
          ),
        ],
      );
    }

    if (state is StudentsError) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load students',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Default fallback
    return Container(
      padding: const EdgeInsets.all(40),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.darkAzure),
      ),
    );
  }

  // ============================================================
  // Accuracy Tab (Premium Only)
  // ============================================================
  Widget _buildAccuracyTab(
    BuildContext context,
    QuizDetailState state,
    bool isDesktop,
  ) {
    if (state is AccuracyLoading) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.darkAzure),
        ),
      );
    }

    if (state is AccuracyLoaded && state.accuracyResults.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 64,
                color: AppColors.darkAzure.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No accuracy data available yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Accuracy data will appear after students complete the quiz',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textDark.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state is AccuracyLoaded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Premium Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.amber, Colors.orange],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  'Premium Feature',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Question Accuracy Analysis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkAzure,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.accuracyResults.length,
            itemBuilder: (context, index) {
              return AccuracyListItem(
                result: state.accuracyResults[index],
                index: index,
              );
            },
          ),
        ],
      );
    }

    if (state is AccuracyError) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load accuracy data',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Default fallback
    return Container(
      padding: const EdgeInsets.all(40),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.darkAzure),
      ),
    );
  }

  // ============================================================
  // Delete Confirmation Dialog
  // ============================================================
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Delete Quiz'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${widget.quiz.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<QuizDetailBloc>().add(
                DeleteQuizEvent(quizId: widget.quiz.id),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
