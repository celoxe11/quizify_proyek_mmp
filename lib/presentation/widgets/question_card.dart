// lib/widgets/question_card.dart
import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/question_model.dart';

class QuestionCard extends StatefulWidget {
  final int index;
  final QuestionModel question;
  final Function(QuestionModel) onUpdate;
  final VoidCallback onRemove;

  QuestionCard({
    Key? key,
    required this.index,
    required this.question,
    required this.onUpdate,
    required this.onRemove,
  }) : super(key: key);

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

enum RadioType { fillColor, backgroundColor, side, innerRadius }

class _QuestionCardState extends State<QuestionCard> {
  late TextEditingController _questionTextController;
  late List<TextEditingController> _optionControllers;
  int _selectedOptionIndex = -1;

  @override
  void initState() {
    super.initState();
    _questionTextController = TextEditingController(
      text: widget.question.questionText,
    );

    // Initialize option controllers based on question type
    if (widget.question.type == 'boolean') {
      _optionControllers = [
        'True',
        'False',
      ].map((text) => TextEditingController(text: text)).toList();
      // Set initial selected index for boolean
      if (widget.question.correctAnswer == 'True') {
        _selectedOptionIndex = 0;
      } else if (widget.question.correctAnswer == 'False') {
        _selectedOptionIndex = 1;
      }
    } else {
      _optionControllers = widget.question.options
          .map((option) => TextEditingController(text: option))
          .toList();
      // Set initial selected index for multiple choice
      _selectedOptionIndex = widget.question.options.indexOf(
        widget.question.correctAnswer,
      );
    }
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateQuestion() {
    final updatedOptions = _optionControllers
        .map((controller) => controller.text)
        .toList();

    widget.onUpdate(
      widget.question.copyWith(
        questionText: _questionTextController.text,
        options: updatedOptions,
      ),
    );
  }

  void _updateCorrectAnswer(int index) {
    setState(() {
      _selectedOptionIndex = index;
    });
    final answer = _optionControllers[index].text;
    widget.onUpdate(widget.question.copyWith(correctAnswer: answer));
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController(text: ''));
    });
    final updatedOptions = _optionControllers.map((c) => c.text).toList();
    widget.onUpdate(
      widget.question.copyWith(
        questionText: _questionTextController.text,
        options: updatedOptions,
      ),
    );
  }

  void _removeOption(int index) {
    if (_optionControllers.length <= 2) return; // Minimum 2 options
    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
      // Adjust selected index if needed
      if (_selectedOptionIndex == index) {
        _selectedOptionIndex = -1;
      } else if (_selectedOptionIndex > index) {
        _selectedOptionIndex--;
      }
    });
    final updatedOptions = _optionControllers.map((c) => c.text).toList();
    final newCorrectAnswer =
        _selectedOptionIndex >= 0 &&
            _selectedOptionIndex < updatedOptions.length
        ? updatedOptions[_selectedOptionIndex]
        : '';
    widget.onUpdate(
      widget.question.copyWith(
        questionText: _questionTextController.text,
        options: updatedOptions,
        correctAnswer: newCorrectAnswer,
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
                      widget.onUpdate(widget.question.copyWith(type: value));
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
              controller: _questionTextController,
              decoration: const InputDecoration(
                labelText: 'Question Text',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (_) => _updateQuestion(),
            ),
            const SizedBox(height: 12),

            // Options
            Text(
              'Options (Select the correct answer):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            if (widget.question.type == 'multiple') ...[
              Column(
                children: _optionControllers.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final controller = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Radio<int>(
                          value: idx,
                          groupValue: _selectedOptionIndex,
                          onChanged: (value) {
                            if (value != null) {
                              _updateCorrectAnswer(value);
                            }
                          },
                        ),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Option ${idx + 1}',
                              border: const OutlineInputBorder(),
                            ),
                            controller: controller,
                            onChanged: (text) {
                              // Update the correct answer if this option is selected
                              String newCorrectAnswer =
                                  _selectedOptionIndex == idx
                                  ? text
                                  : (_selectedOptionIndex >= 0 &&
                                            _selectedOptionIndex <
                                                _optionControllers.length
                                        ? _optionControllers[_selectedOptionIndex]
                                              .text
                                        : '');

                              final updatedOptions = _optionControllers
                                  .map((c) => c.text)
                                  .toList();

                              widget.onUpdate(
                                widget.question.copyWith(
                                  questionText: _questionTextController.text,
                                  options: updatedOptions,
                                  correctAnswer: newCorrectAnswer,
                                ),
                              );
                            },
                          ),
                        ),
                        if (_optionControllers.length > 2)
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _removeOption(idx),
                            tooltip: 'Remove option',
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _addOption,
                  icon: const Icon(Icons.add, color: AppColors.darkAzure),
                  label: const Text(
                    'Add Option',
                    style: TextStyle(color: AppColors.darkAzure),
                  ),
                ),
              ),
            ] else ...[
              // if the option is boolean only display two option without an add option button
              Column(
                children: [
                  RadioListTile(
                    value: 'true',
                    groupValue: widget.question.correctAnswer,
                    onChanged: (value) {
                      if (value != null) {
                        widget.onUpdate(
                          widget.question.copyWith(correctAnswer: value),
                        );
                      }
                    },
                    title: const Text('True'),
                  ),
                  RadioListTile(
                    value: 'false',
                    groupValue: widget.question.correctAnswer,
                    onChanged: (value) {
                      if (value != null) {
                        widget.onUpdate(
                          widget.question.copyWith(correctAnswer: value),
                        );
                      }
                    },
                    title: const Text('False'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
