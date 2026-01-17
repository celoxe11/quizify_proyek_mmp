import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/question_accuracy_model.dart';

class AccuracyListItem extends StatelessWidget {
  final QuestionAccuracy result;
  final int index;

  const AccuracyListItem({
    super.key,
    required this.result,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final accuracyValue = result.accuracy;
    final correctAnswers = result.correctAnswers;
    final totalAnswered = result.totalAnswered;
    final incorrectAnswers = result.incorrectAnswers;
    final meanValue = result.mean;

    final accuracyColor = accuracyValue >= 80
        ? Colors.green
        : (accuracyValue >= 60 ? Colors.orange : Colors.red);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.darkAzure,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  result.question.isNotEmpty
                      ? result.question
                      : 'Question ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accuracyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accuracyColor, width: 1.5),
                ),
                child: Text(
                  '${accuracyValue.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: accuracyColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              _buildStatRow(
                Icons.check_circle,
                'Correct Answers',
                '$correctAnswers',
                Colors.green,
              ),
              const SizedBox(height: 8),
              _buildStatRow(
                Icons.cancel,
                'Wrong Answers',
                '$incorrectAnswers',
                Colors.red,
              ),
              const SizedBox(height: 8),
              _buildStatRow(
                Icons.people,
                'Total Answered',
                '$totalAnswered',
                AppColors.darkAzure,
              ),
              const SizedBox(height: 8),
              _buildStatRow(
                Icons.calculate,
                'Mean Score',
                meanValue.toStringAsFixed(2),
                Colors.blueGrey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textDark.withOpacity(0.7),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
