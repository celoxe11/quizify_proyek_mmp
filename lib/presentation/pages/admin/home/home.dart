import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/repositories/admin_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/analytics/admin_analytics_bloc.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  static const double _kMobileBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    // Inject Bloc & Load Data
    return BlocProvider(
      create: (context) => AdminAnalyticsBloc(
        context.read<AdminRepositoryImpl>(),
      )..add(LoadAnalytics()),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          backgroundColor: AppColors.darkAzure,
        foregroundColor: Colors.white,
          actions: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => ctx.read<AdminAnalyticsBloc>().add(LoadAnalytics()),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: BlocBuilder<AdminAnalyticsBloc, AdminAnalyticsState>(
          builder: (context, state) {
            // 1. Loading
            if (state is AnalyticsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            // 2. Error
            if (state is AnalyticsError) {
              return Center(child: Text("Error: ${state.message}"));
            }

            // 3. Success (Data Asli)
            if (state is AnalyticsLoaded) {
              final data = state.analytics;

              // Hitung Statistik
              int totalQuizzes = 0;
              for (var t in data.teacherTrends) {
                totalQuizzes += (t.math + t.science + t.history + t.other).toInt();
              }
              int activeTeachers = data.teacherTrends.length;
              int activeStudents = data.studentParticipation.active;
              int totalStudents = data.studentParticipation.total;

              return Padding(
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

                      // --- STATS CARDS (DESAIN GRADIENT ASLI) ---
                      GridView.count(
                        crossAxisCount: MediaQuery.of(context).size.width > _kMobileBreakpoint ? 4 : 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _StatCard(
                            title: 'Total Students',
                            value: '$totalStudents',
                            icon: Icons.people,
                            color: Colors.blue,
                          ),
                          _StatCard(
                            title: 'Active Teachers',
                            value: '$activeTeachers',
                            icon: Icons.school,
                            color: Colors.green,
                          ),
                          _StatCard(
                            title: 'Active Students',
                            value: '$activeStudents',
                            icon: Icons.person,
                            color: Colors.orange,
                          ),
                          _StatCard(
                            title: 'Total Quizzes',
                            value: '$totalQuizzes',
                            icon: Icons.quiz,
                            color: Colors.purple,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                      
                      // Shortcut ke Analytics Detail & Log
                      const Text(
                        'Quick Actions',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _ActionCard(
                              title: "View Analytics",
                              icon: Icons.bar_chart,
                              color: AppColors.darkAzure,
                              onTap: () => context.go('/admin/analytics'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _ActionCard(
                              title: "View Activity Logs",
                              icon: Icons.history,
                              color: Colors.teal,
                              // Nanti arahkan ke halaman log yang akan dibuat
                              onTap: () => context.go('/admin/logs'), 
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

// --- DESAIN KARTU ASLI (GRADIENT) ---
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // Gradient Background sesuai request
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
              Icon(icon, color: Colors.white, size: 32), // Icon Putih biar kontras
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Teks Putih
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
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

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}