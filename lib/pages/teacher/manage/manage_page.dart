import 'package:flutter/material.dart';

class TeacherManagePage extends StatelessWidget {
  const TeacherManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.manage_accounts, size: 72, color: Colors.indigo),
            SizedBox(height: 16),
            Text(
              'Manage Quizzes',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Create and manage quizzes here.'),
          ],
        ),
      ),
    );
  }
}
