import 'package:flutter/material.dart';

class LoginDesktop extends StatelessWidget {
  const LoginDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: Text(
          'Login Desktop Page',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
