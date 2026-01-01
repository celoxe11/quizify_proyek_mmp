import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';

class QuizInfoCard extends StatelessWidget {
  final QuizModel quiz;
  final int questionsCount;
  final bool isDesktop;
  final List<QuestionModel> questions;

  const QuizInfoCard({
    super.key,
    required this.quiz,
    required this.questionsCount,
    required this.isDesktop,
    required this.questions,
  });

  void _copyCodeToClipboard(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Quiz code copied to clipboard!'),
        backgroundColor: AppColors.darkAzure,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'public':
        return 'Public';
      case 'private':
        return 'Private';
      case 'draft':
        return 'Draft';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'public':
        return Colors.green;
      case 'private':
        return Colors.orange;
      case 'draft':
        return Colors.grey;
      default:
        return AppColors.darkAzure;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final quizCode = quiz.quizCode ??
        (quiz.id.length >= 8
            ? quiz.id.substring(0, 8).toUpperCase()
            : quiz.id.toUpperCase());

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Status Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkAzure,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(quiz.status).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(quiz.status),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            quiz.status.toLowerCase() == 'public'
                                ? Icons.public
                                : Icons.lock,
                            size: 16,
                            color: _getStatusColor(quiz.status),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getStatusLabel(quiz.status),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(quiz.status),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Edit Button in Header
              ElevatedButton.icon(
                onPressed: () {
                  context.go(
                    '/admin/quiz-detail/edit',
                    extra: {'quiz': quiz, 'questions': questions},
                  );
                },
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkAzure,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),

          // Description
          if (quiz.description != null && quiz.description!.isNotEmpty) ...[
            const SizedBox(height: 20.0),
            Text(
              quiz.description!,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textDark.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ],

          const SizedBox(height: 20.0),
          const Divider(height: 1, color: AppColors.lightCyan),
          const SizedBox(height: 20.0),

          // Quiz Details Grid
          if (isDesktop)
            _buildDesktopDetailsGrid(quizCode)
          else
            _buildMobileDetailsColumn(quizCode),

          // Created/Updated Date
          if (quiz.createdAt != null) ...[
            const SizedBox(height: 20.0),
            const Divider(height: 1, color: AppColors.lightCyan),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textDark.withOpacity(0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  'Created: ${_formatDate(quiz.createdAt!)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textDark.withOpacity(0.5),
                  ),
                ),
                if (quiz.updatedAt != null) ...[
                  const SizedBox(width: 16),
                  Text(
                    '•',
                    style: TextStyle(
                      color: AppColors.textDark.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Updated: ${_formatDate(quiz.updatedAt!)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textDark.withOpacity(0.5),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDesktopDetailsGrid(String quizCode) {
    return Row(
      children: [
        Expanded(
          child: _QuizDetailItem(
            icon: Icons.qr_code,
            label: 'Quiz Code',
            value: quizCode,
            onCopy: (context) => _copyCodeToClipboard(context, quizCode),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _QuizDetailItem(
            icon: Icons.category,
            label: 'Category',
            value: quiz.category ?? 'Uncategorized',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _QuizDetailItem(
            icon: Icons.quiz,
            label: 'Questions',
            value: '$questionsCount',
          ),
        ),
      ],
    );
  }

  Widget _buildMobileDetailsColumn(String quizCode) {
    return Column(
      children: [
        _QuizDetailItem(
          icon: Icons.qr_code,
          label: 'Quiz Code',
          value: quizCode,
          onCopy: (context) => _copyCodeToClipboard(context, quizCode),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuizDetailItem(
                icon: Icons.category,
                label: 'Category',
                value: quiz.category ?? 'Uncategorized',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _QuizDetailItem(
                icon: Icons.quiz,
                label: 'Questions',
                value: '$questionsCount',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuizDetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final void Function(BuildContext)? onCopy;

  const _QuizDetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightCyan.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.darkAzure.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.darkAzure),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textDark.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkAzure,
                  ),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              icon: const Icon(Icons.copy, size: 20),
              onPressed: () => onCopy!(context),
              color: AppColors.darkAzure,
              tooltip: 'Copy',
            ),
        ],
      ),
    );
  }
}
