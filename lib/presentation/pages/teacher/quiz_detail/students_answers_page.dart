import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_session_model.dart';
import 'package:quizify_proyek_mmp/data/models/submission_answer_model.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/student_answers/student_answers_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/student_answers/student_answers_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/student_answers/student_answers_state.dart';

class TeacherStudentAnswersPage extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String quizId;
  final String quizTitle;

  const TeacherStudentAnswersPage({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.quizId,
    required this.quizTitle,
  });

  @override
  State<TeacherStudentAnswersPage> createState() =>
      _TeacherStudentAnswersPageState();
}

class _TeacherStudentAnswersPageState extends State<TeacherStudentAnswersPage> {
  @override
  void initState() {
    super.initState();
    print("Loading answers for Student ID: ${widget.studentId}");

    // Load student answers when page opens
    context.read<StudentAnswersBloc>().add(
      LoadStudentAnswersEvent(
        studentId: widget.studentId,
        quizId: widget.quizId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dirtyCyan,
      appBar: AppBar(
        backgroundColor: AppColors.darkAzure,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.studentName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.quizTitle,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
      body: BlocBuilder<StudentAnswersBloc, StudentAnswersState>(
        builder: (context, state) {
          if (state is StudentAnswersLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.darkAzure),
            );
          }

          if (state is StudentAnswersError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load answers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textDark.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<StudentAnswersBloc>().add(
                        LoadStudentAnswersEvent(
                          studentId: widget.studentId,
                          quizId: widget.quizId,
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkAzure,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is StudentAnswersLoaded) {
            return _buildAnswersList(state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAnswersList(StudentAnswersLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Session Overview
          _buildSessionOverview(state.session),

          const SizedBox(height: 24),

          // Answers List
          _buildAnswersSection(state),
        ],
      ),
    );
  }

  Widget _buildSessionOverview(QuizSessionModel session) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quiz Session',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkAzure,
            ),
          ),
          const SizedBox(height: 16),
          _buildSessionItem(session),
        ],
      ),
    );
  }

  Widget _buildSessionItem(QuizSessionModel session) {
    final startedAt = session.startedAt;
    final endedAt = session.endedAt;
    final score = session.score;
    final status = session.status;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightCyan.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkAzure.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(status ?? 'completed'),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status?.toUpperCase() ?? 'COMPLETED',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              if (score != null)
                Text(
                  'Score: $score',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkAzure,
                  ),
                ),
            ],
          ),
          if (startedAt != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.play_arrow, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Started: ${_formatDateTime(startedAt.toIso8601String())}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ],
          if (endedAt != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.stop, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Ended: ${_formatDateTime(endedAt.toIso8601String())}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswersSection(StudentAnswersLoaded state) {
    if (state.answers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.question_answer_outlined,
                size: 64,
                color: AppColors.darkAzure.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No answers submitted',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Submitted Answers',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkAzure,
                    ),
                  ),
                  Text(
                    '${state.answers.length} answers',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textDark.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...state.answers.asMap().entries.map((entry) {
                final index = entry.key;
                final answer = entry.value;
                return _buildAnswerItem(answer, index + 1);
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerItem(SubmissionAnswerModel answer, int questionNumber) {
    final question = answer.question;
    final selectedAnswer = answer.selectedAnswer;
    final isCorrect = answer.isCorrect;

    // Fallback if question data is missing
    if (question == null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.lightCyan.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            'Question data unavailable',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textDark.withOpacity(0.5),
            ),
          ),
        ),
      );
    }

    final correctAnswer = question.correctAnswer;
    final options = question.options;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isCorrect ?? false)
              ? Colors.green.withOpacity(0.4)
              : Colors.red.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with question number and status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isCorrect ?? false)
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.darkAzure,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Q$questionNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(question.difficulty ?? 'easy'),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    (question.difficulty ?? 'easy').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  isCorrect ?? false
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  color: isCorrect ?? false ? Colors.green : Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  isCorrect ?? false ? 'Correct' : 'Wrong',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ?? false ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),

          // Question text
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.questionText ?? 'No question text',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // Options list
                ...options.asMap().entries.map((entry) {
                  final optionIndex = entry.key;
                  final option = entry.value;
                  final isSelected = option == selectedAnswer;
                  final isCorrectOption = option == correctAnswer;

                  return _buildOptionItem(
                    option: option,
                    optionLabel: String.fromCharCode(65 + optionIndex), // A, B, C, D
                    isSelected: isSelected,
                    isCorrectOption: isCorrectOption,
                    showCorrect: !(isCorrect ?? false), // Show correct answer if student was wrong
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required String option,
    required String optionLabel,
    required bool isSelected,
    required bool isCorrectOption,
    required bool showCorrect,
  }) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? icon;
    Color? iconColor;

    if (isSelected && isCorrectOption) {
      // Student selected correct answer
      backgroundColor = Colors.green.withOpacity(0.15);
      borderColor = Colors.green;
      textColor = Colors.green.shade800;
      icon = Icons.check_circle;
      iconColor = Colors.green;
    } else if (isSelected && !isCorrectOption) {
      // Student selected wrong answer
      backgroundColor = Colors.red.withOpacity(0.15);
      borderColor = Colors.red;
      textColor = Colors.red.shade800;
      icon = Icons.cancel;
      iconColor = Colors.red;
    } else if (!isSelected && isCorrectOption && showCorrect) {
      // This is the correct answer (student didn't select it)
      backgroundColor = Colors.green.withOpacity(0.08);
      borderColor = Colors.green.withOpacity(0.5);
      textColor = Colors.green.shade700;
      icon = Icons.check_circle_outline;
      iconColor = Colors.green;
    } else {
      // Other options
      backgroundColor = Colors.grey.withOpacity(0.05);
      borderColor = Colors.grey.withOpacity(0.2);
      textColor = AppColors.textDark.withOpacity(0.7);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isSelected || (isCorrectOption && showCorrect)
                  ? borderColor.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                optionLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              option,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: textColor,
              ),
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 8),
            Icon(icon, color: iconColor, size: 20),
          ],
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return AppColors.darkAzure;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      case 'abandoned':
        return Colors.red;
      default:
        return AppColors.darkAzure;
    }
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
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
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year} at $hour:$minute';
    } catch (e) {
      return dateTimeStr;
    }
  }
}
