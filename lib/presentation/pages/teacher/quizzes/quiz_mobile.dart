import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/quizzes/quizzes_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/quizzes/quizzes_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/quizzes/quizzes_state.dart';

/// Mobile layout for the Quizzes page.
///
/// Uses BLoC pattern for state management.
/// Data flows from [QuizzesBloc] via [QuizzesState].
class TeacherQuizMobile extends StatelessWidget {
  const TeacherQuizMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.darkAzure,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'My Quizzes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<QuizzesBloc>().add(RefreshQuizzesEvent());
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/teacher/new-quiz');
        },
        backgroundColor: AppColors.darkAzure,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocBuilder<QuizzesBloc, QuizzesState>(
        builder: (context, state) {
          if (state is QuizzesLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.darkAzure),
            );
          }

          if (state is QuizzesError) {
            return _buildErrorState(context, state.message);
          }

          if (state is QuizzesLoaded) {
            return _buildContent(context, state);
          }

          // Initial state
          return const Center(
            child: CircularProgressIndicator(color: AppColors.darkAzure),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, QuizzesLoaded state) {
    if (state.filteredQuizzes.isEmpty) {
      return _buildEmptyState(context, state);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<QuizzesBloc>().add(RefreshQuizzesEvent());
        // Wait a bit for the refresh to complete
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: AppColors.darkAzure,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.filteredQuizzes.length,
        itemBuilder: (context, index) {
          final quiz = state.filteredQuizzes[index];
          return _buildQuizCard(context, quiz);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, QuizzesLoaded state) {
    final hasFilters =
        state.searchQuery != null ||
        state.statusFilter != null ||
        state.categoryFilter != null;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'No quizzes match your filters' : 'No quizzes yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Try adjusting your filters'
                : 'Create your first quiz to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          if (hasFilters) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                context.read<QuizzesBloc>().add(const FilterQuizzesEvent(null));
                context.read<QuizzesBloc>().add(
                  const FilterByCategoryEvent(null),
                );
                context.read<QuizzesBloc>().add(const SearchQuizzesEvent(''));
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear Filters'),
            ),
          ],
        ],
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<QuizzesBloc>().add(LoadQuizzesEvent());
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

  Widget _buildQuizCard(BuildContext context, QuizModel quiz) {
    final isPublic = quiz.status.toLowerCase() == 'public';
    Color statusColor = isPublic ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            context.push('/teacher/quiz-detail', extra: quiz);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                          ),
                          const SizedBox(height: 4),
                          Text(
                            quiz.description ?? 'No description',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        // Category badge
                        if (quiz.category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.darkAzure.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              quiz.category!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkAzure,
                              ),
                            ),
                          ),
                        const SizedBox(height: 4),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPublic ? Icons.public : Icons.lock,
                                size: 12,
                                color: statusColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isPublic ? 'Public' : 'Private',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Created date
                if (quiz.createdAt != null)
                  Text(
                    'Created: ${_formatDate(quiz.createdAt!)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
