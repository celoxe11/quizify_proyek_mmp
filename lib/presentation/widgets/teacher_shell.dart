import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';

class TeacherShell extends StatelessWidget {
  final Widget child;
  const TeacherShell({required this.child, super.key});

  int _indexFromLocation(String loc) {
    if (loc.startsWith('/teacher/quizzes')) return 1;
    if (loc.startsWith('/teacher/shop')) return 2;
    if (loc.startsWith('/teacher/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final currentIndex = _indexFromLocation(GoRouterState.of(context).uri.path);

    void handleLogout() {
      // Dispatch the LogoutRequested event
      context.read<AuthBloc>().add(const LogoutRequested());
    }

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Sidebar with NavigationRail
            NavigationRail(
              // trailing widget placed after destinations (bottom-aligned)
              trailing: Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Divider(
                          color: Colors.white54,
                          indent: 8,
                          endIndent: 8,
                        ),
                        const SizedBox(height: 8),
                        // The button for the logout action
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          iconSize: 24,
                          onPressed: handleLogout,
                          tooltip: 'Logout',
                        ),
                        // Only display the label if labelType is selected (optional, but good practice)
                        if (NavigationRailLabelType.all ==
                            NavigationRailLabelType.all)
                          const Text(
                            'Logout',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
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
                    context.go('/teacher/shop');
                    break;
                  case 3:
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
                  icon: Icon(Icons.storefront), 
                  label: Text('Shop')
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
          BottomNavigationBarItem(
            icon: Icon(Icons.home), 
            label: 'Home'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz), 
            label: 'Quizzes'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront), 
            label: 'Shop'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), 
            label: 'Profile'
          ),
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
              context.go('/teacher/shop');
              break;
            case 3:
              context.go('/teacher/profile');
              break;
          }
        },
      ),
    );
  }
}
