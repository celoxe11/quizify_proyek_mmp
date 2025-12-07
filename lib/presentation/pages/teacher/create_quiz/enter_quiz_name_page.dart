import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';

class TeacherEnterQuizNamePage extends StatefulWidget {
  const TeacherEnterQuizNamePage({super.key});

  @override
  State<TeacherEnterQuizNamePage> createState() =>
      _TeacherEnterQuizNamePageState();
}

class _TeacherEnterQuizNamePageState extends State<TeacherEnterQuizNamePage> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.darkAzure,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => {context.go("/teacher/quizzes")},
        ),
        title: const Text(
          'New Quiz',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        color: AppColors.dirtyCyan,
        child: SafeArea(
          child: Column(
            children: [
              // Main Content
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 40.0 : 24.0,
                        vertical: 40.0,
                      ),
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: isDesktop ? 500 : double.infinity,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Icon with background
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.pureWhite,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.quiz_outlined,
                                size: 40,
                                color: AppColors.darkAzure,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Title
                            Text(
                              'Create New Quiz',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkAzure,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Subtitle
                            Text(
                              'Give your quiz a memorable name',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.darkAzure,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 48),

                            // Card Container
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Label
                                  Text(
                                    'Quiz Name',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.darkAzure,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // TextField
                                  TextField(
                                    controller: _nameController,
                                    keyboardType: TextInputType.text,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'e.g., Math Quiz Chapter 5',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        fontWeight: FontWeight.normal,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.edit_outlined,
                                        color: AppColors.darkAzure,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: AppColors.darkAzure,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Create Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (_nameController.text
                                            .trim()
                                            .isEmpty) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                'Please enter a quiz name',
                                              ),
                                              backgroundColor: Colors.red[400],
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                          return;
                                        }
                                        final quizName = _nameController.text;
                                        context.go("/teacher/create-quiz", extra: quizName);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.darkAzure,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Text(
                                            'Create Quiz',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(Icons.arrow_forward, size: 20),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Helper text
                            Text(
                              'You can add questions and customize your quiz in the next step',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.darkAzure,
                                fontWeight: FontWeight.w400
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
