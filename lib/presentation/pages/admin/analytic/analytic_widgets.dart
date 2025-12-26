import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/admin_analytics_model.dart';

// --- WIDGETS ---

class SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const SectionHeader({super.key, required this.title, required this.subtitle, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }
}

class TeacherCategoryChartCard extends StatelessWidget {
  final List<TeacherTrend> data;
  const TeacherCategoryChartCard({super.key, required this.data});

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
                LegendItem(color: Colors.blue, label: "Math"),
                SizedBox(width: 12),
                LegendItem(color: Colors.orange, label: "Science"),
                SizedBox(width: 12),
                LegendItem(color: Colors.teal, label: "History"),
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
                            child: Text(data[value.toInt()].name,
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

class QuizFlowChartCard extends StatelessWidget {
  final List<QuizFlow> data;
  const QuizFlowChartCard({super.key, required this.data});

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
                    LegendItem(color: Colors.purple, label: "Difficulty"),
                    SizedBox(width: 16),
                    LegendItem(color: Colors.red, label: "Failures"),
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
                    LineChartBarData(
                      spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.difficulty)).toList(),
                      isCurved: true, color: Colors.purple, barWidth: 3, dotData: const FlDotData(show: true),
                    ),
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

class StudentPerformanceChartCard extends StatelessWidget {
  final StudentParticipation data;
  const StudentPerformanceChartCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
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
                  StatRow(label: "Total Students", value: "${data.total}"),
                  const Divider(),
                  StatRow(label: "Active", value: "${data.active}"),
                  const Divider(),
                  StatRow(label: "Pending", value: "${data.pending}"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserActivityChartCard extends StatelessWidget {
  final List<UserActivity> data;
  const UserActivityChartCard({super.key, required this.data});

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
                    LegendItem(color: Colors.blue, label: "New Register"),
                    SizedBox(width: 16),
                    LegendItem(color: Colors.orange, label: "Active Login"),
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

class LegendItem extends StatelessWidget {
  final Color color; final String label;
  const LegendItem({super.key, required this.color, required this.label});
  @override Widget build(BuildContext context) => Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))]);
}

class StatRow extends StatelessWidget {
  final String label; final String value;
  const StatRow({super.key, required this.label, required this.value});
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 4.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]));
}