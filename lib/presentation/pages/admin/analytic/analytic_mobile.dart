import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/data/models/admin_analytics_model.dart';
import 'analytic_widgets.dart'; // Import Widget Helper

class AnalyticMobilePage extends StatelessWidget {
  final AdminAnalyticsModel data;

  const AnalyticMobilePage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(title: "1. Teacher Category Trends", subtitle: "Top Subject Areas", icon: Icons.school, color: Colors.blue),
        const SizedBox(height: 16),
        TeacherCategoryChartCard(data: data.teacherTrends),
        
        const SizedBox(height: 40),
        
        const SectionHeader(title: "2. Student Participation", subtitle: "Submission rate", icon: Icons.assignment_turned_in, color: Colors.green),
        const SizedBox(height: 16),
        StudentPerformanceChartCard(data: data.studentParticipation),
        
        const SizedBox(height: 40),
        
        const SectionHeader(title: "3. Quiz Flow Analysis", subtitle: "Difficulty vs Failures", icon: Icons.graphic_eq, color: Colors.purple),
        const SizedBox(height: 16),
        SizedBox(height: 300, child: QuizFlowChartCard(data: data.quizFlow)),
        
        const SizedBox(height: 40),
        
        const SectionHeader(title: "4. User Activity", subtitle: "Registrations vs Logins", icon: Icons.ssid_chart, color: Colors.orange),
        const SizedBox(height: 16),
        SizedBox(height: 300, child: UserActivityChartCard(data: data.userActivity)),
      ],
    );
  }
}