import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/widgets/hover_card.dart';

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 800;

          Widget mediaBlock = AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.darkGrayAzure,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: AppColors.surfaceLight,
                  size: 72,
                ),
              ),
            ),
          );

          Widget leftContent = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IntrinsicWidth(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.dirtyCyan,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.question_mark_rounded,
                        size: 16,
                        color: AppColors.darkAzure,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Playful Quizzes for Teachers and Student in all platforms',
                        style: textTheme.bodyMedium!.copyWith(
                          color: AppColors.darkAzure,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Engage your class with live, multiplayer quizzes',
                style: textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkAzure,
                  fontSize: isNarrow ? 28.0 : 52.0,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Create stunning quizzes, host them live, and invite students with a simple code. Public or private — your call.',
                style: textTheme.titleMedium!.copyWith(
                  color: AppColors.darkTurquoise,
                ),
              ),
              const SizedBox(height: 24),

              LayoutBuilder(
                builder: (context, buttonConstraints) {
                  final btnNarrow =
                      buttonConstraints.maxWidth < 520 || isNarrow;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: btnNarrow ? buttonConstraints.maxWidth : null,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 24,
                            ),
                          ),
                          onPressed: () =>
                              Navigator.pushNamed(context, "/login"),
                          child: const Text(
                            'Get Started for Free',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        width: btnNarrow ? buttonConstraints.maxWidth : null,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 24,
                            ),
                            foregroundColor: AppColors.primaryBlue,
                            side: BorderSide(
                              color: AppColors.primaryBlue,
                              width: 2,
                            ),
                          ),
                          onPressed: () =>
                              Navigator.pushNamed(context, "/register"),
                          child: const Text(
                            'Already Have an Account',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [leftContent, const SizedBox(height: 20), mediaBlock],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: leftContent),
              const SizedBox(width: 32),
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [mediaBlock],
                ),
              ),
            ],
          );
        },
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

  Widget _quizCard(BuildContext context, Color? bgColor) {
    return HoverCardWrapper(
      child: Container(
        decoration: BoxDecoration(
          color: bgColor ?? AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.darkTurquoise, width: 1),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sample Quiz Title',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkAzure,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A brief description of the quiz goes here. Engage with this sample quiz to see how it works!',
              style: TextStyle(fontSize: 14, color: AppColors.darkAzure),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Explore public quizzes",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkAzure,
                    ),
                  ),
                  Text(
                    "Browse community-created quizzes and try a sample game.",
                    style: TextStyle(fontSize: 16, color: AppColors.darkAzure),
                  ),
                ],
              ),
              FilledButton(
                onPressed: () {},
                child: Text(
                  "Login to Play",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
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
                    child: _quizCard(context, AppColors.pureWhite),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _quizCard(context, AppColors.pureWhite),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _quizCard(context, AppColors.pureWhite),
                  ),
                ],
              );
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
              Navigator.pushNamed(context, '/login');
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
              Navigator.pushNamed(context, '/register');
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
