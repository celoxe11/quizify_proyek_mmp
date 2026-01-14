import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/history_detail_model.dart';
import 'package:quizify_proyek_mmp/data/repositories/student_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/history_detail/history_detail_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/history_detail/history_detail_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/history_detail/history_detail_state.dart';
import 'package:quizify_proyek_mmp/presentation/widgets/gemini_evaluation_dialog.dart';
import 'package:quizify_proyek_mmp/presentation/widgets/question_review_card.dart';

class HistoryDetailPage extends StatelessWidget {
  final String sessionId;

  const HistoryDetailPage({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HistoryDetailBloc(context.read<StudentRepository>())
            ..add(LoadHistoryDetail(sessionId)),
      child: BlocListener<HistoryDetailBloc, HistoryDetailState>(
        listenWhen: (previous, current) {
          // Only listen when transitioning TO evaluation loaded/error states
          return (previous is! HistoryDetailGeminiEvaluationLoaded &&
                  current is HistoryDetailGeminiEvaluationLoaded) ||
              (previous is! HistoryDetailGeminiEvaluationError &&
                  current is HistoryDetailGeminiEvaluationError);
        },
        listener: (context, state) {
          if (state is HistoryDetailGeminiEvaluationLoaded) {
            showDialog(
              context: context,
              builder: (context) =>
                  GeminiEvaluationDialog(evaluation: state.evaluation),
            );
          } else if (state is HistoryDetailGeminiEvaluationError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text(
              'Review Quiz',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.darkAzure,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0.5,
            iconTheme: const IconThemeData(color: AppColors.darkAzure),
          ),
          body: BlocBuilder<HistoryDetailBloc, HistoryDetailState>(
            builder: (context, state) {
              if (state is HistoryDetailLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.darkAzure),
                );
              }
              if (state is HistoryDetailError) {
                return Center(child: Text("Error: ${state.message}"));
              }

              // Extract data from any loaded state
              HistoryDetailModel? data;
              if (state is HistoryDetailLoaded) {
                data = state.data;
              } else if (state is HistoryDetailGeminiEvaluationLoading) {
                data = state.data;
              } else if (state is HistoryDetailGeminiEvaluationLoaded) {
                data = state.data;
              } else if (state is HistoryDetailGeminiEvaluationError) {
                data = state.data;
              }

              if (data != null) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // HEADER: SKOR & INFO
                    _buildHeader(data),
                    const SizedBox(height: 24),

                    // DAFTAR SOAL
                    ...data.details.asMap().entries.map((entry) {
                      return QuestionReviewCard(
                        index: entry.key + 1,
                        question: entry.value,
                      );
                    }),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(HistoryDetailModel data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.darkAzure, AppColors.darkAzure],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkAzure.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.quizTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Finished: ${data.finishedAt.toString().substring(0, 16)}",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "${data.score}",
              style: const TextStyle(
                color: AppColors.darkAzure,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
