import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';

class TeacherQuizMobile extends StatefulWidget {
  const TeacherQuizMobile({super.key});

  @override
  State<TeacherQuizMobile> createState() => _TeacherQuizMobileState();
}

class _TeacherQuizMobileState extends State<TeacherQuizMobile> {
  // Dummy quiz data using QuizModel
  final List<QuizModel> _quizzes = [
    QuizModel(
      id: '1',
      title: 'Math Quiz 101',
      description: 'Basic algebra and geometry questions',
      status: 'public',
      category: 'Mathematics',
      createdAt: DateTime(2024, 11, 15),
    ),
    QuizModel(
      id: '2',
      title: 'Science Challenge',
      description: 'Physics and Chemistry fundamentals',
      status: 'public',
      category: 'Science',
      createdAt: DateTime(2024, 11, 20),
    ),
    QuizModel(
      id: '3',
      title: 'History Trivia',
      description: 'World War II historical events',
      status: 'private',
      category: 'History',
      createdAt: DateTime(2024, 11, 22),
    ),
    QuizModel(
      id: '4',
      title: 'English Grammar',
      description: 'Advanced grammar rules and usage',
      status: 'public',
      category: 'English',
      createdAt: DateTime(2024, 11, 25),
    ),
    QuizModel(
      id: '5',
      title: 'Programming Basics',
      description: 'Introduction to programming concepts',
      status: 'public',
      category: 'Technology',
      createdAt: DateTime(2024, 11, 28),
    ),
  ];

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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/teacher/new-quiz');
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Quiz List
          Expanded(
            child: _quizzes.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _quizzes.length,
                    itemBuilder: (context, index) {
                      final quiz = _quizzes[index];
                      return _buildQuizCard(quiz);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No quizzes yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first quiz to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(QuizModel quiz) {
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
            context.go('/teacher/quiz-detail', extra: quiz);
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

  Widget _buildQuizInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
