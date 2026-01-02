import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/student_history_model.dart';
import 'package:quizify_proyek_mmp/data/repositories/student_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/history/student_history_bloc.dart'; 

class StudentHistoryPage extends StatelessWidget {
  const StudentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Bloc
    return BlocProvider(
      create: (context) => StudentHistoryBloc(
        context.read<StudentRepository>(),
      )..add(LoadStudentHistory()),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'Quiz History',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkAzure),
          ),
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: AppColors.darkAzure),
        ),
        body: BlocBuilder<StudentHistoryBloc, StudentHistoryState>(
          builder: (context, state) {
            if (state is StudentHistoryLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.darkAzure));
            }
            if (state is StudentHistoryError) {
              return Center(child: Text("Error: ${state.message}"));
            }
            if (state is StudentHistoryLoaded) {
              if (state.history.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _HistoryCard(history: state.history[index]);
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No quiz history yet.",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final StudentHistoryModel history;

  const _HistoryCard({required this.history});

  // --- FUNGSI FORMAT TANGGAL MANUAL (TANPA INTL) ---
  String _formatDate(DateTime date) {
    // Daftar nama bulan singkat
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    final day = date.day;
    final month = months[date.month - 1]; // Array index mulai dari 0
    final year = date.year;
    
    // PadLeft memastikan jam/menit selalu 2 digit (misal: 09:05)
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    // Format: 12 Dec 2024, 14:30
    return '$day $month $year, $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan fungsi manual di atas
    final dateStr = _formatDate(history.finishedAt);
    
    // Warna Skor (Hijau jika >= 70, Merah jika < 50)
    Color scoreColor = history.score >= 70 
        ? Colors.green 
        : (history.score < 50 ? Colors.red : Colors.orange);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigasi ke Detail Jawaban (Jika fitur review sudah ada)
          // context.push('/student/history/${history.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 1. CIRCLE SCORE
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: scoreColor.withOpacity(0.3), width: 4),
                  color: scoreColor.withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    "${history.score}",
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      color: scoreColor
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),

              // 2. INFO QUIZ & STATS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      history.quizTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 8),
                    
                    // Stats Row (Benar / Salah)
                    Row(
                      children: [
                        _buildStatPill(
                          icon: Icons.check_circle, 
                          color: Colors.green, 
                          text: "${history.correct}"
                        ),
                        const SizedBox(width: 8),
                        _buildStatPill(
                          icon: Icons.cancel, 
                          color: Colors.red, 
                          text: "${history.incorrect}"
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. ACTION BUTTON (Detail)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  const SizedBox(height: 4),
                  Text(
                    "Detail",
                    style: TextStyle(fontSize: 10, color: AppColors.darkAzure.withOpacity(0.7)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatPill({required IconData icon, required Color color, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}