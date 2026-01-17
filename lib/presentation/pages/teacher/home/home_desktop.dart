import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_state.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/home/home_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/home/home_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/home/home_state.dart';

/// Desktop layout for the Teacher Home page
///
/// Displays recommended quizzes and all public quizzes with search functionality
class TeacherHomeDesktop extends StatefulWidget {
  const TeacherHomeDesktop({super.key});

  @override
  State<TeacherHomeDesktop> createState() => _TeacherHomeDesktopState();
}

class _TeacherHomeDesktopState extends State<TeacherHomeDesktop> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // LoadPublicQuizzesEvent should be called in TeacherHomePage
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.darkAzure,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Teacher Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<TeacherHomeBloc, TeacherHomeState>(
        builder: (context, state) {
          if (state is TeacherHomeLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.darkAzure),
            );
          }

          if (state is TeacherHomeError) {
            return _buildErrorState(context, state.message);
          }

          if (state is TeacherHomeLoaded) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recommended Quizzes Section
                    const Text(
                      'Recommended Quizzes',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkAzure,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildRecommendedSection(context, state),
                    const SizedBox(height: 48),

                    // All Quizzes Section
                    const Text(
                      'All Quizzes',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkAzure,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Search Bar
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (query) {
                          context.read<TeacherHomeBloc>().add(
                            SearchQuizzesEvent(query),
                          );
                        },
                        decoration: InputDecoration(
                          hintText: 'Search quizzes...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.darkAzure,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quiz Cards List in Grid
                    if (state.filteredQuizzes.isEmpty)
                      _buildEmptyState()
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 24,
                              childAspectRatio: 1.3,
                            ),
                        itemCount: state.filteredQuizzes.length,
                        itemBuilder: (context, index) {
                          final quiz = state.filteredQuizzes[index];
                          return _buildQuizCard(context, quiz);
                        },
                      ),
                  ],
                ),
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(color: AppColors.darkAzure),
          );
        },
      ),
    );
  }

  Widget _buildRecommendedSection(
    BuildContext context,
    TeacherHomeLoaded state,
  ) {
    // Get top 10 quizzes as recommended
    final recommended = state.quizzes.take(10).toList();

    if (recommended.isEmpty) {
      return _buildEmptyState();
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: recommended.length,
        itemBuilder: (context, index) {
          final quiz = recommended[index];
          return _buildRecommendedCard(context, quiz);
        },
      ),
    );
  }

  Widget _buildRecommendedCard(BuildContext context, QuizModel quiz) {
    final colors = [
      const Color(0xFF80D8DA),
      const Color(0xFF81C784),
      const Color(0xFF64B5F6),
      const Color(0xFFFFB74D),
    ];
    final color = colors[quiz.id.hashCode % colors.length];

    return GestureDetector(
      onTap: () {
        final authState = context.read<AuthBloc>().state;
        String? currentUserId;
        if (authState is AuthAuthenticated) {
          currentUserId = authState.user.id;
        }

        if (quiz.createdBy == currentUserId) {
          context.push('/teacher/quiz-detail', extra: quiz);
        } else {
          context.push('/teacher/other-quiz-detail', extra: quiz);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        width: 200,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              quiz.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              quiz.category ?? 'General',
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
            Row(
              children: [
                const Icon(Icons.help_outline, size: 16, color: Colors.white70),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${quiz.description?.split(' ').length ?? 0} Q',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCard(BuildContext context, QuizModel quiz) {
    return GestureDetector(
      onTap: () {
        final authState = context.read<AuthBloc>().state;
        String? currentUserId;
        if (authState is AuthAuthenticated) {
          currentUserId = authState.user.id;
        }

        if (quiz.createdBy == currentUserId) {
          context.push('/teacher/quiz-detail', extra: quiz);
        } else {
          context.push('/teacher/other-quiz-detail', extra: quiz);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkAzure,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        quiz.category ?? 'General',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildDifficultyBadge('Medium'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${quiz.description?.split(' ').length ?? 0} questions',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.schedule, size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        '30 min',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    Color bgColor;
    Color textColor;

    switch (difficulty.toLowerCase()) {
      case 'easy':
        bgColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        break;
      case 'hard':
        bgColor = Colors.red[100]!;
        textColor = Colors.red[700]!;
        break;
      case 'medium':
      default:
        bgColor = Colors.orange[100]!;
        textColor = Colors.orange[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.quiz, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              'No quizzes found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 100, color: Colors.red[300]),
          const SizedBox(height: 24),
          Text(
            'Failed to load quizzes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<TeacherHomeBloc>().add(const RefreshQuizzesEvent());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkAzure,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
