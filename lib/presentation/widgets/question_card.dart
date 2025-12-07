// lib/widgets/question_card.dart
import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/question_model.dart';

class QuestionCard extends StatefulWidget {
  final int index;
  final QuestionModel question;
  final Function(QuestionModel) onUpdate;
  final VoidCallback onRemove;

  const QuestionCard({
    super.key,
    required this.index,
    required this.question,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  late TextEditingController _questionController;
  late TextEditingController _correctAnswerController;
  late List<TextEditingController> _incorrectControllers = [];

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(
      text: widget.question.questionText,
    );
    _correctAnswerController = TextEditingController(
      text: widget.question.correctAnswer,
    );

    final incorrectAnswers = widget.question.options
        .where((opt) => opt != widget.question.correctAnswer)
        .toList();

    final int targetCount = widget.question.type == 'boolean' ? 1 : 3;

    while (incorrectAnswers.length < targetCount) {
      incorrectAnswers.add('');
    }

    if (incorrectAnswers.length > targetCount) {
      incorrectAnswers.removeRange(targetCount, incorrectAnswers.length);
    }

    _incorrectControllers = incorrectAnswers
        .map((ans) => TextEditingController(text: ans))
        .toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final allOptions = [_correctAnswerController.text, ...incorrectAnswers];
      widget.onUpdate(widget.question.copyWith(options: allOptions));
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    _correctAnswerController.dispose();
    for (var controller in _incorrectControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateQuestion() {
    // Combine correct answer with incorrect answers to create options list
    final incorrectAnswers = _incorrectControllers.map((c) => c.text).toList();
    final allOptions = [_correctAnswerController.text, ...incorrectAnswers];

    widget.onUpdate(
      widget.question.copyWith(
        questionText: _questionController.text,
        correctAnswer: _correctAnswerController.text,
        options: allOptions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${widget.index + 1}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkAzure,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onRemove,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Type selector
            Row(
              children: [
                const Text('Type: '),
                DropdownButton<String>(
                  value: widget.question.type,
                  items: const [
                    DropdownMenuItem(
                      value: 'multiple',
                      child: Text('Multiple Choice'),
                    ),
                    DropdownMenuItem(
                      value: 'boolean',
                      child: Text('True/False'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      final incorrectAnswers = value == 'boolean'
                          ? [''] // Only 1 incorrect answer for boolean
                          : ['', '', '']; // 3 incorrect answers for multiple
                      final allOptions = [
                        _correctAnswerController.text,
                        ...incorrectAnswers,
                      ];
                      widget.onUpdate(
                        widget.question.copyWith(
                          type: value,
                          options: allOptions,
                        ),
                      );
                      setState(() {
                        _incorrectControllers = incorrectAnswers
                            .map((ans) => TextEditingController(text: ans))
                            .toList();
                      });
                    }
                  },
                ),
                const SizedBox(width: 20),
                const Text('Difficulty: '),
                DropdownButton<String>(
                  value: widget.question.difficulty,
                  items: const [
                    DropdownMenuItem(value: 'easy', child: Text('Easy')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'hard', child: Text('Hard')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      widget.onUpdate(
                        widget.question.copyWith(difficulty: value),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Question text
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Question Text',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (_) => _updateQuestion(),
            ),
            const SizedBox(height: 12),

            // Correct answer
            TextField(
              controller: _correctAnswerController,
              decoration: InputDecoration(
                labelText: widget.question.type == 'boolean'
                    ? 'Correct Answer (True/False)'
                    : 'Correct Answer',
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => _updateQuestion(),
            ),
            const SizedBox(height: 12),

            // Incorrect answers
            Text(
              'Incorrect Answers:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...List.generate(_incorrectControllers.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: _incorrectControllers[i],
                  decoration: InputDecoration(
                    labelText: 'Wrong Answer ${i + 1}',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => _updateQuestion(),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
