import 'package:flutter/material.dart';

class AIGenerationDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onGenerate;

  const AIGenerationDialog({
    super.key,
    required this.onGenerate,
  });

  @override
  State<AIGenerationDialog> createState() => _AIGenerationDialogState();
}

class _AIGenerationDialogState extends State<AIGenerationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _categoryController = TextEditingController(text: 'General Knowledge');
  final _contextController = TextEditingController();
  final _avoidTopicsController = TextEditingController();

  String _type = 'multiple';
  String _difficulty = 'medium';
  String _language = 'id';
  String _ageGroup = 'SMA';
  String _questionStyle = 'formal';
  bool _includeExplanation = false;

  @override
  void dispose() {
    _topicController.dispose();
    _categoryController.dispose();
    _contextController.dispose();
    _avoidTopicsController.dispose();
    super.dispose();
  }

  void _handleGenerate() {
    if (_formKey.currentState!.validate()) {
      // Parse avoid topics from comma-separated string
      final avoidTopics = _avoidTopicsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final params = {
        'type': _type,
        'difficulty': _difficulty,
        'category': _categoryController.text,
        'topic': _topicController.text,
        'language': _language,
        'context': _contextController.text,
        'age_group': _ageGroup,
        'avoid_topics': avoidTopics,
        'include_explanation': _includeExplanation,
        'question_style': _questionStyle,
      };

      widget.onGenerate(params);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: const [
                  Icon(Icons.auto_awesome, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Generate Question with AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(Icons.stars, color: Colors.amber, size: 24),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'This is a premium feature. Generate questions automatically using AI.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),

                      // Question Type
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Question Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.question_answer),
                        ),
                        value: _type,
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
                          setState(() => _type = value!);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Difficulty
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Difficulty',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.speed),
                        ),
                        value: _difficulty,
                        items: const [
                          DropdownMenuItem(value: 'easy', child: Text('Easy')),
                          DropdownMenuItem(
                              value: 'medium', child: Text('Medium')),
                          DropdownMenuItem(value: 'hard', child: Text('Hard')),
                        ],
                        onChanged: (value) {
                          setState(() => _difficulty = value!);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category
                      TextFormField(
                        controller: _categoryController,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          hintText: 'e.g., Science, Math, History',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.category),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Category is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Topic
                      TextFormField(
                        controller: _topicController,
                        decoration: InputDecoration(
                          labelText: 'Topic or Subject',
                          hintText: 'e.g., World War 2, Photosynthesis',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.topic),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Language
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Language',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.language),
                        ),
                        value: _language,
                        items: const [
                          DropdownMenuItem(
                            value: 'id',
                            child: Text('Indonesian'),
                          ),
                          DropdownMenuItem(value: 'en', child: Text('English')),
                        ],
                        onChanged: (value) {
                          setState(() => _language = value!);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Age Group
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Age Group',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.school),
                        ),
                        value: _ageGroup,
                        items: const [
                          DropdownMenuItem(
                            value: 'SD',
                            child: Text('SD (Elementary)'),
                          ),
                          DropdownMenuItem(
                            value: 'SMP',
                            child: Text('SMP (Junior High)'),
                          ),
                          DropdownMenuItem(
                            value: 'SMA',
                            child: Text('SMA (Senior High)'),
                          ),
                          DropdownMenuItem(
                            value: 'Perguruan Tinggi',
                            child: Text('Perguruan Tinggi (University)'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _ageGroup = value!);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Question Style
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Question Style',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.style),
                        ),
                        value: _questionStyle,
                        items: const [
                          DropdownMenuItem(
                            value: 'formal',
                            child: Text('Formal'),
                          ),
                          DropdownMenuItem(
                            value: 'casual',
                            child: Text('Casual'),
                          ),
                          DropdownMenuItem(
                            value: 'scenario-based',
                            child: Text('Scenario-based'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _questionStyle = value!);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Context
                      TextFormField(
                        controller: _contextController,
                        decoration: InputDecoration(
                          labelText: 'Context (Optional)',
                          hintText:
                              'Provide additional context for the question',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.description),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                        maxLength: 5000,
                      ),
                      const SizedBox(height: 16),

                      // Avoid Topics
                      TextFormField(
                        controller: _avoidTopicsController,
                        decoration: InputDecoration(
                          labelText: 'Avoid Topics (Optional)',
                          hintText:
                              'Enter topics to avoid, separated by commas',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.block),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Include Explanation Checkbox
                      CheckboxListTile(
                        title: const Text('Include Explanation'),
                        subtitle: const Text(
                          'Generate explanation for the correct answer',
                        ),
                        value: _includeExplanation,
                        onChanged: (value) {
                          setState(() => _includeExplanation = value!);
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _handleGenerate,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Generate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
