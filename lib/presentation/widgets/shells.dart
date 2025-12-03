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
    if (loc.startsWith('/teacher/quizzes')) return 1;
    if (loc.startsWith('/teacher/profile')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final currentIndex = _indexFromLocation(GoRouterState.of(context).uri.path);

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Sidebar with NavigationRail
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) {
                switch (index) {
                  case 0:
                    context.go('/teacher/home');
                    break;
                  case 1:
                    context.go('/teacher/quizzes');
                    break;
                  case 2:
                    context.go('/teacher/profile');
                    break;
                }
              },
              labelType: NavigationRailLabelType.all,
              backgroundColor: const Color(0xFF0D6B7A),
              selectedIconTheme: const IconThemeData(
                color: Colors.white,
                size: 28,
              ),
              selectedLabelTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              unselectedIconTheme: const IconThemeData(
                color: Colors.white70,
                size: 24,
              ),
              unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.quiz),
                  label: Text('Quizzes'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text('Profile'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // Main content area
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0D6B7A),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quizzes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/teacher/home');
              break;
            case 1:
              context.go('/teacher/quizzes');
              break;
            case 2:
              context.go('/teacher/profile');
              break;
          }
        },
      ),
    );
  }
}
