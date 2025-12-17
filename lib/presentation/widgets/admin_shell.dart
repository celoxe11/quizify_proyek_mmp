import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';

class AdminShell extends StatelessWidget {
  final Widget child;
  const AdminShell({required this.child, super.key});

  int _indexFromLocation(String loc) {
    if (loc.startsWith('/admin/users')) return 1;
    if (loc.startsWith('/admin/quizzes')) return 2;
    if (loc.startsWith('/admin/analytics')) return 3;
    if (loc.startsWith('/admin/settings')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _indexFromLocation(GoRouterState.of(context).uri.path);

    void handleLogout() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Logging out...',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
      // Dispatch the LogoutRequested event
      context.read<AuthBloc>().add(const LogoutRequested());
    }

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
                      // Display label for logout
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
                  context.go('/admin/dashboard');
                  break;
                case 1:
                  context.go('/admin/users');
                  break;
                case 2:
                  context.go('/admin/quizzes');
                  break;
                case 3:
                  context.go('/admin/analytics');
                  break;
                case 4:
                  context.go('/admin/settings');
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
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.quiz),
                label: Text('Quizzes'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics),
                label: Text('Analytics'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
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
}
