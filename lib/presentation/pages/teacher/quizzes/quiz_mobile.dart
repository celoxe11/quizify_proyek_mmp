import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';

class TeacherQuizMobile extends StatefulWidget {
  const TeacherQuizMobile({super.key});

  @override
  State<TeacherQuizMobile> createState() => _TeacherQuizMobileState();
}

class _TeacherQuizMobileState extends State<TeacherQuizMobile> {
  // Dummy quiz data
  final List<Map<String, dynamic>> _quizzes = [
    {
      'id': '1',
      'title': 'Math Quiz 101',
      'description': 'Basic algebra and geometry questions',
      'questions': 20,
      'duration': '30 min',
      'difficulty': 'Easy',
      'participants': 45,
      'dateCreated': '2024-11-15',
      'isPublished': true,
    },
    {
      'id': '2',
      'title': 'Science Challenge',
      'description': 'Physics and Chemistry fundamentals',
      'questions': 15,
      'duration': '25 min',
      'difficulty': 'Medium',
      'participants': 32,
      'dateCreated': '2024-11-20',
      'isPublished': true,
    },
    {
      'id': '3',
      'title': 'History Trivia',
      'description': 'World War II historical events',
      'questions': 25,
      'duration': '40 min',
      'difficulty': 'Hard',
      'participants': 28,
      'dateCreated': '2024-11-22',
      'isPublished': false,
    },
    {
      'id': '4',
      'title': 'English Grammar',
      'description': 'Advanced grammar rules and usage',
      'questions': 30,
      'duration': '45 min',
      'difficulty': 'Medium',
      'participants': 52,
      'dateCreated': '2024-11-25',
      'isPublished': true,
    },
    {
      'id': '5',
      'title': 'Programming Basics',
      'description': 'Introduction to programming concepts',
      'questions': 18,
      'duration': '35 min',
      'difficulty': 'Easy',
      'participants': 67,
      'dateCreated': '2024-11-28',
      'isPublished': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.darkAzure,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'My Quizzes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Add Quiz Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to create quiz page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Create new quiz functionality coming soon!'),
                  ),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Create New Quiz',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkAzure,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Quiz List
          Expanded(
            child: _quizzes.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _quizzes.length,
                    itemBuilder: (context, index) {
                      final quiz = _quizzes[index];
                      return _buildQuizCard(quiz);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No quizzes yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first quiz to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(Map<String, dynamic> quiz) {
    Color difficultyColor;
    switch (quiz['difficulty']) {
      case 'Easy':
        difficultyColor = Colors.green;
        break;
      case 'Medium':
        difficultyColor = Colors.orange;
        break;
      case 'Hard':
        difficultyColor = Colors.red;
        break;
      default:
        difficultyColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // TODO: Navigate to quiz details/edit page
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Edit quiz: ${quiz['title']}')),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quiz['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkAzure,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            quiz['description'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: difficultyColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            quiz['difficulty'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: difficultyColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: quiz['isPublished']
                                ? Colors.green.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            quiz['isPublished'] ? 'Published' : 'Draft',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: quiz['isPublished']
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildQuizInfo(
                      Icons.quiz_outlined,
                      '${quiz['questions']} Q',
                    ),
                    _buildQuizInfo(Icons.access_time, quiz['duration']),
                    _buildQuizInfo(
                      Icons.people,
                      '${quiz['participants']} taken',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Created: ${quiz['dateCreated']}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
