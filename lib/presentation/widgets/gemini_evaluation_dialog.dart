import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';

class GeminiEvaluationDialog extends StatelessWidget {
  final Map<String, dynamic> evaluation;

  const GeminiEvaluationDialog({super.key, required this.evaluation});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.darkAzure,
                  AppColors.darkAzure.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Gemini Evaluation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Score Badge
            if (evaluation['is_correct'] != null)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: (evaluation['is_correct'] as bool)
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (evaluation['is_correct'] as bool)
                          ? Colors.green
                          : Colors.red,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        (evaluation['is_correct'] as bool)
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: (evaluation['is_correct'] as bool)
                            ? Colors.green
                            : Colors.red,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (evaluation['is_correct'] as bool)
                                ? 'Correct!'
                                : 'Incorrect',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: (evaluation['is_correct'] as bool)
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          Text(
                            'Score: ${evaluation['score'] ?? 0}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Feedback
            if (evaluation['feedback'] != null) ...[
              _buildEvaluationSection(
                'Feedback',
                evaluation['feedback'].toString(),
                Icons.feedback,
                AppColors.darkAzure,
              ),
              const SizedBox(height: 16),
            ],

            // Analysis - Correctness
            if (evaluation['analysis'] != null &&
                evaluation['analysis']['correctness'] != null) ...[
              _buildEvaluationSection(
                'Analysis',
                evaluation['analysis']['correctness'].toString(),
                Icons.analytics,
                Colors.blue,
              ),
              const SizedBox(height: 16),
            ],

            // Key Points Missed
            if (evaluation['analysis'] != null &&
                evaluation['analysis']['key_points_missed'] != null &&
                (evaluation['analysis']['key_points_missed'] as List)
                    .isNotEmpty) ...[
              _buildListSection(
                'Key Points Missed',
                evaluation['analysis']['key_points_missed'] as List,
                Icons.error_outline,
                Colors.orange,
              ),
              const SizedBox(height: 16),
            ],

            // Strengths
            if (evaluation['analysis'] != null &&
                evaluation['analysis']['strengths'] != null &&
                (evaluation['analysis']['strengths'] as List).isNotEmpty) ...[
              _buildListSection(
                'Strengths',
                evaluation['analysis']['strengths'] as List,
                Icons.thumb_up,
                Colors.green,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildEvaluationSection(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildListSection(
    String title,
    List items,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(
                      point.toString(),
                      style: const TextStyle(fontSize: 13, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
