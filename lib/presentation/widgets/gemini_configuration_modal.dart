import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';

class GeminiConfigurationModal extends StatefulWidget {
  final String initialLanguage;
  final bool initialDetailedFeedback;
  final String initialQuestionType;
  final Function(String language, bool detailedFeedback, String questionType)
  onConfirm;

  const GeminiConfigurationModal({
    super.key,
    this.initialLanguage = 'id',
    this.initialDetailedFeedback = true,
    required this.initialQuestionType,
    required this.onConfirm,
  });

  // Bottom sheet variant
  static Widget buildAsSheet(
    BuildContext context, {
    required String initialLanguage,
    required bool initialDetailedFeedback,
    required String initialQuestionType,
    required Function(
      String language,
      bool detailedFeedback,
      String questionType,
    )
    onConfirm,
  }) {
    return _GeminiConfigurationSheet(
      initialLanguage: initialLanguage,
      initialDetailedFeedback: initialDetailedFeedback,
      initialQuestionType: initialQuestionType,
      onConfirm: onConfirm,
    );
  }

  @override
  State<GeminiConfigurationModal> createState() =>
      _GeminiConfigurationModalState();
}

class _GeminiConfigurationModalState extends State<GeminiConfigurationModal> {
  late String selectedLanguage;
  late bool detailedFeedback;
  late String selectedQuestionType;

  @override
  void initState() {
    super.initState();
    selectedLanguage = widget.initialLanguage;
    detailedFeedback = widget.initialDetailedFeedback;
    selectedQuestionType = widget.initialQuestionType;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: _buildHeader(),
      content: _buildContent(),
      actions: _buildActions(context),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.darkAzure.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.settings,
            color: AppColors.darkAzure,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Gemini Evaluation Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Language Selection
          const Text(
            'Language',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Row(
                    children: [
                      Text('🇮🇩'),
                      SizedBox(width: 8),
                      Text('Bahasa Indonesia'),
                    ],
                  ),
                  value: 'id',
                  groupValue: selectedLanguage,
                  activeColor: AppColors.darkAzure,
                  onChanged: (value) {
                    setState(() => selectedLanguage = value!);
                  },
                ),
                Divider(height: 1, color: Colors.grey.shade300),
                RadioListTile<String>(
                  title: const Row(
                    children: [
                      Text('🇬🇧'),
                      SizedBox(width: 8),
                      Text('English'),
                    ],
                  ),
                  value: 'en',
                  groupValue: selectedLanguage,
                  activeColor: AppColors.darkAzure,
                  onChanged: (value) {
                    setState(() => selectedLanguage = value!);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Detailed Feedback Toggle
          const Text(
            'Feedback Detail',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SwitchListTile(
              title: const Text('Detailed Feedback'),
              subtitle: Text(
                detailedFeedback
                    ? 'Get comprehensive analysis and suggestions'
                    : 'Get brief evaluation summary',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              value: detailedFeedback,
              activeColor: AppColors.darkAzure,
              onChanged: (value) {
                setState(() => detailedFeedback = value);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
      ),
      ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          widget.onConfirm(
            selectedLanguage,
            detailedFeedback,
            selectedQuestionType,
          );
        },
        icon: const Icon(Icons.auto_awesome, size: 18),
        label: const Text('Get Evaluation'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkAzure,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ];
  }
}

// Bottom Sheet Implementation
class _GeminiConfigurationSheet extends StatefulWidget {
  final String initialLanguage;
  final bool initialDetailedFeedback;
  final String initialQuestionType;
  final Function(String language, bool detailedFeedback, String questionType)
  onConfirm;

  const _GeminiConfigurationSheet({
    required this.initialLanguage,
    required this.initialDetailedFeedback,
    required this.initialQuestionType,
    required this.onConfirm,
  });

  @override
  State<_GeminiConfigurationSheet> createState() =>
      _GeminiConfigurationSheetState();
}

class _GeminiConfigurationSheetState extends State<_GeminiConfigurationSheet> {
  late String selectedLanguage;
  late bool detailedFeedback;
  late String selectedQuestionType;

  @override
  void initState() {
    super.initState();
    selectedLanguage = widget.initialLanguage;
    detailedFeedback = widget.initialDetailedFeedback;
    selectedQuestionType = widget.initialQuestionType;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.darkAzure.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.settings,
                      color: AppColors.darkAzure,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Gemini Evaluation Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Language Selection
                    const Text(
                      'Language',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            title: const Row(
                              children: [
                                Text('🇮🇩'),
                                SizedBox(width: 8),
                                Text('Bahasa Indonesia'),
                              ],
                            ),
                            value: 'id',
                            groupValue: selectedLanguage,
                            activeColor: AppColors.darkAzure,
                            onChanged: (value) {
                              setState(() => selectedLanguage = value!);
                            },
                          ),
                          Divider(height: 1, color: Colors.grey.shade300),
                          RadioListTile<String>(
                            title: const Row(
                              children: [
                                Text('🇬🇧'),
                                SizedBox(width: 8),
                                Text('English'),
                              ],
                            ),
                            value: 'en',
                            groupValue: selectedLanguage,
                            activeColor: AppColors.darkAzure,
                            onChanged: (value) {
                              setState(() => selectedLanguage = value!);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Detailed Feedback Toggle
                    const Text(
                      'Feedback Detail',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SwitchListTile(
                        title: const Text('Detailed Feedback'),
                        subtitle: Text(
                          detailedFeedback
                              ? 'Get comprehensive analysis and suggestions'
                              : 'Get brief evaluation summary',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        value: detailedFeedback,
                        activeColor: AppColors.darkAzure,
                        onChanged: (value) {
                          setState(() => detailedFeedback = value);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            // Actions
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onConfirm(
                          selectedLanguage,
                          detailedFeedback,
                          selectedQuestionType,
                        );
                      },
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: const Text('Get Evaluation'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkAzure,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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
