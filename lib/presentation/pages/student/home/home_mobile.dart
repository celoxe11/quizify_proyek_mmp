import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/home/home_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/home/home_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/home/home_state.dart';

/// Mobile layout for the Student Home page
///
/// Displays recommended quizzes and all public quizzes with search functionality
class StudentHomeMobile extends StatefulWidget {
  const StudentHomeMobile({super.key});

  @override
  State<StudentHomeMobile> createState() => _StudentHomeMobileState();
}

class _StudentHomeMobileState extends State<StudentHomeMobile> {
  late TextEditingController _searchController;
  bool _isNavigatingToQuiz = false; // Flag to prevent duplicate navigation

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // LoadPublicQuizzesEvent sudah dipanggil di StudentHomePage
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
          'Quizzes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<StudentHomeBloc, StudentHomeState>(
          builder: (context, state) {
            if (state is StudentHomeLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.darkAzure),
              );
            }

            if (state is StudentHomeError) {
              return _buildErrorState(context, state.message);
            }

            if (state is StudentHomeLoaded) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recommended Quizzes Section
                      _buildRecommendedSection(context, state),
                      const SizedBox(height: 32),

                      // All Quizzes Section
                      const Text(
                        'All Quizzes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkAzure,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Search Bar
                      TextField(
                        controller: _searchController,
                        onChanged: (query) {
                          context.read<StudentHomeBloc>().add(
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
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Quiz Cards List
                      if (state.filteredQuizzes.isEmpty)
                        _buildEmptyState()
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
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
    StudentHomeLoaded state,
  ) {
    // Get top 3 quizzes as recommended
    final recommended = state.quizzes.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommended Quizzes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkAzure,
          ),
        ),
        const SizedBox(height: 16),
        if (recommended.isEmpty)
          _buildEmptyState()
        else
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recommended.length,
              itemBuilder: (context, index) {
                final quiz = recommended[index];
                return _buildRecommendedCard(context, quiz);
              },
            ),
          ),
      ],
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
        // Navigate to quiz detail page to show info before starting
        context.push('/student/quiz-detail', extra: quiz);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 160,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title and Description
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  quiz.description ?? quiz.category ?? 'General',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            // Stats Row (Questions and Participants)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Questions Count
                Row(
                  children: [
                    const Icon(Icons.description,
                        size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '${quiz.description?.split(' ').length ?? 0} Q',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                // Participants Count
                Row(
                  children: [
                    const Icon(Icons.people, size: 14, color: Colors.white),
                    const SizedBox(width: 2),
                    const Text(
                      '85',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
        // Navigate to quiz detail page to show info before starting
        context.push('/student/quiz-detail', extra: quiz);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.title,
                    style: const TextStyle(
                      fontSize: 16,
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
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.help_outline,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${quiz.description?.split(' ').length ?? 0} questions',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.schedule,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '30 min',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _buildDifficultyBadge('Medium'),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.quiz, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No quizzes found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
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
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Failed to load quizzes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<StudentHomeBloc>().add(const RefreshQuizzesEvent());
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
}
