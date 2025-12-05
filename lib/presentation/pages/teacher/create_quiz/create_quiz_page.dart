import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import "package:quizify_proyek_mmp/core/constants/app_colors.dart";
import 'package:quizify_proyek_mmp/presentation/widgets/question_card.dart';

class TeacherCreateQuizPage extends StatefulWidget {
  const TeacherCreateQuizPage({super.key});

  static const double _kDesktopMaxWidth = 900;
  static const double _kMobileBreakpoint = 600;

  @override
  State<TeacherCreateQuizPage> createState() => _TeacherCreateQuizPageState();
}

class _TeacherCreateQuizPageState extends State<TeacherCreateQuizPage> {
  final List<int> _questions = [1, 2, 3]; // Question indices

  void _addQuestion() {
    setState(() {
      _questions.add(_questions.length + 1);
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
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

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.darkAzure,
        elevation: 0,
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
      body: SingleChildScrollView(
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
                // Breadcrumb
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 500 : double.infinity,
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => context.go('/teacher/quizzes'),
                            child: Text(
                              'My Quizzes',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.darkAzure,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                          ),
                          Text(
                            'Create New Quiz',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Quiz Header Card
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
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
                                  value: true,
                                  onChanged: (value) {},
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
                              value: true,
                              onChanged: (value) {},
                              activeColor: AppColors.darkAzure,
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 16.0),

                      // Quiz Description
                      TextField(
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
                                "ABCD1234",
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
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      children: _questions.asMap().entries.map((entry) {
                        final index = entry.key;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Stack(
                            children: [
                              QuestionCard(),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  onPressed: () => _removeQuestion(index),
                                  tooltip: 'Remove Question',
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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
    );
  }
}
