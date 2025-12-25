import 'package:fl_chart/fl_chart.dart'; // WAJIB: Pastikan sudah install fl_chart
import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';

class AnalyticPage extends StatelessWidget {
  const AnalyticPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Analytics Overview',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkAzure,
        elevation: 0.5,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Cek apakah Desktop (> 900px)
          bool isDesktop = constraints.maxWidth > 900;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER ---
                const Text(
                  "Platform Statistics",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Monitor teacher activity, user engagement, and student performance.",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),

                // --- RESPONSIVE LAYOUT ---
                if (isDesktop) ...[
                  // [DESKTOP] Tampilkan Grafik Guru & Siswa berdampingan (Compact)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _SectionHeader(
                              title: "1. Teacher Activity",
                              subtitle: "Created vs Attempted",
                              icon: Icons.school,
                              color: Colors.blue,
                            ),
                            const SizedBox(height: 16),
                            const _TeacherActivityChartCard(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          children: [
                            _SectionHeader(
                              title: "3. Student Participation",
                              subtitle: "Submission rate",
                              icon: Icons.assignment_turned_in,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 16),
                            const _StudentPerformanceChartCard(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Grafik Login User (Full Width di bawah)
                  _SectionHeader(
                    title: "2. User Engagement",
                    subtitle: "Daily active users (Login History)",
                    icon: Icons.person_pin_circle,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(
                    height: 300, // Fixed height agar rapi di desktop
                    child: _UserLoginChartCard(),
                  ),
                ] else ...[
                  // [MOBILE] Tumpuk ke bawah (Vertical Stack)
                  _SectionHeader(
                    title: "1. Teacher Activity",
                    subtitle: "Questions Created vs. Quizzes Attempted",
                    icon: Icons.school,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  const _TeacherActivityChartCard(),

                  const SizedBox(height: 40),

                  _SectionHeader(
                    title: "2. User Engagement",
                    subtitle: "Daily active users (Login History)",
                    icon: Icons.person_pin_circle,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(
                    height: 250,
                    child: _UserLoginChartCard(),
                  ),

                  const SizedBox(height: 40),

                  _SectionHeader(
                    title: "3. Student Participation",
                    subtitle: "Submission rate over time",
                    icon: Icons.assignment_turned_in,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  const _StudentPerformanceChartCard(),
                ],

                const SizedBox(height: 40), // Bottom padding
              ],
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// WIDGETS KOMPONEN
// =============================================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }
}

// --- 1. BAR CHART (MANUAL VISUAL) ---
// --- 1. BAR CHART (INTERACTIVE WITH FL_CHART) ---
class _TeacherActivityChartCard extends StatelessWidget {
  const _TeacherActivityChartCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Legend / Keterangan Warna
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _LegendItem(color: Colors.blue, label: "Questions Created"),
                const SizedBox(width: 16),
                _LegendItem(color: Colors.purple, label: "Student Attempts"),
              ],
            ),
            const SizedBox(height: 32),
            
            // Grafik Batang Interaktif
            SizedBox(
              height: 250, // Tinggi Grafik
              child: BarChart(
                BarChartData(
                  // Mengatur interaksi sentuh/hover
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      // Warna background tooltip (kotak hitam transparan)
                      getTooltipColor: (group) => Colors.blueGrey.shade900.withOpacity(0.9),
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      // Mengatur isi teks saat di-hover
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String teacherName = _getTeacherName(groupIndex);
                        
                        // Batang Biru (Questions Created)
                        if (rodIndex == 0) {
                          return BarTooltipItem(
                            '$teacherName\n',
                            const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Created: ${rod.toY.toInt()} Qs',
                                style: const TextStyle(
                                  color: Colors.lightBlueAccent, fontSize: 12, fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        } 
                        // Batang Ungu (Attempts - Detail Benar/Salah)
                        else {
                          // Simulasi data detail (Nanti ambil dari API)
                          // Anggaplah 70% Benar, 30% Salah dari total attempt
                          int total = rod.toY.toInt();
                          int correct = (total * 0.7).toInt();
                          int wrong = total - correct;

                          return BarTooltipItem(
                            '$teacherName\n',
                            const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14,
                            ),
                            children: <TextSpan>[
                              const TextSpan(
                                text: 'Total Attempts: ',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              TextSpan(
                                text: '$total\n',
                                style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(
                                text: '✔ Correct: ',
                                style: TextStyle(color: Colors.greenAccent, fontSize: 12),
                              ),
                              TextSpan(
                                text: '$correct\n',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                              const TextSpan(
                                text: '✖ Wrong: ',
                                style: TextStyle(color: Colors.redAccent, fontSize: 12),
                              ),
                              TextSpan(
                                text: '$wrong',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    // Label Bawah (Nama Guru)
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => _bottomTitles(value, meta),
                        reservedSize: 42,
                      ),
                    ),
                    // Label Kiri (Angka)
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 5, // Kelipatan angka di sumbu Y
                        getTitlesWidget: (value, meta) {
                          if (value % 5 != 0) return const SizedBox.shrink();
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(color: Colors.grey, fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5, // Garis bantu setiap kelipatan 5
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade100,
                      strokeWidth: 1,
                    ),
                  ),
                  // DATA GRAFIK (Nanti diganti data API)
                  barGroups: [
                    _makeGroupData(0, 12, 18), // Guru A: 12 Soal, 18 Dikerjakan
                    _makeGroupData(1, 8, 25),  // Guru B
                    _makeGroupData(2, 15, 10), // Guru C
                    _makeGroupData(3, 20, 30), // Guru D
                    _makeGroupData(4, 10, 15), // Guru E
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi Helper untuk membuat Data Batang
  BarChartGroupData _makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: Colors.blue,
          width: 12,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
        ),
        BarChartRodData(
          toY: y2,
          color: Colors.purple,
          width: 12,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
        ),
      ],
    );
  }

  // Label Bawah (Nama Guru)
  Widget _bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12,
    );
    
    String text = _getTeacherName(value.toInt());

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(text, style: style),
    );
  }

  // Helper mapping index ke nama guru
  String _getTeacherName(int index) {
    switch (index) {
      case 0: return 'Mr. A';
      case 1: return 'Mrs. B';
      case 2: return 'Mr. C';
      case 3: return 'Ms. D';
      case 4: return 'Mr. E';
      default: return '';
    }
  }
}

// --- 2. LINE CHART (REAL FL_CHART) ---
class _UserLoginChartCard extends StatelessWidget {
  const _UserLoginChartCard();

  @override
  Widget build(BuildContext context) {
    // Data Dummy untuk grafik (Senin - Minggu)
    final List<FlSpot> spots = [
      const FlSpot(0, 30), // Mon
      const FlSpot(1, 50), // Tue
      const FlSpot(2, 45), // Wed
      const FlSpot(3, 80), // Thu
      const FlSpot(4, 95), // Fri
      const FlSpot(5, 60), // Sat
      const FlSpot(6, 40), // Sun
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 24, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Header di dalam Card
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Login History (7 Days)",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("+15% Increase",
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 24),
            
            // --- FL CHART IMPLEMENTATION ---
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade100,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        // [FIX] Cukup masukkan nama fungsinya saja
                        // Dart akan otomatis mencocokkan parameter (value, meta)
                        getTitlesWidget: bottomTitleWidgets, 
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        // [FIX] Sama, cukup nama fungsinya
                        getTitlesWidget: leftTitleWidgets,
                        reservedSize: 42,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      gradient: const LinearGradient(
                        colors: [Colors.orange, Colors.orangeAccent],
                      ),
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.withOpacity(0.3),
                            Colors.orange.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
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

  // [FIX] Pastikan signature fungsi menerima (double value, TitleMeta meta)
  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 0: text = const Text('Mon', style: style); break;
      case 1: text = const Text('Tue', style: style); break;
      case 2: text = const Text('Wed', style: style); break;
      case 3: text = const Text('Thu', style: style); break;
      case 4: text = const Text('Fri', style: style); break;
      case 5: text = const Text('Sat', style: style); break;
      case 6: text = const Text('Sun', style: style); break;
      default: text = const Text('', style: style); break;
    }
    
    // Gunakan SideTitleWidget untuk positioning yang pas
    return Padding(
      padding: const EdgeInsets.only(top: 8.0), 
      child: text,
    );

  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String text;
    if (value == 0) {
      text = '0';
    } else if (value == 100) {
      text = '100+';
    } else {
      text = '${value.toInt()}';
    }
    
    return Text(text, style: style, textAlign: TextAlign.left);
  }
}
// --- 3. PROGRESS CHART ---
class _StudentPerformanceChartCard extends StatelessWidget {
  const _StudentPerformanceChartCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            SizedBox(
              height: 120,
              width: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const CircularProgressIndicator(
                    value: 0.75,
                    strokeWidth: 12,
                    backgroundColor: Color(0xFFE0E0E0),
                    color: Colors.green,
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("75%",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        Text("Active",
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey[600])),
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
                  const Text("Submission Rate",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _StatRow(label: "Total Students", value: "1,204"),
                  const Divider(),
                  _StatRow(label: "Quiz Submitted", value: "856"),
                  const Divider(),
                  _StatRow(label: "Pending", value: "348"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Helper Widgets Kecil ---

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _BarItem extends StatelessWidget {
  final String label;
  final double value1; // 0.0 - 1.0
  final double value2; // 0.0 - 1.0

  const _BarItem(
      {required this.label, required this.value1, required this.value2});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 16,
              height: 150 * value1,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(width: 4),
            Container(
              width: 16,
              height: 150 * value2,
              decoration: BoxDecoration(
                  color: Colors.purple, borderRadius: BorderRadius.circular(4)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}