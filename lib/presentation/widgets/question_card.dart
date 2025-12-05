import 'package:flutter/material.dart';

class QuestionCard extends StatefulWidget {
  const QuestionCard({super.key});

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  String? _questionType = 'multiple_choice';
  String? _difficulty = 'easy';
  String? _selectedAnswer;
  final List<String> _answers = [];
  final TextEditingController _answerController = TextEditingController();

  void _addAnswer() {
    if (_answerController.text.isNotEmpty) {
      setState(() {
        _answers.add(_answerController.text);
        _answerController.clear();
      });
    }
  }

  void _removeAnswer(int index) {
    setState(() {
      _answers.removeAt(index);
      if (_selectedAnswer == _answers.elementAtOrNull(index)) {
        _selectedAnswer = null;
      }
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Text Input
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Question Text',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              maxLines: null,
            ),
          ),
          const Divider(height: 1),

          // Question Type and Difficulty Row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Question Type Dropdown
                Expanded(
                  child: DropdownMenu<String>(
                    initialSelection: _questionType,
                    onSelected: (value) {
                      setState(() {
                        _questionType = value;
                        _selectedAnswer = null;
                        if (value == 'true_false') {
                          _answers.clear();
                        }
                      });
                    },
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(
                        value: 'multiple_choice',
                        label: 'Multiple Choice',
                      ),
                      DropdownMenuEntry(
                        value: 'true_false',
                        label: 'True/False',
                      ),
                    ],
                    label: const Text('Question Type'),
                  ),
                ),
                const SizedBox(width: 16),

                // Difficulty Dropdown
                Expanded(
                  child: DropdownMenu<String>(
                    initialSelection: _difficulty,
                    onSelected: (value) {
                      setState(() {
                        _difficulty = value;
                      });
                    },
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(value: 'easy', label: 'Easy'),
                      DropdownMenuEntry(value: 'medium', label: 'Medium'),
                      DropdownMenuEntry(value: 'hard', label: 'Hard'),
                    ],
                    label: const Text('Difficulty'),
                  ),
                ),

                // Delete Button
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Handle delete action
                  },
                  tooltip: 'Delete Question',
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Answer Options Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Answer Options',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // True/False Options
                if (_questionType == 'true_false') ...[
                  _buildAnswerOption('True', 'true'),
                  const SizedBox(height: 8),
                  _buildAnswerOption('False', 'false'),
                ] else ...[
                  // Multiple Choice Answers
                  ..._answers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final answer = entry.value;
                    return Column(
                      children: [
                        _buildAnswerOption(
                          answer,
                          answer,
                          onDelete: () {
                            _removeAnswer(index);
                          },
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  }),

                  // Add Answer Input
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _answerController,
                            decoration: const InputDecoration(
                              hintText: 'Enter new answer',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onSubmitted: (_) => _addAnswer(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.green),
                          onPressed: _addAnswer,
                          tooltip: 'Add Answer',
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOption(
    String label,
    String value, {
    VoidCallback? onDelete,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _selectedAnswer == value ? Colors.blue : Colors.grey[300]!,
          width: _selectedAnswer == value ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(4),
        color: _selectedAnswer == value ? Colors.blue.withOpacity(0.05) : null,
      ),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: _selectedAnswer,
            onChanged: (newValue) {
              setState(() {
                _selectedAnswer = newValue;
              });
            },
          ),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[800], fontSize: 14),
            ),
          ),
          if (onDelete != null && _questionType == 'multiple_choice')
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red, size: 18),
              onPressed: onDelete,
              tooltip: 'Remove Answer',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
          else
            const SizedBox(width: 8),
        ],
      ),
    );
  }
}
