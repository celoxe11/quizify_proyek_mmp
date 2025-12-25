import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';

class AdminQuizMobilePage extends StatelessWidget {
  final List<QuizModel> quizzes;

  const AdminQuizMobilePage({super.key, required this.quizzes});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: quizzes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        return _QuizCard(quiz: quiz);
      },
    );
  }
}

// --- WIDGET CARD YANG SERAGAM ---
class _QuizCard extends StatelessWidget {
  final QuizModel quiz;

  const _QuizCard({required this.quiz});

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
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigasi ke Detail (Pastikan route di main.dart benar)
          // Mengirim 'extra' title agar di halaman detail judulnya langsung muncul
          context.go('/admin/quiz/${quiz.id}', extra: quiz.title);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.darkAzure.withOpacity(0.1),
                child: const Icon(Icons.quiz, color: AppColors.darkAzure),
              ),
              const SizedBox(width: 16),
              
              // Info Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      // Tampilkan deskripsi atau placeholder
                      quiz.description?.isNotEmpty == true 
                          ? quiz.description! 
                          : "No description available",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Badge Status/Code
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.orange.withOpacity(0.5)),
                      ),
                      child: Text(
                        "Code: ${quiz.quizCode ?? '-'}",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange[800]),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}