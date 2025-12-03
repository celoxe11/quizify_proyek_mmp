import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';

class TeacherHomeDesktop extends StatefulWidget {
  const TeacherHomeDesktop({super.key});

  @override
  State<TeacherHomeDesktop> createState() => _TeacherHomeDesktopState();
}

class _TeacherHomeDesktopState extends State<TeacherHomeDesktop> {
  final TextEditingController _searchController = TextEditingController();

  // Dummy data for recommended quizzes
  final List<Map<String, dynamic>> _recommendedQuizzes = [
    {
      'title': 'Math Quiz 101',
      'description': 'Basic algebra and geometry',
      'questions': 20,
      'participants': 45,
      'color': const Color(0xFF7DD3C0),
    },
    {
      'title': 'Science Challenge',
      'description': 'Physics and Chemistry basics',
      'questions': 15,
      'participants': 32,
      'color': const Color(0xFF5DB4C4),
    },
    {
      'title': 'History Trivia',
      'description': 'World War II events',
      'questions': 25,
      'participants': 28,
      'color': const Color(0xFFA8D8D8),
    },
  ];

  // Dummy data for all quizzes
  final List<Map<String, dynamic>> _allQuizzes = [
    {
      'title': 'English Grammar',
      'subject': 'English',
      'questions': 30,
      'duration': '45 min',
      'difficulty': 'Medium',
    },
    {
      'title': 'Biology Basics',
      'subject': 'Science',
      'questions': 20,
      'duration': '30 min',
      'difficulty': 'Easy',
    },
    {
      'title': 'Advanced Calculus',
      'subject': 'Math',
      'questions': 25,
      'duration': '60 min',
      'difficulty': 'Hard',
    },
    {
      'title': 'World Geography',
      'subject': 'Geography',
      'questions': 18,
      'duration': '25 min',
      'difficulty': 'Easy',
    },
    {
      'title': 'Programming Fundamentals',
      'subject': 'Computer Science',
      'questions': 22,
      'duration': '40 min',
      'difficulty': 'Medium',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.darkAzure,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Quizify',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
            onPressed: () {
              // TODO: Navigate to shop
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recommended Quizzes Section
              const Text(
                'Recommended Quizzes',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkAzure,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _recommendedQuizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = _recommendedQuizzes[index];
                    return _buildRecommendedCard(quiz);
                  },
                ),
              ),
              const SizedBox(height: 40),

              // All Quizzes Section
              const Text(
                'All Quizzes',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkAzure,
                ),
              ),
              const SizedBox(height: 24),

              // Search Bar
              SizedBox(
                width: 600,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search quizzes...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.darkAzure,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quiz Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.5,
                ),
                itemCount: _allQuizzes.length,
                itemBuilder: (context, index) {
                  final quiz = _allQuizzes[index];
                  return _buildQuizCard(quiz);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedCard(Map<String, dynamic> quiz) {
    return Container(
      width: 320,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: quiz['color'],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz['title'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  quiz['description'],
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.quiz, color: Colors.white, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      '${quiz['questions']} Questions',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.people, color: Colors.white, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      '${quiz['participants']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    quiz['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkAzure,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: difficultyColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    quiz['difficulty'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: difficultyColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              quiz['subject'],
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const Spacer(),
            Row(
              children: [
                _buildQuizInfo(Icons.quiz_outlined, '${quiz['questions']} Q'),
                const SizedBox(width: 16),
                _buildQuizInfo(Icons.access_time, quiz['duration']),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
    );
  }
}
