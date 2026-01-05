import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';

class StudentShell extends StatelessWidget {
  final Widget child;
  const StudentShell({required this.child, super.key});

  // 1. Update logika index untuk menyertakan History
  int _indexFromLocation(String loc) {
    if (loc.startsWith('/student/join-quiz')) return 1;
    if (loc.startsWith('/student/history')) return 2; // Tambahan History
    if (loc.startsWith('/student/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final uri = GoRouterState.of(context).uri;
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final currentIndex = _indexFromLocation(uri.path);

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
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          iconSize: 24,
                          onPressed: handleLogout,
                          tooltip: 'Logout',
                        ),
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
                    context.go('/student/home');
                    break;
                  case 1:
                    context.go('/student/join-quiz');
                    break;
                  case 2: // Tambahan logic navigasi desktop
                    context.go('/student/history');
                    break;
                  case 3:
                    context.go('/student/profile');
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
                  label: Text('Join Quiz'),
                ),
                // 2. Tambahkan Destination Desktop
                NavigationRailDestination(
                  icon: Icon(Icons.history),
                  label: Text('History'),
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

    // Tampilan Mobile
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        // Penting: gunakan fixed type jika item lebih dari 3 agar warna tetap muncul
        type: BottomNavigationBarType.fixed, 
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0D6B7A),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quizzes'),
          // 3. Tambahkan Item Mobile
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (i) {
          if (i == 0) context.go('/student/home');
          if (i == 1) context.go('/student/join-quiz');
          if (i == 2) context.go('/student/history'); // Navigasi History
          if (i == 3) context.go('/student/profile');
        },
      ),
    );
  }
}