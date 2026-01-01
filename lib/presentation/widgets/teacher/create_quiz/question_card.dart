// lib/widgets/question_card.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/domain/entities/question_image.dart';

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
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _questionTextController = TextEditingController(
      text: widget.question.questionText,
    );

    // Load existing image if available (local path stored in imageUrl for new uploads)
    if (widget.question.image != null &&
        (widget.question.image!.imageUrl.startsWith('/') ||
            widget.question.image!.imageUrl.contains(':'))) {
      // Local file path
      _selectedImage = File(widget.question.image!.imageUrl);
    }

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

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // For web, we need to read bytes and convert to base64
        // For mobile, we store the file path
        String imageData;

        if (kIsWeb) {
          // Web: Read bytes and convert to base64
          final bytes = await pickedFile.readAsBytes();
          final base64Image = base64Encode(bytes);
          imageData = 'data:image/png;base64,$base64Image';
        } else {
          // Mobile: Store file path
          imageData = pickedFile.path;
          setState(() {
            _selectedImage = File(pickedFile.path);
          });
        }

        // Store as temporary QuestionImage with image data
        final tempQuestionImage = QuestionImage(
          id: 0, // Temporary ID, will be assigned by backend
          userId: '', // Will be filled when uploading
          questionId: widget.question.id,
          imageUrl: imageData, // Store base64 for web or path for mobile
          uploadedAt: DateTime.now(),
        );

        widget.onUpdate(widget.question.copyWith(image: tempQuestionImage));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image selected! Will be uploaded when saving quiz.'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
    widget.onUpdate(widget.question.copyWith(image: QuestionImage.empty));
  }

  Widget _buildWebImage() {
    final imageUrl = widget.question.image?.imageUrl ?? '';

    // Check if it's a base64 encoded image
    if (imageUrl.startsWith('data:image')) {
      // Extract the base64 data
      final base64Data = imageUrl.split(',').last;
      final bytes = base64Decode(base64Data);
      return Image.memory(
        bytes,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else if (imageUrl.startsWith('http')) {
      // It's a URL
      return Image.network(
        imageUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey.shade300,
            child: const Center(child: Text('Failed to load image')),
          );
        },
      );
    } else {
      // Fallback
      return Container(
        height: 200,
        color: Colors.grey.shade300,
        child: const Center(child: Text('Image preview unavailable')),
      );
    }
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

            // Image upload section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Question Image (Optional)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.add_photo_alternate, size: 20),
                        label: const Text('Upload Image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkAzure,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (_selectedImage != null ||
                      (kIsWeb &&
                          widget.question.image != null &&
                          widget.question.image!.imageUrl.isNotEmpty)) ...[
                    const SizedBox(height: 12),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: kIsWeb
                              ? _buildWebImage()
                              : Image.file(
                                  _selectedImage!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            onPressed: _removeImage,
                            icon: const Icon(Icons.close),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
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
                    value: 'True',
                    groupValue: widget.question.correctAnswer,
                    onChanged: (value) {
                      if (value != null) {
                        widget.onUpdate(
                          widget.question.copyWith(
                            correctAnswer: value,
                            options: ['True', 'False'],
                          ),
                        );
                      }
                    },
                    title: const Text('True'),
                  ),
                  RadioListTile(
                    value: 'False',
                    groupValue: widget.question.correctAnswer,
                    onChanged: (value) {
                      if (value != null) {
                        widget.onUpdate(
                          widget.question.copyWith(
                            correctAnswer: value,
                            options: ['True', 'False'],
                          ),
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
