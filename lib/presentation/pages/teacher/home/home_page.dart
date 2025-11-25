import 'package:flutter/material.dart';

class TeacherHomePage extends StatelessWidget {
  const TeacherHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.person, size: 72, color: Colors.indigo),
            SizedBox(height: 16),
            Text(
              'Teacher Home',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Teacher dashboard and stats appear here.'),
          ],
        ),
      ),
    );
  }
}
