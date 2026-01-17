import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/quiz_detail/quiz_detail_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/quiz_detail/quiz_detail_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/quiz_detail/quiz_detail_state.dart';
import 'package:quizify_proyek_mmp/presentation/widgets/teacher/quiz_detail/question_list_item.dart';

class OtherTeacherQuizDetailPage extends StatelessWidget {
  static const double _kMobileBreakpoint = 600;
  static const double _kDesktopMaxWidth = 900;

  const OtherTeacherQuizDetailPage({super.key, required this.quiz});

  final QuizModel quiz;

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

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= _kMobileBreakpoint;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = isDesktop ? _kDesktopMaxWidth : double.infinity;

    return Scaffold(
      backgroundColor: AppColors.dirtyCyan,
      appBar: AppBar(
        backgroundColor: AppColors.darkAzure,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Quiz Preview',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<QuizDetailBloc, QuizDetailState>(
        builder: (context, state) {
          if (state is QuizDetailLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.darkAzure),
            );
          }

          if (state is QuizDetailError) {
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
                    'Failed to load quiz details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<QuizDetailBloc>().add(
                        LoadQuizDetailEvent(quizId: quiz.id),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkAzure,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is QuizDetailLoaded) {
            return SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  width: screenWidth,
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 16.0 : 12.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, state, isDesktop),
                      const SizedBox(height: 24.0),

                      // Questions Section
                      const Text(
                        'Questions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkAzure,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (state.questions.isEmpty)
                        const Center(child: Text('No questions available'))
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.questions.length,
                          itemBuilder: (context, index) {
                            return QuestionListItem(
                              question: state.questions[index],
                              index: index,
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(color: AppColors.darkAzure),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    QuizDetailLoaded state,
    bool isDesktop,
  ) {
    final quizCode =
        state.quiz.quizCode ??
        (state.quiz.id.length >= 8
            ? state.quiz.id.substring(0, 8).toUpperCase()
            : state.quiz.id.toUpperCase());

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
          // Title and Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.quiz.title,
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
                        color: _getStatusColor(
                          state.quiz.status,
                        ).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(state.quiz.status),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            state.quiz.status.toLowerCase() == 'public'
                                ? Icons.public
                                : Icons.lock,
                            size: 16,
                            color: _getStatusColor(state.quiz.status),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getStatusLabel(state.quiz.status),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(state.quiz.status),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Description
          if (state.quiz.description != null &&
              state.quiz.description!.isNotEmpty) ...[
            const SizedBox(height: 20.0),
            Text(
              state.quiz.description!,
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

          // Details Grid
          if (isDesktop)
            _buildDesktopDetailsGrid(context, state, quizCode)
          else
            _buildMobileDetailsColumn(context, state, quizCode),
        ],
      ),
    );
  }

  Widget _buildDesktopDetailsGrid(
    BuildContext context,
    QuizDetailLoaded state,
    String quizCode,
  ) {
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
            value: state.quiz.category ?? 'Uncategorized',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _QuizDetailItem(
            icon: Icons.quiz,
            label: 'Questions',
            value: '${state.questions.length}',
          ),
        ),
      ],
    );
  }

  Widget _buildMobileDetailsColumn(
    BuildContext context,
    QuizDetailLoaded state,
    String quizCode,
  ) {
    return Column(
      children: [
        _QuizDetailItem(
          icon: Icons.qr_code,
          label: 'Quiz Code',
          value: quizCode,
          onCopy: (context) => _copyCodeToClipboard(context, quizCode),
        ),
        const SizedBox(height: 16),
        _QuizDetailItem(
          icon: Icons.category,
          label: 'Category',
          value: state.quiz.category ?? 'Uncategorized',
        ),
        const SizedBox(height: 16),
        _QuizDetailItem(
          icon: Icons.quiz,
          label: 'Questions',
          value: '${state.questions.length}',
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
