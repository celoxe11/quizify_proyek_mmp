import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/quizzes/quizzes_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/quizzes/quizzes_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/quizzes/quizzes_state.dart';

/// Desktop layout for the Quizzes page.
///
/// Uses BLoC pattern for state management.
/// Displays quizzes in a grid layout with search and filter options.
class TeacherQuizDesktop extends StatelessWidget {
  const TeacherQuizDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.darkAzure,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Text(
        'My Quizzes',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        // Search field
        BlocBuilder<QuizzesBloc, QuizzesState>(
          builder: (context, state) {
            return Container(
              width: 250,
              height: 40,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search quizzes...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  context.read<QuizzesBloc>().add(SearchQuizzesEvent(value));
                },
              ),
            );
          },
        ),
        const SizedBox(width: 16),
        // Refresh button
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            context.read<QuizzesBloc>().add(RefreshQuizzesEvent());
          },
          tooltip: 'Refresh',
        ),
        const SizedBox(width: 8),
        // Create Quiz button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton.icon(
            onPressed: () {
              context.go("/teacher/new-quiz");
            },
            icon: const Icon(Icons.add, color: AppColors.darkAzure),
            label: const Text(
              'Create New Quiz',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkAzure,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, QuizzesLoaded state) {
    if (state.filteredQuizzes.isEmpty) {
      return _buildEmptyState(context, state);
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with count and filters
            _buildHeader(context, state),

            const SizedBox(height: 24),

            // Quiz grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 2,
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

  Widget _buildHeader(BuildContext context, QuizzesLoaded state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Total Quizzes: ${state.quizzes.length}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            if (state.filteredQuizzes.length != state.quizzes.length) ...[
              const SizedBox(width: 8),
              Text(
                '(${state.filteredQuizzes.length} shown)',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ],
        ),
        Row(
          children: [
            // Status filter
            _buildFilterChip(
              context: context,
              label: 'All',
              isSelected: state.statusFilter == null,
              onSelected: () {
                context.read<QuizzesBloc>().add(const FilterQuizzesEvent(null));
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context: context,
              label: 'Public',
              isSelected: state.statusFilter == 'public',
              onSelected: () {
                context.read<QuizzesBloc>().add(
                  const FilterQuizzesEvent('public'),
                );
              },
              color: Colors.green,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context: context,
              label: 'Private',
              isSelected: state.statusFilter == 'private',
              onSelected: () {
                context.read<QuizzesBloc>().add(
                  const FilterQuizzesEvent('private'),
                );
              },
              color: Colors.orange,
            ),
            // Category dropdown
            if (state.categories.isNotEmpty) ...[
              const SizedBox(width: 16),
              const VerticalDivider(width: 1, thickness: 1),
              const SizedBox(width: 16),
              PopupMenuButton<String?>(
                initialValue: state.categoryFilter,
                onSelected: (value) {
                  context.read<QuizzesBloc>().add(FilterByCategoryEvent(value));
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: null,
                    child: Text('All Categories'),
                  ),
                  const PopupMenuDivider(),
                  ...state.categories.map(
                    (cat) => PopupMenuItem(value: cat, child: Text(cat)),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: state.categoryFilter != null
                        ? AppColors.darkAzure.withOpacity(0.1)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.category, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        state.categoryFilter ?? 'Category',
                        style: TextStyle(
                          fontWeight: state.categoryFilter != null
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    Color? color,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: (color ?? AppColors.darkAzure).withOpacity(0.2),
      checkmarkColor: color ?? AppColors.darkAzure,
      labelStyle: TextStyle(
        color: isSelected ? (color ?? AppColors.darkAzure) : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
          Icon(Icons.quiz_outlined, size: 120, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            hasFilters ? 'No quizzes match your filters' : 'No quizzes yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            hasFilters
                ? 'Try adjusting your search or filters'
                : 'Create your first quiz to get started',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          if (hasFilters) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<QuizzesBloc>().add(const FilterQuizzesEvent(null));
                context.read<QuizzesBloc>().add(
                  const FilterByCategoryEvent(null),
                );
                context.read<QuizzesBloc>().add(const SearchQuizzesEvent(''));
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear All Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkAzure,
                foregroundColor: Colors.white,
              ),
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
          Icon(Icons.error_outline, size: 120, color: Colors.red[300]),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64),
            child: Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<QuizzesBloc>().add(LoadQuizzesEvent());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkAzure,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.push('/teacher/quiz-detail', extra: quiz);
          },
          child: Padding(
            padding: const EdgeInsets.all(24),
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
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkAzure,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            quiz.description ?? 'No description',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Category badge
                        if (quiz.category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.darkAzure.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              quiz.category!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkAzure,
                              ),
                            ),
                          ),
                        const SizedBox(height: 6),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
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
                                size: 14,
                                color: statusColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isPublic ? 'Public' : 'Private',
                                style: TextStyle(
                                  fontSize: 12,
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
                const Spacer(),
                // Created date
                if (quiz.createdAt != null)
                  Text(
                    'Created: ${_formatDate(quiz.createdAt!)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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
