import 'package:flutter/material.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  static const double _kMobileBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('Admin Dashboard'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard Overview',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Stats Cards
              GridView.count(
                crossAxisCount:
                    MediaQuery.of(context).size.width > _kMobileBreakpoint
                    ? 4
                    : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _StatCard(
                    title: 'Total Users',
                    value: '1,234',
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                  _StatCard(
                    title: 'Active Teachers',
                    value: '45',
                    icon: Icons.school,
                    color: Colors.green,
                  ),
                  _StatCard(
                    title: 'Active Students',
                    value: '1,189',
                    icon: Icons.person,
                    color: Colors.orange,
                  ),
                  _StatCard(
                    title: 'Total Quizzes',
                    value: '567',
                    icon: Icons.quiz,
                    color: Colors.purple,
                  ),
                ],
              ),

              const SizedBox(height: 32),
              const Text(
                'Recent Activity',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Activity List
              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.event)),
                      title: Text('Activity ${index + 1}'),
                      subtitle: const Text('2 hours ago'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.7), color.withOpacity(0.3)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
