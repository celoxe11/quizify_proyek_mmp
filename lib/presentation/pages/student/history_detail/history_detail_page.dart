import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/history_detail_model.dart';
import 'package:quizify_proyek_mmp/data/repositories/student_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/history_detail/history_detail_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/history_detail/history_detail_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/history_detail/history_detail_state.dart';

class HistoryDetailPage extends StatelessWidget {
  final String sessionId;

  const HistoryDetailPage({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HistoryDetailBloc(
        context.read<StudentRepository>(),
      )..add(LoadHistoryDetail(sessionId)),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Review Quiz', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkAzure)),
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: AppColors.darkAzure),
        ),
        body: BlocBuilder<HistoryDetailBloc, HistoryDetailState>(
          builder: (context, state) {
            if (state is HistoryDetailLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.darkAzure));
            }
            if (state is HistoryDetailError) {
              return Center(child: Text("Error: ${state.message}"));
            }
            if (state is HistoryDetailLoaded) {
              final data = state.data;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // HEADER: SKOR & INFO
                  _buildHeader(data),
                  const SizedBox(height: 24),
                  
                  // DAFTAR SOAL
                  ...data.details.asMap().entries.map((entry) {
                    return _QuestionReviewCard(index: entry.key + 1, question: entry.value);
                  }).toList(),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildHeader(HistoryDetailModel data) {
    return Card(
      elevation: 0,
      color: AppColors.darkAzure,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.quizTitle, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("Finished: ${data.finishedAt.toString().substring(0, 16)}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Text(
                "${data.score}",
                style: const TextStyle(color: AppColors.darkAzure, fontSize: 24, fontWeight: FontWeight.w900),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _QuestionReviewCard extends StatelessWidget {
  final int index;
  final QuestionReview question;

  const _QuestionReviewCard({required this.index, required this.question});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Soal
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: question.isCorrect ? Colors.green : Colors.red,
                  child: Icon(question.isCorrect ? Icons.check : Icons.close, size: 14, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Text("Question $index", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const Spacer(),
                // Badge Difficulty
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                  child: Text(question.difficulty.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 12),
            Text(question.questionText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            
            // OPTIONS LIST
            ...question.options.map((option) {
              return _buildOptionItem(option);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(String optionText) {
    bool isSelected = optionText == question.userAnswer;
    bool isCorrectAnswer = optionText == question.correctAnswer;

    Color bgColor = Colors.white;
    Color borderColor = Colors.grey.shade300;
    IconData? icon;
    Color iconColor = Colors.transparent;

    // LOGIKA WARNA
    if (isCorrectAnswer) {
      // Jawaban Benar (Selalu Hijau)
      bgColor = Colors.green.shade50;
      borderColor = Colors.green;
      icon = Icons.check_circle;
      iconColor = Colors.green;
    } else if (isSelected && !question.isCorrect) {
      // Jawaban User Salah (Merah)
      bgColor = Colors.red.shade50;
      borderColor = Colors.red;
      icon = Icons.cancel;
      iconColor = Colors.red;
    } else if (isSelected && question.isCorrect) {
       // User Benar (Sudah tercover di if pertama, tapi untuk safety)
       bgColor = Colors.green.shade50;
       borderColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              optionText,
              style: TextStyle(
                fontWeight: isSelected || isCorrectAnswer ? FontWeight.bold : FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ),
          if (icon != null) Icon(icon, color: iconColor, size: 20),
        ],
      ),
    );
  }
}