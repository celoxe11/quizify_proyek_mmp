import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import "package:quizify_proyek_mmp/core/constants/app_colors.dart";
import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/edit_quiz/edit_quiz_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/widgets/question_card.dart';

/// Edit Quiz Page - Allows teachers to edit an existing quiz.
///
/// Uses BLoC pattern for state management:
/// - [EditQuizBloc] handles all business logic
/// - [EditQuizState] contains the current state
/// - [EditQuizEvent] triggers state changes
///
/// The page receives quiz and questions from the route and initializes
/// the BLoC with this data via [InitializeEditQuizEvent].
class TeacherEditQuizPage extends StatelessWidget {
  const TeacherEditQuizPage({
    super.key,
    required this.quiz,
    required this.questions,
  });

  /// The quiz to be edited. Used as initial data.
  final QuizModel quiz;

  /// The initial questions for this quiz.
  final List<QuestionModel> questions;

  static const double _kDesktopMaxWidth = 900;
  static const double _kMobileBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= _kMobileBreakpoint;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = isDesktop ? _kDesktopMaxWidth : double.infinity;

    return BlocConsumer<EditQuizBloc, EditQuizState>(
      listener: (context, state) {
        // Handle side effects
        if (state is EditQuizSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Quiz updated successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          // Navigate back to quiz detail
          context.pop();
        } else if (state is EditQuizError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: state is! EditQuizReady || !state.hasChanges,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final shouldPop = await _showUnsavedChangesDialog(context);
            if (shouldPop && context.mounted) {
              context.pop();
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.dirtyCyan,
            appBar: _buildAppBar(context, state),
            body: _buildBody(context, state, isDesktop, screenWidth, maxWidth),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, EditQuizState state) {
    final hasChanges = state is EditQuizReady && state.hasChanges;
    final isSaving = state is EditQuizReady && state.isSaving;

    return AppBar(
      backgroundColor: AppColors.darkAzure,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () async {
          if (hasChanges) {
            final shouldPop = await _showUnsavedChangesDialog(context);
            if (shouldPop && context.mounted) {
              context.pop();
            }
          } else {
            context.pop();
          }
        },
      ),
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Edit Quiz',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (hasChanges)
            const Text(
              'Unsaved changes',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
      actions: [
        // Save button in app bar for quick access
        if (hasChanges)
          TextButton.icon(
            onPressed: isSaving
                ? null
                : () => context.read<EditQuizBloc>().add(SaveQuizEvent()),
            icon: isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save, color: Colors.white),
            label: Text(
              isSaving ? 'Saving...' : 'Save',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    EditQuizState state,
    bool isDesktop,
    double screenWidth,
    double maxWidth,
  ) {
    if (state is EditQuizInitial || state is EditQuizLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.darkAzure),
      );
    }

    if (state is! EditQuizReady) {
      return const Center(child: Text('Something went wrong'));
    }

    return Container(
      decoration: const BoxDecoration(color: AppColors.dirtyCyan),
      child: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            width: screenWidth,
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 16.0 : 8.0,
              vertical: 16.0,
            ),
            child: Column(
              children: [
                // Quiz Header Card
                _buildQuizHeaderCard(context, state, isDesktop),

                const SizedBox(height: 24.0),

                // Add Question Button
                _buildAddQuestionButton(context),

                const SizedBox(height: 16.0),

                // Questions List
                _buildQuestionsList(context, state),

                const SizedBox(height: 24.0),

                // Save Button
                _buildSaveButton(context, state),

                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizHeaderCard(
    BuildContext context,
    EditQuizReady state,
    bool isDesktop,
  ) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quiz Title and Public Switch
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: state.title,
                  decoration: const InputDecoration(
                    hintText: 'Quiz Title',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkAzure,
                  ),
                  onChanged: (value) {
                    context.read<EditQuizBloc>().add(TitleChangedEvent(value));
                  },
                ),
              ),
              if (isDesktop) _buildPublicSwitch(context, state),
            ],
          ),

          // If mobile, show switch on separate line
          if (!isDesktop) ...[
            const SizedBox(height: 12),
            _buildPublicSwitch(context, state),
          ],

          const SizedBox(height: 16.0),

          // Quiz Description
          TextFormField(
            initialValue: state.description,
            decoration: const InputDecoration(
              hintText: 'Quiz Description',
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 16, color: AppColors.darkAzure),
            maxLines: null,
            onChanged: (value) {
              context.read<EditQuizBloc>().add(DescriptionChangedEvent(value));
            },
          ),

          const SizedBox(height: 20.0),
          const Divider(),
          const SizedBox(height: 16.0),

          // Category Field
          Row(
            children: [
              const Icon(Icons.category, color: AppColors.darkAzure, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: state.category,
                  decoration: const InputDecoration(
                    hintText: 'Category (e.g., Science, Math, History)',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.darkAzure,
                  ),
                  onChanged: (value) {
                    context.read<EditQuizBloc>().add(
                      CategoryChangedEvent(value),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16.0),
          const Divider(),
          const SizedBox(height: 16.0),

          // Quiz Code Section (Read-only)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.qr_code, color: AppColors.darkAzure, size: 20),
                  SizedBox(width: 12),
                  Text(
                    "Quiz Code:",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkAzure,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.lightCyan.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      state.code,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkAzure,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () => _copyCodeToClipboard(context, state.code),
                    tooltip: 'Copy Code',
                    color: AppColors.darkAzure,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPublicSwitch(BuildContext context, EditQuizReady state) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          state.isPublic ? Icons.public : Icons.lock,
          size: 18,
          color: state.isPublic ? Colors.green : Colors.orange,
        ),
        const SizedBox(width: 8),
        Text(
          state.isPublic ? "Public" : "Private",
          style: TextStyle(
            color: state.isPublic ? Colors.green : Colors.orange,
            fontWeight: FontWeight.w500,
          ),
        ),
        Switch(
          value: state.isPublic,
          onChanged: (value) {
            context.read<EditQuizBloc>().add(TogglePublicEvent(value));
          },
          activeColor: Colors.green,
          inactiveThumbColor: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildAddQuestionButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton.icon(
        onPressed: () {
          context.read<EditQuizBloc>().add(AddQuestionEvent());
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Question"),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkAzure,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionsList(BuildContext context, EditQuizReady state) {
    if (state.questions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.pureWhite.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.lightCyan,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.quiz_outlined,
                size: 48,
                color: AppColors.darkAzure.withOpacity(0.3),
              ),
              const SizedBox(height: 12),
              Text(
                'No questions yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Click "Add Question" to add questions to this quiz',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textDark.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.questions.length,
      itemBuilder: (context, index) {
        return QuestionCard(
          index: index,
          question: state.questions[index],
          onUpdate: (updatedQuestion) {
            context.read<EditQuizBloc>().add(
              UpdateQuestionEvent(index: index, question: updatedQuestion),
            );
          },
          onRemove: () {
            context.read<EditQuizBloc>().add(RemoveQuestionEvent(index));
          },
        );
      },
    );
  }

  Widget _buildSaveButton(BuildContext context, EditQuizReady state) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: state.isSaving
            ? null
            : () => context.read<EditQuizBloc>().add(SaveQuizEvent()),
        style: ElevatedButton.styleFrom(
          backgroundColor: state.hasChanges ? AppColors.darkAzure : Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          disabledBackgroundColor: Colors.grey.shade400,
        ),
        child: state.isSaving
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Saving...",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            : Text(
                state.hasChanges ? "Save Changes" : "No Changes",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  // ============================================================
  // Utility Methods
  // ============================================================

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

  Future<bool> _showUnsavedChangesDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Unsaved Changes'),
          ],
        ),
        content: const Text(
          'You have unsaved changes. Are you sure you want to leave without saving?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
