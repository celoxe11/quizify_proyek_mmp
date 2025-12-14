import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import "package:quizify_proyek_mmp/core/constants/app_colors.dart";
import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';
import 'package:quizify_proyek_mmp/presentation/widgets/question_card.dart';

/// Edit Quiz Page - Allows teachers to edit an existing quiz.
///
/// This page receives a [QuizModel] and pre-fills all fields with existing data.
/// Questions are loaded from the database based on the quiz ID.
///
/// TODOs for backend integration:
/// - Load questions from database in [_loadQuestions]
/// - Implement [_saveQuiz] to update quiz in database
/// - Implement [_deleteQuestion] to remove question from database
/// - Add validation before saving
class TeacherEditQuizPage extends StatefulWidget {
  const TeacherEditQuizPage({super.key, required this.quiz});

  /// The quiz to be edited. All fields will be pre-filled with this data.
  final QuizModel quiz;

  static const double _kDesktopMaxWidth = 900;
  static const double _kMobileBreakpoint = 600;

  @override
  State<TeacherEditQuizPage> createState() => _TeacherEditQuizPageState();
}

class _TeacherEditQuizPageState extends State<TeacherEditQuizPage> {
  // ============================================================
  // State Variables
  // ============================================================

  /// List of questions for this quiz. Loaded from database on init.
  final List<QuestionModel> _questions = [];

  /// Whether the quiz is public or private.
  late bool _isPublic;

  /// Controller for quiz title input.
  late final TextEditingController _titleController;

  /// Controller for quiz description input.
  late final TextEditingController _descriptionController;

  /// Controller for quiz code display.
  late final TextEditingController _codeController;

  /// Controller for quiz category input.
  late final TextEditingController _categoryController;

  /// Loading state for questions.
  bool _isLoadingQuestions = false;

  /// Saving state for quiz updates.
  bool _isSaving = false;

  /// Track if there are unsaved changes.
  bool _hasChanges = false;

  // ============================================================
  // Lifecycle Methods
  // ============================================================

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadQuestions();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _codeController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  /// Initialize all text controllers with existing quiz data.
  void _initializeControllers() {
    // Pre-fill title from existing quiz
    _titleController = TextEditingController(text: widget.quiz.title);

    // Pre-fill description from existing quiz
    _descriptionController = TextEditingController(
      text: widget.quiz.description ?? '',
    );

    // TODO: Replace with actual quiz code field when added to QuizModel
    // For now, use first 8 characters of quiz ID as code
    final quizCode = widget.quiz.id.length >= 8
        ? widget.quiz.id.substring(0, 8).toUpperCase()
        : widget.quiz.id.toUpperCase();
    _codeController = TextEditingController(text: quizCode);

    // Pre-fill category from existing quiz
    _categoryController = TextEditingController(
      text: widget.quiz.category ?? '',
    );

    // Pre-fill public status from existing quiz
    _isPublic = widget.quiz.status.toLowerCase() == 'public';

    // Add listeners to track changes
    _titleController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
    _categoryController.addListener(_onFieldChanged);
  }

  /// Called when any field changes to track unsaved changes.
  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  // ============================================================
  // Data Loading Methods
  // ============================================================

  /// Load questions from database for this quiz.
  ///
  /// TODO: Implement backend call to load questions
  /// Example implementation:
  /// ```dart
  /// final questions = await questionRepository.getByQuizId(widget.quiz.id);
  /// setState(() {
  ///   _questions.addAll(questions);
  ///   _isLoadingQuestions = false;
  /// });
  /// ```
  Future<void> _loadQuestions() async {
    setState(() {
      _isLoadingQuestions = true;
    });

    // TODO: Replace with actual backend call
    // final questions = await questionRepository.getByQuizId(widget.quiz.id);

    // Simulate loading delay for development
    await Future.delayed(const Duration(milliseconds: 500));

    // TODO: Populate _questions with loaded data
    // _questions.addAll(questions.cast<QuestionModel>());

    // If quiz already has questions loaded, use them
    if (widget.quiz.questions.isNotEmpty) {
      _questions.addAll(widget.quiz.questions.cast<QuestionModel>());
    }

    setState(() {
      _isLoadingQuestions = false;
    });
  }

  // ============================================================
  // Question Management Methods
  // ============================================================

  /// Add a new empty question to the quiz.
  void _addQuestion() {
    setState(() {
      _questions.add(
        QuestionModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          quizId: widget.quiz.id, // Link to current quiz
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

  /// Update a question at the specified index.
  void _updateQuestion(int index, QuestionModel updatedQuestion) {
    setState(() {
      if (index >= 0 && index < _questions.length) {
        _questions[index] = updatedQuestion;
        _hasChanges = true;
      }
    });
  }

  /// Remove a question at the specified index.
  ///
  /// TODO: Implement backend call to delete question
  /// If the question exists in the database (has a valid ID),
  /// make an API call to delete it.
  void _removeQuestion(int index) {
    // TODO: Uncomment and use when implementing backend deletion
    // final question = _questions[index];
    // if (question.id != null) {
    //   await questionRepository.delete(question.id);
    // }

    setState(() {
      _questions.removeAt(index);
      _hasChanges = true;
    });
  }

  // ============================================================
  // Save & Update Methods
  // ============================================================

  /// Save all changes to the quiz and questions.
  ///
  /// TODO: Implement backend calls to update quiz and questions
  ///
  /// Steps to implement:
  /// 1. Validate all fields
  /// 2. Update quiz in database
  /// 3. Update/create/delete questions as needed
  /// 4. Show success/error message
  /// 5. Navigate back to quiz detail page
  Future<void> _saveQuiz() async {
    // Validate required fields
    if (_titleController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a quiz title');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // TODO: Create updated quiz model
      // final updatedQuiz = widget.quiz.copyWith(
      //   title: _titleController.text.trim(),
      //   description: _descriptionController.text.trim(),
      //   category: _categoryController.text.trim().isEmpty
      //       ? null
      //       : _categoryController.text.trim(),
      //   status: _isPublic ? 'public' : 'private',
      //   updatedAt: DateTime.now(),
      // );

      // TODO: Update quiz in database
      // await quizRepository.update(updatedQuiz);

      // TODO: Update/create questions
      // for (final question in _questions) {
      //   if (question.id.startsWith('temp_')) {
      //     // New question - create
      //     await questionRepository.create(question.copyWith(quizId: widget.quiz.id));
      //   } else {
      //     // Existing question - update
      //     await questionRepository.update(question);
      //   }
      // }

      // Simulate save delay for development
      await Future.delayed(const Duration(seconds: 1));

      // Show success message
      if (mounted) {
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

        // Navigate back to quiz detail page
        // TODO: Pass updated quiz data back
        context.pop();
      }
    } catch (e) {
      // TODO: Handle specific error types
      _showErrorSnackBar('Failed to save quiz: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// Show error message in a snackbar.
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ============================================================
  // Utility Methods
  // ============================================================

  /// Copy quiz code to clipboard.
  void _copyCodeToClipboard() {
    Clipboard.setData(ClipboardData(text: _codeController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Quiz code copied to clipboard!'),
        backgroundColor: AppColors.darkAzure,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Show confirmation dialog when user tries to leave with unsaved changes.
  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
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

  // ============================================================
  // Build Methods
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.of(context).size.width >=
        TeacherEditQuizPage._kMobileBreakpoint;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = isDesktop
        ? TeacherEditQuizPage._kDesktopMaxWidth
        : double.infinity;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.dirtyCyan,
        appBar: _buildAppBar(),
        body: Container(
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
                    _buildQuizHeaderCard(isDesktop),

                    const SizedBox(height: 24.0),

                    // Add Question Button
                    _buildAddQuestionButton(),

                    const SizedBox(height: 16.0),

                    // Questions List
                    _buildQuestionsList(),

                    const SizedBox(height: 24.0),

                    // Save Button
                    _buildSaveButton(),

                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.darkAzure,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () async {
          if (_hasChanges) {
            final shouldPop = await _onWillPop();
            if (shouldPop && mounted) {
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
            onPressed: _isSaving ? null : _saveQuiz,
            icon: _isSaving
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
              _isSaving ? 'Saving...' : 'Save',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildQuizHeaderCard(bool isDesktop) {
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
              if (isDesktop) _buildPublicSwitch(),
            ],
          ),

          // If mobile, show switch on separate line
          if (!isDesktop) ...[const SizedBox(height: 12), _buildPublicSwitch()],

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
              Row(
                children: [
                  const Icon(
                    Icons.qr_code,
                    color: AppColors.darkAzure,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Text(
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
                    onPressed: _copyCodeToClipboard,
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

  Widget _buildPublicSwitch() {
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
          onChanged: (value) {
            setState(() {
              _isPublic = value;
              _hasChanges = true;
            });
          },
          activeColor: Colors.green,
          inactiveThumbColor: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildAddQuestionButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton.icon(
        onPressed: _addQuestion,
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

  Widget _buildQuestionsList() {
    if (_isLoadingQuestions) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            children: [
              CircularProgressIndicator(color: AppColors.darkAzure),
              SizedBox(height: 16),
              Text(
                'Loading questions...',
                style: TextStyle(color: AppColors.darkAzure),
              ),
            ],
          ),
        ),
      );
    }

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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveQuiz,
        style: ElevatedButton.styleFrom(
          backgroundColor: _hasChanges ? AppColors.darkAzure : Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          disabledBackgroundColor: Colors.grey.shade400,
        ),
        child: _isSaving
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
}
