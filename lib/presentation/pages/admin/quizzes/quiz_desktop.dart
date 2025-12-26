import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';

class AdminQuizDesktopPage extends StatelessWidget {
  final List<QuizModel> quizzes;

  const AdminQuizDesktopPage({super.key, required this.quizzes});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 1200 ? 4 : 3;

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5, // Rasio lebar:tinggi card
      ),
      itemCount: quizzes.length,
      itemBuilder: (context, index) {
        return _QuizGridCard(quiz: quizzes[index]);
      },
    );
  }
}

class _QuizGridCard extends StatelessWidget {
  final QuizModel quiz;

  const _QuizGridCard({required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          context.go('/admin/quiz/${quiz.id}', extra: quiz.title);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.darkAzure.withOpacity(0.1),
                    child: const Icon(Icons.quiz, color: AppColors.darkAzure),
                  ),
                  const Spacer(),
                  // Badge Status (Public/Private)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: quiz.status == 'public' ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      quiz.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10, 
                        fontWeight: FontWeight.bold,
                        color: quiz.status == 'public' ? Colors.green : Colors.grey[700],
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),
              Text(
                quiz.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  quiz.description ?? "No description",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Created by: ${quiz.creatorName ?? 'Unknown'}",
                style: TextStyle(fontSize: 11, color: Colors.grey[500], fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}