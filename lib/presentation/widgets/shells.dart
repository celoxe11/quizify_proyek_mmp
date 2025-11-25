import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudentShell extends StatelessWidget {
  final Widget child;
  const StudentShell({required this.child, super.key});

  int _indexFromLocation(String loc) {
    if (loc.startsWith('/student/quizzes')) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final uri = GoRouterState.of(context).uri;
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final currentIndex = _indexFromLocation(uri.path);

    if (isDesktop) {
      return Scaffold(
        appBar: AppBar(title: const Text('Student')),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(child: Text('Student Menu')),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                selected: currentIndex == 0,
                onTap: () => context.go('/student/home'),
              ),
              ListTile(
                leading: const Icon(Icons.quiz),
                title: const Text('Quizzes'),
                selected: currentIndex == 1,
                onTap: () => context.go('/student/quizzes'),
              ),
            ],
          ),
        ),
        body: child,
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quizzes'),
        ],
        onTap: (i) {
          if (i == 0) context.go('/student/home');
          if (i == 1) context.go('/student/quizzes');
        },
      ),
    );
  }
}

class TeacherShell extends StatelessWidget {
  final Widget child;
  const TeacherShell({required this.child, super.key});

  int _indexFromLocation(String loc) {
    if (loc.startsWith('/teacher/manage')) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final currentIndex = _indexFromLocation(GoRouterState.of(context).uri.path);

    if (isDesktop) {
      return Scaffold(
        appBar: AppBar(title: const Text('Teacher')),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(child: Text('Teacher Menu')),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                selected: currentIndex == 0,
                onTap: () => context.go('/teacher/home'),
              ),
              ListTile(
                leading: const Icon(Icons.manage_accounts),
                title: const Text('Manage'),
                selected: currentIndex == 1,
                onTap: () => context.go('/teacher/manage'),
              ),
            ],
          ),
        ),
        body: child,
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: 'Manage',
          ),
        ],
        onTap: (i) {
          if (i == 0) context.go('/teacher/home');
          if (i == 1) context.go('/teacher/manage');
        },
      ),
    );
  }
}
