import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/question_model.dart';

class QuestionListItem extends StatelessWidget {
  final QuestionModel question;
  final int index;

  const QuestionListItem({
    super.key,
    required this.question,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.darkAzure,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Text(
          question.questionText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              _QuestionTag(
                text: question.type == 'multiple'
                    ? 'Multiple Choice'
                    : 'True/False',
              ),
              const SizedBox(width: 8),
              _QuestionTag(text: question.difficulty, isColored: true),
            ],
          ),
        ),
        children: [
          const Divider(),
          const SizedBox(height: 8),
          // Image Preview (if exists)
          Text(
            "Question Image ${question.image != null ? 'Preview' : 'Not Available'}",
          ),

          if (question.image != null &&
              question.image!.imageUrl.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Question Image:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.darkAzure,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _QuestionImage(imageUrl: question.image!.imageUrl),
                  ),
                ],
              ),
            ),
          ],
          // Options
          ...question.options.asMap().entries.map((entry) {
            final optionIndex = entry.key;
            final option = entry.value;
            final isCorrect = option == question.correctAnswer;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isCorrect
                    ? Colors.green.withOpacity(0.1)
                    : AppColors.lightCyan.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCorrect ? Colors.green : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? Colors.green
                          : AppColors.darkAzure.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCorrect
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : Text(
                              String.fromCharCode(65 + optionIndex),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkAzure.withOpacity(0.7),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 14,
                        color: isCorrect
                            ? Colors.green.shade700
                            : AppColors.textDark,
                        fontWeight: isCorrect
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isCorrect)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Correct',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _QuestionImage extends StatelessWidget {
  final String imageUrl;

  const _QuestionImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Web: Handle base64 encoded images or network URLs
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
        // Network URL
        return Image.network(
          imageUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorPlaceholder();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingPlaceholder(loadingProgress);
          },
        );
      }
    } else {
      // Mobile: Handle local file paths or network URLs
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorPlaceholder();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingPlaceholder(loadingProgress);
          },
        );
      } else if (imageUrl.startsWith('/') || imageUrl.contains(':')) {
        // Local file path
        final file = File(imageUrl);
        return Image.file(
          file,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: Colors.grey.shade300,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Image not found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    }

    // Fallback
    return Container(
      height: 200,
      color: Colors.grey.shade300,
      child: const Center(
        child: Text(
          'Image preview unavailable',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      height: 200,
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(ImageChunkEvent loadingProgress) {
    return Container(
      height: 200,
      color: Colors.grey.shade200,
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
              : null,
          color: AppColors.darkAzure,
        ),
      ),
    );
  }
}

class _QuestionTag extends StatelessWidget {
  final String text;
  final bool isColored;

  const _QuestionTag({required this.text, this.isColored = false});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    if (isColored) {
      switch (text.toLowerCase()) {
        case 'easy':
          bgColor = Colors.green.withOpacity(0.1);
          textColor = Colors.green;
          break;
        case 'medium':
          bgColor = Colors.orange.withOpacity(0.1);
          textColor = Colors.orange;
          break;
        case 'hard':
          bgColor = Colors.red.withOpacity(0.1);
          textColor = Colors.red;
          break;
        default:
          bgColor = AppColors.lightCyan.withOpacity(0.5);
          textColor = AppColors.darkAzure;
      }
    } else {
      bgColor = AppColors.lightCyan.withOpacity(0.5);
      textColor = AppColors.darkAzure;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
