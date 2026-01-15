import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import "package:quizify_proyek_mmp/core/constants/app_colors.dart";
import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/presentation/widgets/teacher/create_quiz/question_card.dart';

class AdminCreateQuizPage extends StatefulWidget {
  const AdminCreateQuizPage({super.key});

  static const double _kDesktopMaxWidth = 900;
  static const double _kMobileBreakpoint = 600;

  @override
  State<AdminCreateQuizPage> createState() => _AdminCreateQuizPageState();
}

class _AdminCreateQuizPageState extends State<AdminCreateQuizPage> {
  final List<QuestionModel> _questions = [
    QuestionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'multiple',
      difficulty: 'easy',
      questionText: '',
      correctAnswer: '',
      options: ['', '', '', ''],
    ),
  ];
  bool _isPublic = true;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _codeController = TextEditingController(text: _generateQuizCode());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _codeController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.of(context).size.width >=
        AdminCreateQuizPage._kMobileBreakpoint;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = isDesktop
        ? AdminCreateQuizPage._kDesktopMaxWidth
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

    return Scaffold(
      backgroundColor: Colors.grey[100],
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
                                    Clipboard.setData(
                                      ClipboardData(
                                        text: _codeController.text,
                                      ),
                                    );
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

                  // Add Question Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
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
                        // Save quiz logic
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
    );
  }
}
