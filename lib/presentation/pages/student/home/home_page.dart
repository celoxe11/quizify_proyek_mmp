import 'package:flutter/material.dart';

class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.school, size: 72, color: Colors.indigo),
            SizedBox(height: 16),
            Text(
              'Student Home',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Welcome to the student area. Use the navigation to view quizzes.',
            ),
          ],
        ),
      ),
    );
  }
}
