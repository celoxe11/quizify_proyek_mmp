import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quizify'),
        actions: [
          FilledButton(onPressed: () {}, child: Text('Login')),
          OutlinedButton(onPressed: () {}, child: Text('Register')),
        ],
      ),
      body: Center(
        child: Text(
          'Landing Page',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
