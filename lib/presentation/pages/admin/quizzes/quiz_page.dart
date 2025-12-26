import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quizify_proyek_mmp/core/api/api_client.dart';
import 'package:quizify_proyek_mmp/core/api/quiz/quiz_api.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';
import 'quiz_mobile.dart';
import 'quiz_desktop.dart';

class AdminQuizPage extends StatefulWidget {
  const AdminQuizPage({super.key});

  @override
  State<AdminQuizPage> createState() => _AdminQuizPageState();
}

class _AdminQuizPageState extends State<AdminQuizPage> {
  late final QuizApi _quizApi;
  late Future<List<QuizModel>> _futureQuizzes;

  @override
  void initState() {
    super.initState();
    // Inisialisasi API (Bisa diganti Bloc nanti jika mau seragam)
    _quizApi = QuizApi(ApiClient());
    _futureQuizzes = _quizApi.getAllQuizzes();
  }

  void _refreshData() {
    setState(() {
      _futureQuizzes = _quizApi.getAllQuizzes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Background konsisten
      appBar: AppBar(
        title: const Text(
          'Manage Quizzes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.darkAzure, // Warna AppBar Konsisten
        foregroundColor: Colors.white, // Teks Putih
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: FutureBuilder<List<QuizModel>>(
        future: _futureQuizzes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.darkAzure));
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _refreshData, child: const Text("Retry"))
                ],
              ),
            );
          }

          final quizzes = snapshot.data ?? [];

          if (quizzes.isEmpty) {
            return const Center(child: Text("No quizzes found. Create one!"));
          }

          // --- RESPONSIVE LAYOUT SWITCHER ---
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return AdminQuizDesktopPage(quizzes: quizzes);
              } else {
                return AdminQuizMobilePage(quizzes: quizzes);
              }
            },
          );
        },
      ),
      // Tombol Tambah Quiz
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Sesuaikan route dengan main.dart kamu
          context.go('/admin/quizz/create'); 
        },
        backgroundColor: AppColors.darkAzure,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Create Quiz"),
      ),
    );
  }
}