import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/domain/entities/question.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/quiz_detail/admin_quiz_detail_bloc.dart';

class AdminQuizDetailMobile extends StatelessWidget {
  final List<Question> questions;
  final String quizId; 

  const AdminQuizDetailMobile({
    super.key, 
    required this.questions, 
    required this.quizId
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: questions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return QuestionCard(
          index: index,
          question: questions[index],
          quizId: quizId,
        );
      },
    );
  }
}

// --- Question Card Widget (Bisa dipisah ke file widget sendiri jika mau) ---
class QuestionCard extends StatelessWidget {
  final int index;
  final Question question;
  final String quizId;

  const QuestionCard({
    super.key,
    required this.index,
    required this.question,
    required this.quizId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- HEADER: Nomor, Teks Soal, dan Tombol Delete ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.darkAzure,
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.questionText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                     _showDeleteConfirmation(context);
                  },
                  tooltip: 'Delete Question',
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.hovered)) {
                        return Colors.red.withOpacity(0.1);
                      }
                      return Colors.transparent;
                    }),
                    iconColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.hovered)) {
                        return Colors.red;
                      }
                      return Colors.grey[400];
                    }),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // --- TAGS ---
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTag("Type: ${question.type}", Colors.blue.shade50,
                    Colors.blue.shade700),
                _buildTag("Diff: ${question.difficulty}", Colors.orange.shade50,
                    Colors.orange.shade700),
                _buildTag("Ans: ${question.correctAnswer}",
                    Colors.green.shade50, Colors.green.shade700),
              ],
            ),
            const SizedBox(height: 16),

            // --- STATISTIK ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.check_circle,
                    color: Colors.green,
                    label: "Benar",
                    count: question.correctCount,
                  ),
                  Container(
                      width: 1, height: 24, color: Colors.grey.shade300),
                  _buildStatItem(
                    icon: Icons.cancel,
                    color: Colors.red,
                    label: "Salah",
                    count: question.incorrectCount,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Question?"),
        content: const Text("This action cannot be undone. Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Tutup dialog
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx); // Tutup dialog dulu
              
              // Panggil Event Delete di Bloc
              context.read<AdminQuizDetailBloc>().add(
                DeleteQuestionEvent(
                  questionId: question.id, 
                  quizId: quizId
                )
              );
              
              // Opsional: Tampilkan Snackbar loading/sukses
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Deleting question..."), duration: Duration(seconds: 1)),
              );
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String label,
    required int count,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(count.toString(),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            Text(label,
                style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}