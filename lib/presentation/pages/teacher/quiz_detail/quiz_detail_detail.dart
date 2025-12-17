import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/quiz_detail/quiz_detail_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/quiz_detail/quiz_detail_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/quiz_detail/quiz_detail_state.dart';

/// Quiz Detail Page for Teachers
///
/// This page displays quiz information, questions, students who attended,
/// and accuracy results (for premium users).
///
/// Uses BLoC pattern for state management:
/// - [QuizDetailBloc] handles all business logic
/// - [QuizDetailState] contains the current state
/// - [QuizDetailEvent] triggers state changes
class TeacherQuizDetailPage extends StatefulWidget {
  static const double _kMobileBreakpoint = 600;
  static const double _kDesktopMaxWidth = 900;

  const TeacherQuizDetailPage({super.key, required this.quiz});

  final QuizModel quiz;

  @override
  State<TeacherQuizDetailPage> createState() => _TeacherQuizDetailPageState();
}

class _TeacherQuizDetailPageState extends State<TeacherQuizDetailPage>
    with SingleTickerProviderStateMixin {
  // Tab Controller for Questions/Students/Accuracy tabs
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // We'll update tab length when we know premium status from BLoC
    _tabController = TabController(length: 3, vsync: this); // Max 3 tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _copyCodeToClipboard(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Quiz code copied to clipboard!'),
        backgroundColor: AppColors.darkAzure,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'public':
        return 'Public';
      case 'private':
        return 'Private';
      case 'draft':
        return 'Draft';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'public':
        return Colors.green;
      case 'private':
        return Colors.orange;
      case 'draft':
        return Colors.grey;
      default:
        return AppColors.darkAzure;
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

          if (state is QuizDetailLoaded) {
            return _buildContent(
              context,
              state,
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
    final tabCount = state.isPremiumUser ? 3 : 2;

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
              _buildQuizInfoCard(context, state, isDesktop),

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
                    context.read<QuizDetailBloc>().add(
                      ChangeTabEvent(tabIndex: index),
                    );
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
                    if (state.isPremiumUser)
                      const Tab(
                        icon: Icon(Icons.analytics_outlined),
                        text: 'Accuracy',
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24.0),

              // Tab Content (based on selected tab from BLoC state)
              _buildTabContent(context, state, isDesktop),

              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    QuizDetailLoaded state,
    bool isDesktop,
  ) {
    switch (state.selectedTabIndex) {
      case 0:
        return _buildQuestionsTab(context, state, isDesktop);
      case 1:
        return _buildStudentsTab(context, state, isDesktop);
      case 2:
        if (state.isPremiumUser) {
          return _buildAccuracyTab(context, state, isDesktop);
        }
        return const SizedBox.shrink();
      default:
        return _buildQuestionsTab(context, state, isDesktop);
    }
  }

  // ============================================================
  // Quiz Info Card
  // ============================================================
  Widget _buildQuizInfoCard(
    BuildContext context,
    QuizDetailLoaded state,
    bool isDesktop,
  ) {
    final quiz = state.quiz;
    final quizCode =
        quiz.quizCode ??
        (quiz.id.length >= 8
            ? quiz.id.substring(0, 8).toUpperCase()
            : quiz.id.toUpperCase());

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Status Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkAzure,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(quiz.status).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(quiz.status),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            quiz.status.toLowerCase() == 'public'
                                ? Icons.public
                                : Icons.lock,
                            size: 16,
                            color: _getStatusColor(quiz.status),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getStatusLabel(quiz.status),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(quiz.status),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Edit Button in Header
              ElevatedButton.icon(
                onPressed: () {
                  context.go(
                    '/teacher/quiz-detail/edit',
                    extra: {'quiz': state.quiz, 'questions': state.questions},
                  );
                },
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkAzure,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),

          // Description
          if (quiz.description != null && quiz.description!.isNotEmpty) ...[
            const SizedBox(height: 20.0),
            Text(
              quiz.description!,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textDark.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ],

          const SizedBox(height: 20.0),
          const Divider(height: 1, color: AppColors.lightCyan),
          const SizedBox(height: 20.0),

          // Quiz Details Grid
          if (isDesktop)
            _buildDesktopDetailsGrid(state, quizCode)
          else
            _buildMobileDetailsColumn(state, quizCode),

          // Created/Updated Date
          if (quiz.createdAt != null) ...[
            const SizedBox(height: 20.0),
            const Divider(height: 1, color: AppColors.lightCyan),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textDark.withOpacity(0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  'Created: ${_formatDate(quiz.createdAt!)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textDark.withOpacity(0.5),
                  ),
                ),
                if (quiz.updatedAt != null) ...[
                  const SizedBox(width: 16),
                  Text(
                    '•',
                    style: TextStyle(
                      color: AppColors.textDark.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Updated: ${_formatDate(quiz.updatedAt!)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textDark.withOpacity(0.5),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDesktopDetailsGrid(QuizDetailLoaded state, String quizCode) {
    return Row(
      children: [
        Expanded(
          child: _buildDetailItem(
            icon: Icons.qr_code,
            label: 'Quiz Code',
            value: quizCode,
            onCopy: () => _copyCodeToClipboard(quizCode),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDetailItem(
            icon: Icons.category,
            label: 'Category',
            value: state.quiz.category ?? 'Uncategorized',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDetailItem(
            icon: Icons.quiz,
            label: 'Questions',
            value: '${state.questions.length}',
          ),
        ),
      ],
    );
  }

  Widget _buildMobileDetailsColumn(QuizDetailLoaded state, String quizCode) {
    return Column(
      children: [
        _buildDetailItem(
          icon: Icons.qr_code,
          label: 'Quiz Code',
          value: quizCode,
          onCopy: () => _copyCodeToClipboard(quizCode),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                icon: Icons.category,
                label: 'Category',
                value: state.quiz.category ?? 'Uncategorized',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDetailItem(
                icon: Icons.quiz,
                label: 'Questions',
                value: '${state.questions.length}',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightCyan.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.darkAzure.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.darkAzure),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textDark.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkAzure,
                  ),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              icon: const Icon(Icons.copy, size: 20),
              onPressed: onCopy,
              color: AppColors.darkAzure,
              tooltip: 'Copy',
            ),
        ],
      ),
    );
  }

  // ============================================================
  // Questions Tab
  // ============================================================
  Widget _buildQuestionsTab(
    BuildContext context,
    QuizDetailLoaded state,
    bool isDesktop,
  ) {
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
        _buildQuestionsList(state.questions, isDesktop),
      ],
    );
  }

  Widget _buildQuestionsList(List<QuestionModel> questions, bool isDesktop) {
    if (questions.isEmpty) {
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

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        return _buildQuestionCard(questions[index], index);
      },
    );
  }

  Widget _buildQuestionCard(QuestionModel question, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.darkAzure,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Text(
          question.questionText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              _buildQuestionTag(
                question.type == 'multiple' ? 'Multiple Choice' : 'True/False',
              ),
              const SizedBox(width: 8),
              _buildQuestionTag(question.difficulty, isColored: true),
            ],
          ),
        ),
        children: [
          const Divider(),
          const SizedBox(height: 8),
          // Options
          ...question.options.asMap().entries.map((entry) {
            final optionIndex = entry.key;
            final option = entry.value;
            final isCorrect = option == question.correctAnswer;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isCorrect
                    ? Colors.green.withOpacity(0.1)
                    : AppColors.lightCyan.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCorrect ? Colors.green : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? Colors.green
                          : AppColors.darkAzure.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCorrect
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : Text(
                              String.fromCharCode(65 + optionIndex),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkAzure.withOpacity(0.7),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 14,
                        color: isCorrect
                            ? Colors.green.shade700
                            : AppColors.textDark,
                        fontWeight: isCorrect
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isCorrect)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Correct',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuestionTag(String text, {bool isColored = false}) {
    Color bgColor;
    Color textColor;

    if (isColored) {
      switch (text.toLowerCase()) {
        case 'easy':
          bgColor = Colors.green.withOpacity(0.1);
          textColor = Colors.green;
          break;
        case 'medium':
          bgColor = Colors.orange.withOpacity(0.1);
          textColor = Colors.orange;
          break;
        case 'hard':
          bgColor = Colors.red.withOpacity(0.1);
          textColor = Colors.red;
          break;
        default:
          bgColor = AppColors.lightCyan.withOpacity(0.5);
          textColor = AppColors.darkAzure;
      }
    } else {
      bgColor = AppColors.lightCyan.withOpacity(0.5);
      textColor = AppColors.darkAzure;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  // ============================================================
  // Students Tab
  // ============================================================
  Widget _buildStudentsTab(
    BuildContext context,
    QuizDetailLoaded state,
    bool isDesktop,
  ) {
    if (state.isLoadingStudents) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.darkAzure),
        ),
      );
    }

    if (state.students.isEmpty) {
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
            return _buildStudentCard(state.students[index], index);
          },
        ),
      ],
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student, int index) {
    final score = student['score'] as int;
    final scoreColor = score >= 80
        ? Colors.green
        : (score >= 60 ? Colors.orange : Colors.red);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.darkAzure,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Student Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['student'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Completed on ${_formatDateTime(student['ended_at'])}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textDark.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          // Score Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: scoreColor, width: 1.5),
            ),
            child: Text(
              '$score%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: scoreColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Accuracy Tab (Premium Only)
  // ============================================================
  Widget _buildAccuracyTab(
    BuildContext context,
    QuizDetailLoaded state,
    bool isDesktop,
  ) {
    if (state.isLoadingAccuracy) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.darkAzure),
        ),
      );
    }

    if (state.accuracyResults.isEmpty) {
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
            return _buildAccuracyCard(state.accuracyResults[index], index);
          },
        ),
      ],
    );
  }

  Widget _buildAccuracyCard(Map<String, dynamic> result, int index) {
    final accuracy = result['accuracy'] as int;
    final correctAnswers = result['correct_answers'] as int;
    final totalAnswered = result['total_answered'] as int;
    final accuracyColor = accuracy >= 80
        ? Colors.green
        : (accuracy >= 60 ? Colors.orange : Colors.red);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.darkAzure,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  result['question'] ?? 'Unknown question',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$correctAnswers / $totalAnswered correct',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textDark.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    '$accuracy%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: accuracyColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: accuracy / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(accuracyColor),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
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

  // ============================================================
  // Utility Methods
  // ============================================================
  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'Unknown';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
          '${dateTime.hour.toString().padLeft(2, '0')}:'
          '${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }
}
