import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';

class StudentListItem extends StatelessWidget {
  final Map<String, dynamic> student;
  final int index;
  final String quizId;
  final String quizTitle;

  const StudentListItem({
    super.key,
    required this.student,
    required this.index,
    required this.quizId,
    required this.quizTitle,
  });

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

  @override
  Widget build(BuildContext context) {
    final score = student['score'] as int;
    final scoreColor = score >= 80
        ? Colors.green
        : (score >= 60 ? Colors.orange : Colors.red);

    return InkWell(
      onTap: () {
        print("Student Id: ${student['student_id']}");

        // Navigate to student answers page
        context.push(
          '/admin/quiz-detail/answers',
          extra: {
            'student_id': student['student_id'] ?? '',
            'student_name': student['student'] ?? 'Unknown',
            'quiz_id': quizId,
            'quiz_title': quizTitle,
          },
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
                color: AppColors.darkAzure.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.darkAzure,
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
                  Row(
                    children: [
                      Text(
                        'Started: ${_formatDateTime(student['started_at'])}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textDark.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Completed: ${_formatDateTime(student['ended_at'])}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textDark.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Score Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: scoreColor, width: 1.5),
              ),
              child: Text(
                '$score%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Arrow indicator
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.darkAzure,
            ),
          ],
        ),
      ),
    );
  }
}
