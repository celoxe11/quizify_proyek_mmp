import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/repositories/admin_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/analytics/admin_analytics_bloc.dart';

// Import 2 file Layout
import './analytic_dekstop.dart';
import 'analytic_mobile.dart';

class AnalyticPageWrapper extends StatelessWidget {
  const AnalyticPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: AppColors.darkAzure,
        foregroundColor: Colors.white,
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

                      // SWITCH LAYOUT DISINI
                      if (isDesktop) 
                        AnalyticDesktopPage(data: state.analytics)
                      else 
                        AnalyticMobilePage(data: state.analytics),
                      
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