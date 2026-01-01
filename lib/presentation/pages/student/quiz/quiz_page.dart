import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/core/api/api_client.dart';
import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/data/repositories/student_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/quiz_session/quiz_session_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/quiz_session/quiz_session_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/quiz_session/quiz_session_state.dart';

class QuizPage extends StatefulWidget {
  final String sessionId;
  final String quizId;

  const QuizPage({super.key, required this.sessionId, required this.quizId});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuizSessionBloc(StudentRepository(ApiClient()))
        ..add(
          LoadQuizSessionEvent(
            sessionId: widget.sessionId,
            quizId: widget.quizId,
          ),
        ),
      child: BlocConsumer<QuizSessionBloc, QuizSessionState>(
        listener: (context, state) {
          if (state is QuizSessionEnded) {
            // Navigate to result page
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            // TODO: Navigate to QuizResultPage with sessionId
          } else if (state is QuizSessionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is QuizSessionLoading) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Loading Quiz...'),
                backgroundColor: const Color(0xFF007C89),
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is QuizSessionError) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Error'),
                backgroundColor: const Color(0xFF007C89),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Kembali'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is QuizSessionLoaded) {
            return _buildQuizContent(context, state);
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Quiz'),
              backgroundColor: const Color(0xFF007C89),
            ),
            body: const Center(child: Text('Initializing...')),
          );
        },
      ),
    );
  }

  Widget _buildQuizContent(BuildContext context, QuizSessionLoaded state) {
    final question = state.currentQuestion;
    final selectedAnswer = state.currentSelectedAnswer;
    final isSubmitted = state.isCurrentQuestionSubmitted;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Soal ${state.currentQuestionIndex + 1}/${state.totalQuestions}',
        ),
        backgroundColor: const Color(0xFF007C89),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => _showEndQuizDialog(context),
            child: const Text('Selesai', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (state.currentQuestionIndex + 1) / state.totalQuestions,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF007C89)),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question info
                  Row(
                    children: [
                      Chip(
                        label: Text(question.difficulty.toUpperCase()),
                        backgroundColor: _getDifficultyColor(
                          question.difficulty,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(question.type.toUpperCase()),
                        backgroundColor: const Color(0xFF63C5C5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Question text
                  Text(
                    question.questionText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Question image if exists
                  if (question.image != null) ...[
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        question.image!.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.image_not_supported),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Options
                  ...question.options.map((option) {
                    final isSelected = selectedAnswer == option;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: InkWell(
                        onTap: isSubmitted
                            ? null
                            : () {
                                context.read<QuizSessionBloc>().add(
                                  SelectAnswerEvent(
                                    questionId: question.id,
                                    answer: option,
                                  ),
                                );
                              },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF007C89)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF007C89)
                                  : Colors.grey[400]!,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 16,
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 24),

                  // Submit button
                  if (!isSubmitted && selectedAnswer != null)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<QuizSessionBloc>().add(
                            SubmitAnswerEvent(
                              questionId: question.id,
                              answer: selectedAnswer,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Submit Jawaban',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  if (isSubmitted)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Jawaban telah disubmit',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                if (!state.isFirstQuestion)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<QuizSessionBloc>().add(
                          const PreviousQuestionEvent(),
                        );
                      },
                      child: const Text('Sebelumnya'),
                    ),
                  ),
                if (!state.isFirstQuestion && !state.isLastQuestion)
                  const SizedBox(width: 16),
                if (!state.isLastQuestion)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<QuizSessionBloc>().add(
                          const NextQuestionEvent(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007C89),
                      ),
                      child: const Text('Selanjutnya'),
                    ),
                  ),
                if (state.isLastQuestion)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showEndQuizDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('Selesai Quiz'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showEndQuizDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Akhiri Quiz?'),
        content: const Text(
          'Apakah Anda yakin ingin mengakhiri quiz? Pastikan semua jawaban sudah disubmit.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<QuizSessionBloc>().add(const EndQuizSessionEvent());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Akhiri Quiz'),
          ),
        ],
      ),
    );
  }
}
