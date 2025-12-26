import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/domain/entities/question.dart';
// Import file mobile untuk menggunakan QuestionCard
import 'quiz_mobile.dart'; 

class AdminQuizDetailDesktop extends StatelessWidget {
  final String quizId;
  final List<Question> questions;

  const AdminQuizDetailDesktop({
    super.key, 
    required this.questions, 
    required this.quizId
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // Jika layar sangat lebar (>1200px), pakai 3 kolom, jika tidak 2 kolom
    int crossAxisCount = screenWidth > 1200 ? 3 : 2;

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        // Tinggi card disesuaikan agar konten tidak overflow
        mainAxisExtent: 220, 
      ),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        // Reuse widget QuestionCard dari file mobile
        return QuestionCard(
          index: index,
          question: questions[index],
          quizId: quizId,
        );
      },
    );
  }
}