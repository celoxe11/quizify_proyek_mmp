import 'package:flutter/material.dart';

class StudentQuizzesPage extends StatelessWidget {
  const StudentQuizzesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.quiz, size: 72, color: Colors.indigo),
            SizedBox(height: 16),
            Text(
              'Quizzes',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('List of available quizzes for students will show here.'),
          ],
        ),
      ),
    );
  }
}
