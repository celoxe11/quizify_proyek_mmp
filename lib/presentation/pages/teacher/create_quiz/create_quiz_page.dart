import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import "package:quizify_proyek_mmp/core/constants/app_colors.dart";
import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/data/repositories/teacher_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/create_quiz/create_quiz_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/widgets/teacher/create_quiz/question_card.dart';

class TeacherCreateQuizPage extends StatefulWidget {
  const TeacherCreateQuizPage({super.key});

  static const double _kDesktopMaxWidth = 900;
  static const double _kMobileBreakpoint = 600;

  @override
  State<TeacherCreateQuizPage> createState() => _TeacherCreateQuizPageState();
}

class _TeacherCreateQuizPageState extends State<TeacherCreateQuizPage> {
  final List<QuestionModel> _questions = [];
  bool _isPublic = true;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _codeController;
  late final TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _codeController = TextEditingController(text: _generateQuizCode());
    _categoryController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _codeController.dispose();
    _categoryController.dispose();
    super.dispose();
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
    });
  }

  void _updateQuestion(int index, QuestionModel updatedQuestion) {
    setState(() {
      if (index >= 0 && index < _questions.length) {
        _questions[index] = updatedQuestion;
      }
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  // generate a random 8 character alphanumeric string
  String _generateQuizCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final code = StringBuffer();
    for (int i = 0; i < 8; i++) {
      code.write(chars[random.nextInt(chars.length)]);
    }
    return code.toString();
  }

  void _showAIGenerationDialog(BuildContext context) {
    // TODO: Check premium status first
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.auto_awesome, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text('Generate Question with AI'),
            SizedBox(width: 8),
            Icon(Icons.stars, color: Colors.amber, size: 20),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This is a premium feature. Generate questions automatically using AI.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Topic or Subject',
                hintText: 'e.g., World War 2, Photosynthesis, etc.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.topic),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Difficulty',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.speed),
              ),
              value: 'easy',
              items: const [
                DropdownMenuItem(value: 'easy', child: Text('Easy')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'hard', child: Text('Hard')),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Question Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.question_answer),
              ),
              value: 'multiple',
              items: const [
                DropdownMenuItem(
                  value: 'multiple',
                  child: Text('Multiple Choice'),
                ),
                DropdownMenuItem(value: 'boolean', child: Text('True/False')),
              ],
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement AI generation logic
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('AI Generation feature coming soon!'),
                  backgroundColor: Colors.deepPurple,
                ),
              );
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.of(context).size.width >=
        TeacherCreateQuizPage._kMobileBreakpoint;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = isDesktop
        ? TeacherCreateQuizPage._kDesktopMaxWidth
        : double.infinity;

    // Set title from route extra if available (only once)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_titleController.text.isEmpty) {
        final quizName = GoRouterState.of(context).extra as String?;
        if (quizName != null && quizName.isNotEmpty) {
          _titleController.text = quizName;
        }
      }
    });

    return BlocListener<CreateQuizBloc, CreateQuizState>(
      listener: (context, state) {
        if (state is CreateQuizLoading) {
          // Show loading dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Dialog(
              backgroundColor: Colors.transparent,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (state is CreateQuizSuccess) {
          // Hide loading dialog
          Navigator.of(context, rootNavigator: true).pop();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quiz saved successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate to my quizzes page
          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              context.go("/teacher/quizzes");
            }
          });
        } else if (state is CreateQuizFailure) {
          // Hide loading dialog
          Navigator.of(context, rootNavigator: true).pop();

          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        } else if (state is CreateQuizValidationError) {
          // Hide loading dialog if it's showing
          if (ModalRoute.of(context)?.isCurrent == false) {
            Navigator.of(context, rootNavigator: true).pop();
          }

          // Show validation error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
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
        appBar: AppBar(
          backgroundColor: AppColors.darkAzure,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => {context.go("/teacher/new-quiz")},
          ),
          automaticallyImplyLeading: false,
          title: const Text(
            'Create New Quiz',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(color: AppColors.dirtyCyan),
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
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
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
                              if (isDesktop)
                                Row(
                                  children: [
                                    const Text("Make Quiz Public"),
                                    Switch(
                                      value: _isPublic,
                                      onChanged: (value) {
                                        setState(() {
                                          _isPublic = value;
                                        });
                                      },
                                      activeColor: AppColors.darkAzure,
                                    ),
                                  ],
                                ),
                            ],
                          ),

                          // If mobile, show switch on separate line
                          if (!isDesktop) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Text("Make Quiz Public"),
                                Switch(
                                  value: _isPublic,
                                  onChanged: (value) {
                                    setState(() {
                                      _isPublic = value;
                                    });
                                  },
                                  activeColor: AppColors.darkAzure,
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 16.0),

                          // Quiz Description
                          TextField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              hintText: 'Quiz Description',
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.darkAzure,
                            ),
                            maxLines: null,
                          ),

                          const SizedBox(height: 20.0),
                          const Divider(),
                          const SizedBox(height: 16.0),

                          // Category Field
                          Row(
                            children: [
                              const Icon(
                                Icons.category,
                                color: AppColors.darkAzure,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _categoryController,
                                  decoration: const InputDecoration(
                                    hintText:
                                        'Category (e.g., Science, Math, History)',
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

                          // Quiz Code Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Quiz Code:",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.darkAzure,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    _codeController.text,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkAzure,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy),
                                    onPressed: () {
                                      // Copy quiz code to clipboard
                                    },
                                    tooltip: 'Copy Code',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

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
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Generate with AI Button (Premium)
                        ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Check if user is premium, then show AI generation dialog
                            _showAIGenerationDialog(context);
                          },
                          icon: const Icon(Icons.auto_awesome, size: 20),
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text("Generate with AI"),
                              SizedBox(width: 4),
                              Icon(Icons.stars, size: 16, color: Colors.amber),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16.0),

                    // Questions List using LayoutBuilder
                    ListView.builder(
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
                    ),

                    const SizedBox(height: 24.0),

                    // Save Quiz Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Dispatch SubmitQuizEvent
                          context.read<CreateQuizBloc>().add(
                            SubmitQuizEvent(
                              title: _titleController.text,
                              description: _descriptionController.text,
                              category: _categoryController.text,
                              status: _isPublic ? 'public' : 'private',
                              quizCode: _codeController.text,
                              questions: _questions,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkAzure,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Save Quiz",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

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
}
