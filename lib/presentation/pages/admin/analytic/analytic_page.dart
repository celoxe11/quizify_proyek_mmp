import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/admin_analytics_model.dart';
import 'package:quizify_proyek_mmp/data/repositories/admin_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/analytics/admin_analytics_bloc.dart'; // Import Bloc Baru

class AnalyticPageWrapper extends StatelessWidget {
  const AnalyticPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Bloc disini agar Page lebih bersih
    return BlocProvider(
      create: (context) => AdminAnalyticsBloc(
        context.read<AdminRepositoryImpl>(),
      )..add(LoadAnalytics()),
      child: const AnalyticPage(),
    );
  }
}

class AnalyticPage extends StatelessWidget {
  const AnalyticPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Analytics Overview', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkAzure,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AdminAnalyticsBloc>().add(LoadAnalytics()),
          )
        ],
      ),
      body: BlocBuilder<AdminAnalyticsBloc, AdminAnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.darkAzure));
          } else if (state is AnalyticsError) {
            return Center(child: Text("Error: ${state.message}"));
          } else if (state is AnalyticsLoaded) {
            final data = state.analytics; // DATA ASLI DARI BACKEND

            return LayoutBuilder(
              builder: (context, constraints) {
                bool isDesktop = constraints.maxWidth > 900;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Platform Statistics",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      const SizedBox(height: 8),
                      Text("Real-time data from database.", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      const SizedBox(height: 32),

                      if (isDesktop) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  const _SectionHeader(title: "1. Teacher Category Trends", subtitle: "Top Subject Areas", icon: Icons.school, color: Colors.blue),
                                  const SizedBox(height: 16),
                                  // PASS DATA KE CHART
                                  _TeacherCategoryChartCard(data: data.teacherTrends),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                children: [
                                  const _SectionHeader(title: "2. Student Participation", subtitle: "Submission rate", icon: Icons.assignment_turned_in, color: Colors.green),
                                  const SizedBox(height: 16),
                                  // PASS DATA KE CHART
                                  _StudentPerformanceChartCard(data: data.studentParticipation),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        const _SectionHeader(title: "3. Quiz Flow Analysis", subtitle: "Difficulty vs Student Failures", icon: Icons.graphic_eq, color: Colors.purple),
                        const SizedBox(height: 16),
                        SizedBox(height: 350, child: _QuizFlowChartCard(data: data.quizFlow)),
                        const SizedBox(height: 40),
                        const _SectionHeader(title: "4. User Activity", subtitle: "Registrations vs Active Logins", icon: Icons.ssid_chart, color: Colors.orange),
                        const SizedBox(height: 16),
                        SizedBox(height: 350, child: _UserActivityChartCard(data: data.userActivity)),
                      ] else ...[
                        const _SectionHeader(title: "1. Teacher Category Trends", subtitle: "Top Subject Areas", icon: Icons.school, color: Colors.blue),
                        const SizedBox(height: 16),
                        _TeacherCategoryChartCard(data: data.teacherTrends),
                        const SizedBox(height: 40),
                        const _SectionHeader(title: "2. Student Participation", subtitle: "Submission rate", icon: Icons.assignment_turned_in, color: Colors.green),
                        const SizedBox(height: 16),
                        _StudentPerformanceChartCard(data: data.studentParticipation),
                        const SizedBox(height: 40),
                        const _SectionHeader(title: "3. Quiz Flow Analysis", subtitle: "Difficulty vs Failures", icon: Icons.graphic_eq, color: Colors.purple),
                        const SizedBox(height: 16),
                        SizedBox(height: 300, child: _QuizFlowChartCard(data: data.quizFlow)),
                        const SizedBox(height: 40),
                        const _SectionHeader(title: "4. User Activity", subtitle: "Registrations vs Logins", icon: Icons.ssid_chart, color: Colors.orange),
                        const SizedBox(height: 16),
                        SizedBox(height: 300, child: _UserActivityChartCard(data: data.userActivity)),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

// ================= WIDGETS (UPDATED WITH REAL DATA) =================

class _TeacherCategoryChartCard extends StatelessWidget {
  final List<TeacherTrend> data; // Menerima Data Asli
  const _TeacherCategoryChartCard({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Card(child: Padding(padding: EdgeInsets.all(20), child: Text("No teacher data yet")));

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _LegendItem(color: Colors.blue, label: "Math"),
                SizedBox(width: 12),
                _LegendItem(color: Colors.orange, label: "Science"),
                SizedBox(width: 12),
                _LegendItem(color: Colors.teal, label: "History"),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: List.generate(data.length, (index) {
                    final item = data[index];
                    // Mapping data model ke Batang Grafik
                    return _makeStackedGroup(index, item.math, item.science, item.history);
                  }),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= data.length) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(data[value.toInt()].name, // NAMA GURU ASLI
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeStackedGroup(int x, double y1, double y2, double y3) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1 + y2 + y3,
          width: 20,
          borderRadius: BorderRadius.circular(4),
          rodStackItems: [
            BarChartRodStackItem(0, y1, Colors.blue),
            BarChartRodStackItem(y1, y1 + y2, Colors.orange),
            BarChartRodStackItem(y1 + y2, y1 + y2 + y3, Colors.teal),
          ],
        ),
      ],
    );
  }
}

class _QuizFlowChartCard extends StatelessWidget {
  final List<QuizFlow> data;
  const _QuizFlowChartCard({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Card(child: Padding(padding: EdgeInsets.all(20), child: Text("No quiz flow data available")));

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Difficulty & Failures", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                Row(
                  children: [
                    _LegendItem(color: Colors.purple, label: "Difficulty"),
                    SizedBox(width: 16),
                    _LegendItem(color: Colors.red, label: "Failures"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: true, verticalInterval: 1, getDrawingVerticalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1), getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1))),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < data.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(data[value.toInt()].label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 20, reservedSize: 30, getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)))),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0, maxX: (data.length - 1).toDouble(),
                  minY: 0, maxY: 100,
                  lineBarsData: [
                    // DIFFICULTY LINE
                    LineChartBarData(
                      spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.difficulty)).toList(),
                      isCurved: true, color: Colors.purple, barWidth: 3, dotData: const FlDotData(show: true),
                    ),
                    // FAILURES LINE
                    LineChartBarData(
                      spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.failures)).toList(),
                      isCurved: true, color: Colors.red, barWidth: 3, dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: true, color: Colors.red.withOpacity(0.1)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentPerformanceChartCard extends StatelessWidget {
  final StudentParticipation data;
  const _StudentPerformanceChartCard({required this.data});

  @override
  Widget build(BuildContext context) {
    // Hitung persentase aktif
    double rawPercent = data.total > 0 ? (data.active / data.total) : 0;
    double percent = rawPercent > 1.0 ? 1.0 : rawPercent;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            SizedBox(
              height: 120, width: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(value: percent, strokeWidth: 12, backgroundColor: const Color(0xFFE0E0E0), color: Colors.green),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${(percent * 100).toInt()}%", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        Text("Active", style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Submission Rate", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _StatRow(label: "Total Students", value: "${data.total}"),
                  const Divider(),
                  _StatRow(label: "Active", value: "${data.active}"),
                  const Divider(),
                  _StatRow(label: "Pending", value: "${data.pending}"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserActivityChartCard extends StatelessWidget {
  final List<UserActivity> data;
  const _UserActivityChartCard({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Card(child: Padding(padding: EdgeInsets.all(20), child: Text("No user activity data")));
  
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Weekly Activity", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                Row(
                  children: [
                    _LegendItem(color: Colors.blue, label: "New Register"),
                    SizedBox(width: 16),
                    _LegendItem(color: Colors.orange, label: "Active Login"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 20, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100)),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true, interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < data.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(data[value.toInt()].day, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 5, reservedSize: 30, getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)))),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0, maxX: (data.length - 1).toDouble(),
                  minY: 0,
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.registers)).toList(),
                      isCurved: true, color: Colors.blue, barWidth: 3, dotData: const FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.logins)).toList(),
                      isCurved: true, color: Colors.orange, barWidth: 3, dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Helper Kecil ---
class _LegendItem extends StatelessWidget {
  final Color color; final String label;
  const _LegendItem({required this.color, required this.label});
  @override Widget build(BuildContext context) => Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))]);
}

class _SectionHeader extends StatelessWidget {
  final String title; final String subtitle; final IconData icon; final Color color;
  const _SectionHeader({required this.title, required this.subtitle, required this.icon, required this.color});
  @override Widget build(BuildContext context) => Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)), const SizedBox(width: 16), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)), Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600]))])]);
}

class _StatRow extends StatelessWidget {
  final String label; final String value;
  const _StatRow(
    {required this.label, required this.value}
  );
  @override Widget build(BuildContext context) => 
    Padding(
      padding: 
        const EdgeInsets.symmetric(vertical: 4.0),  
        child: 
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [
              Text(
                  label, 
                  style: TextStyle(color: Colors.grey[600], fontSize: 13)
                  ), 
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold))
            ]
          )
    );
}