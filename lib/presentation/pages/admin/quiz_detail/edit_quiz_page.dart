import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import "package:quizify_proyek_mmp/core/constants/app_colors.dart";
import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';
import 'package:quizify_proyek_mmp/data/repositories/auth_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/edit_quiz/admin_edit_quiz_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/generate_question/admin_generate_question_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/generate_question/admin_generate_question_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/generate_question/admin_generate_question_state.dart';
import 'package:quizify_proyek_mmp/presentation/widgets/teacher/create_quiz/ai_generation_dialog.dart';
import 'package:quizify_proyek_mmp/presentation/widgets/teacher/create_quiz/question_card.dart';

class AdminEditQuizPage extends StatefulWidget {
  const AdminEditQuizPage({
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
  State<AdminEditQuizPage> createState() => _AdminEditQuizPageState();
}

class _AdminEditQuizPageState extends State<AdminEditQuizPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _codeController;
  late List<QuestionModel> _questions;
  bool _isPublic = true;
  bool _hasChanges = false;
  bool _isPremiumUser = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.quiz.title);
    _descriptionController = TextEditingController(
      text: widget.quiz.description ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.quiz.category ?? '',
    );
    _codeController = TextEditingController(text: widget.quiz.quizCode);
    _questions = List.from(widget.questions);
    _isPublic = widget.quiz.status.toLowerCase() == 'public';

    // Add listeners to track changes
    _titleController.addListener(_onTextChanged);
    _descriptionController.addListener(_onTextChanged);
    _categoryController.addListener(_onTextChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPremiumStatus());
  }

  Future<void> _loadPremiumStatus() async {
    final authRepo = context.read<AuthenticationRepositoryImpl>();
    try {
      final premium = authRepo.isPremiumUser();
      if (mounted) setState(() => _isPremiumUser = premium);
    } catch (e) {
      // handle error if needed
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  void _onPublicToggled(bool value) {
    setState(() {
      _isPublic = value;
      _hasChanges = true;
    });
  }

  void _addQuestion() {
    setState(() {
      _questions.add(
        QuestionModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: 'multiple',
          difficulty: 'easy',
          questionText: '',
          correctAnswer: '',
          options: ['', '', '', ''],
        ),
      );
      _hasChanges = true;
    });
  }

  void _updateQuestion(int index, QuestionModel updatedQuestion) {
    setState(() {
      if (index >= 0 && index < _questions.length) {
        _questions[index] = updatedQuestion;
        _hasChanges = true;
      }
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.of(context).size.width >=
        AdminEditQuizPage._kMobileBreakpoint;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = isDesktop
        ? AdminEditQuizPage._kDesktopMaxWidth
        : double.infinity;

    return MultiBlocListener(
      listeners: [
        BlocListener<AdminEditQuizBloc, AdminEditQuizState>(
          listener: (context, state) {
            // Handle side effects
            if (state is AdminEditQuizSaved) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Quiz updated successfully!'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );

              // Navigate back to quiz detail page after a short delay
              Future.delayed(const Duration(milliseconds: 500), () {
                if (context.mounted) {
                  context.go('/admin/quiz-detail', extra: state.updatedQuiz);
                }
              });
            } else if (state is AdminEditQuizError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
        ),
        BlocListener<AdminGenerateQuestionBloc, AdminGenerateQuestionState>(
          listener: (context, state) {
            if (state is AdminGenerateQuestionLoading) {
              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Dialog(
                  backgroundColor: Colors.transparent,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.deepPurple),
                        SizedBox(height: 16),
                        Text(
                          'Generating question with AI...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else if (state is AdminGenerateQuestionSuccess) {
              // Hide loading dialog
              Navigator.of(context, rootNavigator: true).pop();

              // Add generated question to list
              setState(() {
                _questions.add(state.question);
                _hasChanges = true;
              });

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Question generated successfully!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            } else if (state is AdminGenerateQuestionFailure) {
              // Hide loading dialog
              Navigator.of(context, rootNavigator: true).pop();

              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to generate question: ${state.error}'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          },
        ),
      ],
      child: BlocConsumer<AdminEditQuizBloc, AdminEditQuizState>(
        listener: (context, state) {
          // This listener is now redundant but kept for backwards compatibility
          // The actual logic has been moved to the MultiBlocListener above
        },
        builder: (context, state) {
          return PopScope(
            canPop: !_hasChanges,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;
              final shouldPop = await _showUnsavedChangesDialog(context);
              if (shouldPop && context.mounted) {
                context.pop();
              }
            },
            child: Scaffold(
              backgroundColor: AppColors.dirtyCyan,
              floatingActionButton: FloatingActionButton.extended(
                onPressed: _addQuestion,
                backgroundColor: AppColors.darkAzure,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Add Question",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              appBar: _buildAppBar(context, state),
              body: _buildBody(
                context,
                state,
                isDesktop,
                screenWidth,
                maxWidth,
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AdminEditQuizState state,
  ) {
    final isSaving = state is AdminEditQuizReady && state.isSaving;

    return AppBar(
      backgroundColor: AppColors.darkAzure,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () async {
          if (_hasChanges) {
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
          if (_hasChanges)
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
        if (_hasChanges)
          TextButton.icon(
            onPressed: isSaving
                ? null
                : () => context.read<AdminEditQuizBloc>().add(
                    AdminSaveQuizEvent(
                      quizId: widget.quiz.id,
                      title: _titleController.text.trim(),
                      description: _descriptionController.text.trim().isEmpty
                          ? null
                          : _descriptionController.text.trim(),
                      category: _categoryController.text.trim().isEmpty
                          ? null
                          : _categoryController.text.trim(),
                      status: _isPublic ? 'public' : 'private',
                      quizCode: _codeController.text,
                      questions: _questions,
                    ),
                  ),
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
    AdminEditQuizState state,
    bool isDesktop,
    double screenWidth,
    double maxWidth,
  ) {
    final isSaving = state is AdminEditQuizReady && state.isSaving;

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
                _buildQuizHeaderCard(context, isDesktop),

                const SizedBox(height: 24.0),

                // Add Question Buttons Row
                Row(
                  children: [
                    // Add Question Button
                    ElevatedButton.icon(
                      onPressed: _addQuestion,
                      icon: const Icon(Icons.add),
                      label: const Text("Add Question"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkAzure,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Generate with AI Button (Premium)
                    if (_isPremiumUser) ...{
                      ElevatedButton.icon(
                        onPressed: () {
                          _showAIGenerationDialog(context);
                        },
                        icon: const Icon(Icons.auto_awesome, size: 20),
                        label: const Text("Generate with AI"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    },
                  ],
                ),

                const SizedBox(height: 16.0),

                // Questions List
                _buildQuestionsList(context),

                const SizedBox(height: 24.0),

                // Save Button
                _buildSaveButton(context, isSaving),

                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizHeaderCard(BuildContext context, bool isDesktop) {
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
                child: TextField(
                  controller: _titleController,
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
                ),
              ),
              if (isDesktop) _buildPublicSwitch(context),
            ],
          ),

          // If mobile, show switch on separate line
          if (!isDesktop) ...[
            const SizedBox(height: 12),
            _buildPublicSwitch(context),
          ],

          const SizedBox(height: 16.0),

          // Quiz Description
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              hintText: 'Quiz Description',
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 16, color: AppColors.darkAzure),
            maxLines: null,
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
                child: TextField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    hintText: 'Category (e.g., Science, Math, History)',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.darkAzure,
                  ),
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
                      _codeController.text,
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
                    onPressed: () =>
                        _copyCodeToClipboard(context, _codeController.text),
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

  Widget _buildPublicSwitch(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _isPublic ? Icons.public : Icons.lock,
          size: 18,
          color: _isPublic ? Colors.green : Colors.orange,
        ),
        const SizedBox(width: 8),
        Text(
          _isPublic ? "Public" : "Private",
          style: TextStyle(
            color: _isPublic ? Colors.green : Colors.orange,
            fontWeight: FontWeight.w500,
          ),
        ),
        Switch(
          value: _isPublic,
          onChanged: _onPublicToggled,
          activeColor: Colors.green,
          inactiveThumbColor: Colors.orange,
        ),
      ],
    );
  }

  void _showAIGenerationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AIGenerationDialog(
        onGenerate: (params) {
          Navigator.pop(dialogContext);
          // Dispatch GenerateQuestionWithAIEvent
          context.read<AdminGenerateQuestionBloc>().add(
            AdminGenerateQuestionWithAIEvent(
              type: params["type"],
              difficulty: params["difficulty"],
              category: params["category"],
              topic: params["topic"],
              language: params["language"],
              context: params["context"],
              ageGroup: params["age_group"],
              avoidTopics: params["avoid_topics"],
              includeExplanation: params["include_explanation"],
              questionStyle: params["question_style"],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestionsList(BuildContext context) {
    if (_questions.isEmpty) {
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
      itemCount: _questions.length,
      itemBuilder: (context, index) {
        return QuestionCard(
          index: index,
          question: _questions[index],
          onUpdate: (updatedQuestion) =>
              _updateQuestion(index, updatedQuestion),
          onRemove: () => _removeQuestion(index),
        );
      },
    );
  }

  Widget _buildSaveButton(BuildContext context, bool isSaving) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSaving
            ? null
            : () => context.read<AdminEditQuizBloc>().add(
                AdminSaveQuizEvent(
                  quizId: widget.quiz.id,
                  title: _titleController.text.trim(),
                  description: _descriptionController.text.trim().isEmpty
                      ? null
                      : _descriptionController.text.trim(),
                  category: _categoryController.text.trim().isEmpty
                      ? null
                      : _categoryController.text.trim(),
                  status: _isPublic ? 'public' : 'private',
                  quizCode: _codeController.text,
                  questions: _questions,
                ),
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _hasChanges ? AppColors.darkAzure : Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          disabledBackgroundColor: Colors.grey.shade400,
        ),
        child: isSaving
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
                _hasChanges ? "Save Changes" : "No Changes",
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
