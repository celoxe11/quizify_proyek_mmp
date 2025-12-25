import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/quiz_detail/admin_quiz_detail_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/pages/admin/quiz_detail/quiz_dekstop.dart';

// Import file Mobile & Desktop yang baru dibuat
import 'quiz_mobile.dart';

class AdminQuizDetailPage extends StatefulWidget {
  final String quizId;
  final String quizTitle;

  const AdminQuizDetailPage({
    super.key,
    required this.quizId,
    required this.quizTitle,
  });

  @override
  State<AdminQuizDetailPage> createState() => _AdminQuizDetailPageState();
}

class _AdminQuizDetailPageState extends State<AdminQuizDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminQuizDetailBloc>().add(LoadAdminQuizDetail(widget.quizId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.quizTitle, 
          style: const TextStyle(fontWeight: FontWeight.bold)
        ),
        backgroundColor: AppColors.darkAzure,
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: BlocBuilder<AdminQuizDetailBloc, AdminQuizDetailState>(
        builder: (context, state) {
          if (state is AdminQuizDetailLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.darkAzure)
            );
          } else if (state is AdminQuizDetailError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is AdminQuizDetailLoaded) {
            if (state.questions.isEmpty) {
              return const Center(child: Text("This quiz has no questions yet."));
            }

            // --- RESPONSIVE LAYOUT BUILDER ---
            return LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  // > 900px anggap Desktop/Tablet Landscape
                  return AdminQuizDetailDesktop(
                    questions: state.questions,
                    quizId: widget.quizId, 
                  );
                } else {
                  // < 900px anggap Mobile/Tablet Portrait
                  return AdminQuizDetailMobile(
                    questions: state.questions,
                    quizId: widget.quizId,
                  );
                }
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}