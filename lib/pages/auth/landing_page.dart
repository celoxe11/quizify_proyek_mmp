import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  // --- Widget Builders ---

  Widget _buildHeroSection(BuildContext context) {
    // Get theme colors for consistent styling
    final textTheme = Theme.of(context).textTheme;

    return Container(
      // The background gradient for the entire top section
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.lightCyan, AppColors.pureWhite],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 72.0),

      // Use a Row for the desktop/web layout shown in the image
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Text and Buttons (60% width)
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IntrinsicWidth(
                  child: Container(
                    // style
                    decoration: BoxDecoration(
                      color: AppColors
                          .dirtyCyan, // Dark background for the image area
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child:
                        // Small accent text
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.question_mark_rounded,
                              size: 16,
                              color: AppColors.darkAzure,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Playful Quizzes for Teachers and Student in all platforms',
                                style: textTheme.bodyMedium!.copyWith(
                                  color: AppColors.darkAzure,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                  ),
                ),

                const SizedBox(height: 16),

                // Main Title
                Text(
                  'Engage your class with live, multiplayer quizzes',
                  style: textTheme.headlineLarge!.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkAzure,
                    fontSize: 48,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  'Create stunning quizzes, host them live, and invite students with a simple code. Public or private — your call.',
                  style: textTheme.titleMedium!.copyWith(
                    color: AppColors.darkTurquoise,
                  ),
                ),
                const SizedBox(height: 32),

                // Buttons Row
                Row(
                  children: [
                    // Primary Button (FilledButton - "Get Started for Free")
                    FilledButton(
                      onPressed: () => Navigator.pushNamed(context, "/login"),
                      child: const Text('Get Started for Free'),
                    ),
                    const SizedBox(width: 16),

                    // Secondary Button (OutlinedButton - "Already Have an Account")
                    OutlinedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, "/register"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        side: BorderSide(
                          color: AppColors.primaryBlue,
                          width: 2,
                        ),
                      ),
                      child: const Text('Already Have an Account'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 32),

          // Right Column: Media Placeholder (40% width)
          Expanded(
            flex: 5,
            child: AspectRatio(
              aspectRatio: 16 / 9, // Standard video aspect ratio
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors
                      .darkGrayAzure, // Dark background for the image area
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    color:
                        AppColors.surfaceLight, // Light color for the play icon
                    size: 72,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTwo(BuildContext context) {
    // Placeholder for Section Two
    return Container(
      height: 400,
      color: const Color(0xFFC4E0E0), // Placeholder color
      child: const Center(child: Text('Section 2 Placeholder')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quizify', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: Text('Login'),
          ),
          SizedBox(width: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              side: BorderSide(color: AppColors.primaryBlue),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/register');
            },
            child: Text('Register'),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context),
            // Placeholder for the next section ("Built for learning and fun")
            Container(
              height: 400,
              color: const Color(0xFFC4E0E0), // Placeholder color
              child: const Center(child: Text('Section 2 Placeholder')),
            ),
            // Placeholder for the third section ("Explore public quizzes")
            Container(
              height: 500,
              color: AppColors.scaffoldBackground,
              child: const Center(child: Text('Section 3 Placeholder')),
            ),
            // Footer
            Container(
              color: AppColors.darkGrayAzure,
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  '© 2025 QuizSpark - made for playful learning.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall!.copyWith(color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
