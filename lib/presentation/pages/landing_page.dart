import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/presentation/widgets/hover_card.dart';
import 'package:go_router/go_router.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/landing/landing_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/landing/landing_state.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  // --- Widget Builders ---

  Widget _buildHeroSection(BuildContext context) {
    // Get theme colors for consistent styling
    final textTheme = Theme.of(context).textTheme;

    // Measure available height to allow a taller hero on large screens
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final appBarHeight = AppBar().preferredSize.height;
    final safeAreaTop = mediaQuery.padding.top;
    final availableHeight = screenHeight - appBarHeight - safeAreaTop;
    final isMobileWidth = mediaQuery.size.width < 520;

    return Container(
      height: isMobileWidth ? null : availableHeight / 1.3,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.lightCyan, AppColors.pureWhite],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobileWidth ? 16.0 : 32.0,
        vertical: isMobileWidth ? 28.0 : 72.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Badge centered
              Container(
                decoration: BoxDecoration(
                  color: AppColors.dirtyCyan,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.question_mark_rounded,
                      size: 18,
                      color: AppColors.darkAzure,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Playful Quizzes for Teachers and Students in all platforms',
                        style: textTheme.bodyMedium!.copyWith(
                          color: AppColors.darkAzure,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Main heading centered
              Text(
                'Engage your class with live, multiplayer quizzes',
                style: textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkAzure,
                  fontSize: isMobileWidth ? 32.0 : 56.0,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description centered
              Text(
                'Create stunning quizzes, host them live, and invite students with a simple code. Public or private — your call.',
                style: textTheme.titleMedium!.copyWith(
                  color: AppColors.darkTurquoise,
                  fontSize: isMobileWidth ? 16.0 : 18.0,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Buttons centered
              Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                    ),
                    onPressed: () => context.push('/login'),
                    child: const Text(
                      'Get Started for Free',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                      foregroundColor: AppColors.primaryBlue,
                      side: BorderSide(color: AppColors.primaryBlue, width: 2),
                    ),
                    onPressed: () => context.go('/register'),
                    child: const Text(
                      'Already Have an Account',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureCard(
    BuildContext context,
    IconData iconData,
    String title,
    String description, {
    Color? bgColor,
  }) {
    // Wrap content in a hoverable card wrapper so we can animate border & elevation on web/desktop
    // The wrapper is transparent so the inner container can control the background color.
    return HoverCardWrapper(
      child: Container(
        decoration: BoxDecoration(
          color: bgColor ?? AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.darkTurquoise, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(iconData, size: 48, color: AppColors.darkTurquoise),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkAzure,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(fontSize: 16, color: AppColors.darkAzure),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    // Placeholder for Section Two — align content to the start (left) and add padding
    return Container(
      width: double.infinity,
      color: AppColors.lightCyan,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 72.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Built for learning and fun",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppColors.darkAzure,
            ),
          ),
          Text(
            "A simple flow for everyone, especially teachers, and students.",
            style: TextStyle(fontSize: 16, color: AppColors.darkAzure),
          ),
          SizedBox(height: 24), // Add spacing between title and content
          // Compute column count and card width so cards fill the available width evenly
          LayoutBuilder(
            builder: (context, constraints) {
              final double maxWidth = constraints.maxWidth;
              // Determine columns based on available width
              int columns;
              if (maxWidth >= 1000) {
                columns = 3;
              } else if (maxWidth >= 700) {
                columns = 2;
              } else {
                columns = 1;
              }

              const spacing = 16.0;
              final cardWidth = (maxWidth - spacing * (columns - 1)) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                alignment: WrapAlignment.start,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _featureCard(
                      context,
                      Icons.book,
                      "Teacher create Quizzes",
                      "Design engaging quizzes with images and timers. Share an invite code for live sessions.",
                      bgColor: AppColors.pureWhite,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _featureCard(
                      context,
                      Icons.people,
                      "Students join & play",
                      "Join from any device with a code. Earn points and climb the leaderboard in real time.",
                      bgColor: AppColors.pureWhite,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _featureCard(
                      context,
                      Icons.private_connectivity,
                      "Public and private modes",
                      "Publish to the community or keep it private for your class — flexible by design.",
                      bgColor: AppColors.pureWhite,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _quizCard(
    BuildContext context, {
    required String title,
    required String description,
    required String quizCode,
    required String category,
    Color? bgColor,
  }) {
    return HoverCardWrapper(
      child: Container(
        decoration: BoxDecoration(
          color: bgColor ?? AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.darkTurquoise, width: 1),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.lightCyan,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkTurquoise,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Quiz title
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkAzure,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Quiz description
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.darkAzure.withOpacity(0.8),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            // Quiz code
            Row(
              children: [
                Icon(Icons.qr_code_2, size: 18, color: AppColors.darkTurquoise),
                const SizedBox(width: 6),
                Text(
                  'Code: $quizCode',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkTurquoise,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreQuizzesSection(BuildContext context) {
    // Placeholder for Section Three
    return Container(
      width: double.infinity,
      color: AppColors.pureWhite,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 72.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Responsive header + action: stacks vertically on small screens
          LayoutBuilder(
            builder: (context, headerConstraints) {
              final bool isNarrowHeader = headerConstraints.maxWidth < 700;
              final title = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Explore public quizzes",
                    style: TextStyle(
                      fontSize: isNarrowHeader ? 20 : 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkAzure,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Browse community-created quizzes and try a sample game.",
                    style: TextStyle(
                      fontSize: isNarrowHeader ? 14 : 16,
                      color: AppColors.darkAzure,
                    ),
                  ),
                ],
              );

              final actionButton = FilledButton(
                onPressed: () => context.push('/login'),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: isNarrowHeader ? 12 : 8,
                    horizontal: isNarrowHeader ? 0 : 12,
                  ),
                  child: Text(
                    "Login to Play",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isNarrowHeader ? 16 : 18,
                    ),
                  ),
                ),
              );

              if (isNarrowHeader) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    const SizedBox(height: 12),
                    SizedBox(width: double.infinity, child: actionButton),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [title, actionButton],
              );
            },
          ),
          SizedBox(height: 24), // Add spacing between title and content
          // Use BlocBuilder to fetch and display quizzes
          BlocBuilder<LandingBloc, LandingState>(
            builder: (context, state) {
              if (state is LandingQuizzesLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state is LandingQuizzesError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.darkAzure.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load quizzes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkAzure,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.error,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.darkAzure.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is LandingQuizzesLoaded) {
                final quizzes = state.quizzes;

                if (quizzes.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'No public quizzes available yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.darkAzure.withOpacity(0.7),
                        ),
                      ),
                    ),
                  );
                }

                // Compute column count and card width so cards fill the available width evenly
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final double maxWidth = constraints.maxWidth;
                    // Determine columns based on available width
                    int columns;
                    if (maxWidth >= 1000) {
                      columns = 3;
                    } else if (maxWidth >= 700) {
                      columns = 2;
                    } else {
                      columns = 1;
                    }

                    const spacing = 16.0;
                    final cardWidth =
                        (maxWidth - spacing * (columns - 1)) / columns;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      alignment: WrapAlignment.start,
                      children: quizzes.map((quiz) {
                        return SizedBox(
                          width: cardWidth,
                          child: _quizCard(
                            context,
                            title: quiz.title,
                            description: quiz.description ?? '',
                            quizCode: quiz.quizCode ?? '',
                            category: quiz.category ?? 'General',
                            bgColor: AppColors.pureWhite,
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quizify',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              context.push('/login');
            },
            child: Text(
              'Login',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          SizedBox(width: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              side: BorderSide(color: AppColors.primaryBlue),
            ),
            onPressed: () {
              context.push('/register');
            },
            child: Text(
              'Register',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context),
            _buildFeaturesSection(context),
            _buildExploreQuizzesSection(context),
            // Footer
            Container(
              color: AppColors.darkGrayAzure,
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  '© 2025 Quizify - made for playful learning.',
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
