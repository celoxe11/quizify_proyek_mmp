import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/history_detail_model.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/history_detail/history_detail_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/history_detail/history_detail_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/history_detail/history_detail_state.dart';
import 'package:quizify_proyek_mmp/presentation/widgets/gemini_configuration_modal.dart';

class QuestionReviewCard extends StatelessWidget {
  final int index;
  final QuestionReview question;

  const QuestionReviewCard({
    super.key,
    required this.index,
    required this.question,
  });

  void _showGeminiEvaluation(BuildContext context) {
    if (question.submissionAnswerId == null ||
        question.submissionAnswerId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No submission ID available for this question'),
        ),
      );
      return;
    }

    // Capture the bloc before opening dialog
    final bloc = context.read<HistoryDetailBloc>();

    // Show configuration modal
    showDialog(
      context: context,
      builder: (context) => GeminiConfigurationModal(
        initialQuestionType: question.type,
        onConfirm: (language, detailedFeedback, questionType) {
          bloc.add(
            LoadGeminiEvaluation(
              question.submissionAnswerId!,
              language: language,
              detailedFeedback: detailedFeedback,
              questionType: questionType,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Soal
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: question.isCorrect
                      ? Colors.green
                      : Colors.red,
                  child: Icon(
                    question.isCorrect ? Icons.check : Icons.close,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Question $index",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                // Badge Difficulty
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    question.difficulty.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              question.questionText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // OPTIONS LIST
            ...question.options.map((option) {
              return _buildOptionItem(option);
            }),

            // ASK GEMINI BUTTON
            if (question.submissionAnswerId != null &&
                question.submissionAnswerId!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: BlocBuilder<HistoryDetailBloc, HistoryDetailState>(
                  builder: (context, state) {
                    final isLoading =
                        state is HistoryDetailGeminiEvaluationLoading;

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading
                            ? null
                            : () => _showGeminiEvaluation(context),
                        icon: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.auto_awesome, size: 18),
                        label: Text(
                          isLoading
                              ? 'Loading...'
                              : 'Ask Gemini for Evaluation',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkAzure,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(String optionText) {
    bool isSelected = optionText == question.userAnswer;
    bool isCorrectAnswer = optionText == question.correctAnswer;

    Color bgColor = Colors.white;
    Color borderColor = Colors.grey.shade300;
    IconData? icon;
    Color iconColor = Colors.transparent;

    // LOGIKA WARNA
    if (isCorrectAnswer) {
      // Jawaban Benar (Selalu Hijau)
      bgColor = Colors.green.shade50;
      borderColor = Colors.green;
      icon = Icons.check_circle;
      iconColor = Colors.green;
    } else if (isSelected && !question.isCorrect) {
      // Jawaban User Salah (Merah)
      bgColor = Colors.red.shade50;
      borderColor = Colors.red;
      icon = Icons.cancel;
      iconColor = Colors.red;
    } else if (isSelected && question.isCorrect) {
      // User Benar (Sudah tercover di if pertama, tapi untuk safety)
      bgColor = Colors.green.shade50;
      borderColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              optionText,
              style: TextStyle(
                fontWeight: isSelected || isCorrectAnswer
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ),
          if (icon != null) Icon(icon, color: iconColor, size: 20),
        ],
      ),
    );
  }
}
