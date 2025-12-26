import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';

class StudentListItem extends StatelessWidget {
  final Map<String, dynamic> student;
  final int index;

  const StudentListItem({
    super.key,
    required this.student,
    required this.index,
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
                  student['username'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Completed: ${_formatDateTime(student['completed_at'])}',
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
        ],
      ),
    );
  }
}
