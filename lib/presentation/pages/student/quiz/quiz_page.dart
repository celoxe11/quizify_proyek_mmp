import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';

class QuizPage extends StatefulWidget {
  final QuizModel? quiz;
  final String? sessionId;

  const QuizPage({super.key, this.quiz, this.sessionId})
    : assert(
        quiz != null || sessionId != null,
        'Either quiz or sessionId must be provided',
      );

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz?.title ?? 'Quiz'),
        backgroundColor: const Color(0xFF007C89),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.sessionId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Session ID: ${widget.sessionId}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            if (widget.quiz != null) ...[
              Text(
                widget.quiz!.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (widget.quiz!.description != null)
                Text(
                  widget.quiz!.description!,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              const SizedBox(height: 16),
              if (widget.quiz!.category != null)
                Chip(
                  label: Text(widget.quiz!.category!),
                  backgroundColor: const Color(0xFF63C5C5),
                ),
            ],
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Quiz content will be displayed here',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
