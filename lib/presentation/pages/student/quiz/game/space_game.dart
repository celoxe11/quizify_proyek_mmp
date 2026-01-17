import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import 'package:quizify_proyek_mmp/core/config/platform_config.dart';
import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/components/alien.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/components/bullet.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/components/left_arrow.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/components/right_arrow.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/components/shoot_button.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/components/shooting_star.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/components/spaceship.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/components/star.dart';

class SpaceGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  late TextBoxComponent questionText;
  late TextComponent questionCounter;
  late RectangleComponent progressBar;
  late Spaceship spaceship;
  final List<Vector2> alienPositions = [];
  final math.Random random = math.Random();
  bool gameCompleted = false;
  double shootingStarTimer = 0;
  final double shootingStarInterval = 3.0;

  // Image modal components
  bool isImageModalOpen = false;
  late PositionComponent imageViewButton;
  late TextComponent imageViewButtonText;

  // Callback untuk menampilkan image modal dari Flutter widget
  Function(String imageUrl)? onShowImageModal;

  // Quiz data
  List<QuestionModel> questions = [];
  int currentQuestionIndex = 0;
  Map<int, String> answers = {};
  final Map<String, Alien> aliens = {};
  bool isProcessingAnswer = false;

  Function()? onGameComplete;
  Function(Map<int, String>)? onAnswersSubmit;
  Function(String questionId, String answer)?
  onAnswerSubmit; // Single answer callback

  SpaceGame({
    this.onGameComplete,
    this.onAnswersSubmit,
    this.onAnswerSubmit,
    this.onShowImageModal,
    this.questions = const [],
    int startingQuestionIndex = 0,
    Map<String, String> answeredQuestions = const {},
  }) {
    // Set starting question index
    currentQuestionIndex = startingQuestionIndex;

    // Pre-populate answers from resumed session
    if (answeredQuestions.isNotEmpty) {
      print(
        '🔄 [SpaceGame] Resuming with ${answeredQuestions.length} answered questions',
      );
      // Convert Map<String, String> (questionId -> answer) to Map<int, String> (index -> answer)
      for (int i = 0; i < questions.length; i++) {
        final questionId = questions[i].id;
        if (answeredQuestions.containsKey(questionId)) {
          // Get the answer text and convert it to option label (A, B, C, D)
          final answerText = answeredQuestions[questionId]!;
          final question = questions[i];

          // Find which option matches the answer text
          for (int j = 0; j < question.options.length; j++) {
            if (question.options[j] == answerText) {
              final optionLabel = ['A', 'B', 'C', 'D'][j];
              answers[i] = optionLabel;
              print(
                '✅ [SpaceGame] Restored answer for Q${i + 1}: $optionLabel',
              );
              break;
            }
          }
        }
      }
      print(
        '📋 [SpaceGame] Starting from question ${currentQuestionIndex + 1}/${questions.length}',
      );
    }
  }

  @override
  Future<void> onLoad() async {
    final background = RectangleComponent(
      size: size,
      paint: Paint()..color = const Color.fromARGB(255, 0, 0, 0),
    );
    add(background);

    // Add moving stars with varied sizes and speeds for depth effect
    for (int i = 0; i < 80; i++) {
      final starRadius = random.nextDouble() * 2.5 + 0.5;
      final speed = (starRadius / 3) * 30 + 10; // Larger stars move faster

      final star = Star(
        position: Vector2(
          random.nextDouble() * size.x,
          random.nextDouble() * size.y,
        ),
        radius: starRadius,
        speed: speed,
        color: Colors.white.withOpacity(random.nextDouble() * 0.5 + 0.5),
        maxY: size.y,
        maxX: size.x,
      );
      add(star);
    }

    // Add progress bar background
    final progressBg = RectangleComponent(
      size: Vector2(size.x - 40, 8),
      position: Vector2(20, 20),
      paint: Paint()..color = Colors.grey.shade800,
    );
    add(progressBg);

    // Add progress bar (will be updated)
    progressBar = RectangleComponent(
      size: Vector2(
        (size.x - 40) *
            (currentQuestionIndex + 1) /
            (questions.length > 0 ? questions.length : 1),
        8,
      ),
      position: Vector2(20, 20),
      paint: Paint()..color = const Color(0xFF4CAF50),
    );
    add(progressBar);

    // Add question counter with background
    // final counterBg = RectangleComponent(
    //   size: Vector2(150, 35),
    //   position: Vector2(size.x / 2, 50),
    //   anchor: Anchor.center,
    //   paint: Paint()..color = const Color(0xFF1E3A5F),
    // );
    // add(counterBg);

    final questionCounter = TextComponent(
      text: 'Soal ${currentQuestionIndex + 1}/${questions.length}',
      position: Vector2(size.x / 2, 50),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellowAccent,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    this.questionCounter = questionCounter;
    add(questionCounter);

    // Add question text with background for better readability
    final isDesktop = size.x > 600;
    final questionBgHeight = isDesktop ? 120.0 : 160.0;
    final questionTextHeight = isDesktop ? 100.0 : 140.0;
    final questionFontSize = isDesktop ? 18.0 : 12.0;

    final questionBg = RectangleComponent(
      size: Vector2(size.x - 40, questionBgHeight),
      position: Vector2(20, 110),
      paint: Paint()..color = Colors.black.withOpacity(0.75),
    );
    add(questionBg);

    questionText = TextBoxComponent(
      text: _getCurrentQuestionText(),
      position: Vector2(30, 120),
      size: Vector2(size.x - 60, questionTextHeight),
      textRenderer: TextPaint(
        style: GoogleFonts.oxanium(
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: questionFontSize,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
      ),
      align: Anchor.topCenter,
    );
    add(questionText);

    // Add image view button (will be shown/hidden based on question image)
    _createImageViewButton();
    _updateImageButtonVisibility();

    // Add instruction text
    // final instructionText = TextComponent(
    //   text:
    //       'Tembak alien untuk menjawab! [<][>] atau A/D bergerak | SPASI menembak',
    //   position: Vector2(size.x / 2, 185),
    //   anchor: Anchor.center,
    //   textRenderer: TextPaint(
    //     style: TextStyle(
    //       color: Colors.yellowAccent.withOpacity(0.95),
    //       fontSize: 14,
    //       fontWeight: FontWeight.bold,
    //     ),
    //   ),
    // );
    // add(instructionText);

    // Create spaceship first before spawning aliens
    _createSpaceship();
    // Spawn aliens with options
    _spawnAliens();
    return super.onLoad();
  }

  String _getCurrentQuestionText() {
    if (questions.isEmpty || currentQuestionIndex >= questions.length) {
      return 'Memuat soal...';
    }
    final question = questions[currentQuestionIndex];
    // Return full question text, TextBoxComponent will handle wrapping
    return question.questionText;
  }

  void _createSpaceship() {
    spaceship = Spaceship();
    spaceship.position = Vector2(size.x / 2 - 100, size.y / 2 + 120);
    add(spaceship);
  }

  void _spawnAliens() {
    if (questions.isEmpty || currentQuestionIndex >= questions.length) return;

    final question = questions[currentQuestionIndex];
    final numOptions = question.options.length;

    // Update spaceship's totalOptions
    spaceship.totalOptions = numOptions;
    spaceship.resetPosition();

    // Determine option labels based on question type
    final optionLabels = numOptions == 2
        ? ['A', 'B'] // Boolean questions (True/False)
        : ['A', 'B', 'C', 'D']; // Multiple choice

    print(
      '🎮 [SpaceGame] Question type: ${question.type}, Options: $numOptions',
    );

    // Get option texts from the options list
    final optionTexts = question.options;

    for (int i = 0; i < optionLabels.length && i < optionTexts.length; i++) {
      final optionValue = optionLabels[i];
      final optionText = optionTexts[i];

      // Skip empty options
      if (optionText.isEmpty) continue;

      final alien = Alien(
        optionValue: optionValue,
        optionText: optionText,
        onHit: () => _handleAnswer(optionValue),
        totalOptions: numOptions, // Pass total options for positioning
      );
      aliens[optionValue] = alien;
      add(alien);
    }

    print('👽 [SpaceGame] Spawned ${aliens.length} aliens');
  }

  void _handleAnswer(String answer) {
    // Prevent multiple answers for same question
    if (isProcessingAnswer || gameCompleted) {
      print(
        '⏸️ [SpaceGame] Answer blocked: isProcessing=$isProcessingAnswer, gameCompleted=$gameCompleted',
      );
      return;
    }

    isProcessingAnswer = true;

    // Get the full option text from the answer label (A, B, C, D)
    final currentQuestion = questions[currentQuestionIndex];
    final optionIndex = ['A', 'B', 'C', 'D'].indexOf(answer);
    final answerText =
        optionIndex >= 0 && optionIndex < currentQuestion.options.length
        ? currentQuestion.options[optionIndex]
        : answer;

    print(
      '💾 [SpaceGame] Saving answer for question $currentQuestionIndex: $answer (text: $answerText)',
    );
    answers[currentQuestionIndex] = answer;

    // Submit this answer immediately to backend using the full option text
    if (onAnswerSubmit != null && currentQuestionIndex < questions.length) {
      final questionId = currentQuestion.id;
      print(
        '📤 [SpaceGame] Submitting answer immediately: questionId=$questionId, answerLabel=$answer, answerText=$answerText',
      );
      onAnswerSubmit?.call(questionId, answerText);
    }

    // Move to next question or complete quiz
    print(
      '🔍 [SpaceGame] Check: currentQuestionIndex=$currentQuestionIndex, questions.length=${questions.length}',
    );
    print(
      '🔍 [SpaceGame] Condition: $currentQuestionIndex < ${questions.length - 1} = ${currentQuestionIndex < questions.length - 1}',
    );

    if (currentQuestionIndex < questions.length - 1) {
      print('➡️ [SpaceGame] Moving to next question');
      _nextQuestion();
      // Reset flag after aliens are cleared
      Future.delayed(const Duration(milliseconds: 100), () {
        isProcessingAnswer = false;
      });
    } else {
      print('🏁 [SpaceGame] This is the last question, completing quiz...');
      _completeQuiz();
      // No need to reset flag, quiz is complete
    }
  }

  void _nextQuestion() {
    // Close image modal if open
    if (isImageModalOpen) {
      closeImageModal();
    }

    // Remove current aliens
    for (var alien in aliens.values) {
      alien.removeFromParent();
    }
    aliens.clear();

    // Move to next question
    currentQuestionIndex++;

    // Update question text
    questionText.text = _getCurrentQuestionText();
    // Update question counter
    questionCounter.text =
        'Soal ${currentQuestionIndex + 1}/${questions.length}';

    // Update progress bar with smooth animation
    final newWidth =
        (size.x - 40) * (currentQuestionIndex + 1) / questions.length;

    // Animate progress bar growth
    final oldWidth = progressBar.size.x;
    final widthDiff = newWidth - oldWidth;
    double animationTime = 0;
    const animationDuration = 0.3;

    add(
      TimerComponent(
        period: 0.016, // ~60fps
        repeat: true,
        onTick: () {
          animationTime += 0.016;
          if (animationTime >= animationDuration) {
            progressBar.size = Vector2(newWidth, 8);
            return;
          }
          final progress = animationTime / animationDuration;
          final currentWidth = oldWidth + (widthDiff * progress);
          progressBar.size = Vector2(currentWidth, 8);
        },
        removeOnFinish: true,
      ),
    );

    //
    // Spawn new aliens
    _spawnAliens();

    // Reset spaceship position
    spaceship.resetPosition();

    // Update image button visibility for new question
    _updateImageButtonVisibility();
  }

  void _completeQuiz() {
    gameCompleted = true;

    // PAUSE THE GAME to stop all updates
    pauseEngine();
    print('⏸️ [SpaceGame] Game paused');

    // Remove all aliens
    for (var alien in aliens.values) {
      alien.removeFromParent();
    }
    aliens.clear();

    // Add celebration background
    final celebrationBg =
        RectangleComponent(
          size: Vector2(500, 250),
          position: Vector2(size.x / 2, size.y / 2),
          anchor: Anchor.center,
          paint: Paint()..color = const Color(0xFF1B5E20).withOpacity(0.95),
        )..add(
          RectangleComponent(
            size: Vector2(490, 240),
            position: Vector2(250, 125),
            anchor: Anchor.center,
            paint: Paint()..color = const Color(0xFF2E7D32),
          ),
        );
    add(celebrationBg);

    // Add celebration icon (star)
    final starIcon = TextComponent(
      text: '⭐🎉⭐',
      position: Vector2(size.x / 2, size.y / 2 - 60),
      anchor: Anchor.center,
      textRenderer: TextPaint(style: const TextStyle(fontSize: 48)),
    );
    add(starIcon);

    // Show completion message
    final completionTitle = TextComponent(
      text: 'Quiz Selesai!',
      position: Vector2(size.x / 2, size.y / 2 - 10),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellowAccent,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(completionTitle);

    final completionSubtitle = TextComponent(
      text: 'Mengirim jawaban...',
      position: Vector2(size.x / 2, size.y / 2 + 30),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
    add(completionSubtitle);

    final answeredText = TextComponent(
      text:
          'Kamu telah menjawab ${answers.length} dari ${questions.length} soal',
      position: Vector2(size.x / 2, size.y / 2 + 60),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
      ),
    );
    add(answeredText);

    // Submit answers and show dialog
    print('🎯 [SpaceGame] Quiz completed! Total answers: ${answers.length}');
    print('📋 [SpaceGame] Answers map: $answers');

    if (onAnswersSubmit != null) {
      print('📤 [SpaceGame] Calling onAnswersSubmit callback...');
      onAnswersSubmit?.call(answers);
      print('✅ [SpaceGame] onAnswersSubmit callback executed');
    } else {
      print('⚠️ [SpaceGame] WARNING: onAnswersSubmit is null!');
    }

    // Call onGameComplete immediately without delay
    print('🏁 [SpaceGame] Calling onGameComplete callback...');
    onGameComplete?.call();
  }

  void shootBullet() {
    if (gameCompleted) return;

    final bullet = Bullet(
      position: Vector2(
        spaceship.position.x + spaceship.size.x / 2,
        spaceship.position.y,
      ),
    );
    add(bullet);
  }

  void _addLeftArrow() {
    final leftArrow = LeftArrow();
    leftArrow.position = Vector2(20, size.y - 100);
    add(leftArrow);
  }

  void _addRightArrow() {
    final rightArrow = RightArrow();
    // letakkan di sebelah kanan left arrow
    rightArrow.position = Vector2(140, size.y - 100);
    add(rightArrow);
  }

  void _addShootButton() {
    final shootButton = ShootButton();
    shootButton.position = Vector2(size.x - 120, size.y - 100);
    add(shootButton);
  }

  @override
  void onMount() {
    super.onMount();
    _addLeftArrow();
    _addRightArrow();
    _addShootButton();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Add shooting stars periodically
    shootingStarTimer += dt;
    if (shootingStarTimer >= shootingStarInterval && !gameCompleted) {
      shootingStarTimer = 0;
      add(ShootingStar());
    }
  }

  void _createImageViewButton() {
    // Create button component with tap handler
    final button = _ImageViewButton(
      size: Vector2(140, 40),
      position: Vector2(size.x - 160, 70),
      onTap: () {
        if (!isImageModalOpen && _hasCurrentQuestionImage()) {
          _openImageModal();
        }
      },
    );
    button.priority = 100;
    imageViewButton = button;
    add(button);

    // Create button text with icon
    imageViewButtonText = TextComponent(
      text: 'Lihat Gambar Soal',
      position: Vector2(size.x - 90, 90),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          shadows: [
            Shadow(color: Colors.black45, offset: Offset(1, 1), blurRadius: 2),
          ],
        ),
      ),
    );
    imageViewButtonText.priority = 101;
    add(imageViewButtonText);
  }

  bool _hasCurrentQuestionImage() {
    if (questions.isEmpty || currentQuestionIndex >= questions.length) {
      return false;
    }
    final question = questions[currentQuestionIndex];
    final hasImage =
        question.image != null && question.image!.imageUrl.isNotEmpty;

    // Debug logging
    print(
      '🖼️ [SpaceGame] Question ${currentQuestionIndex + 1}: image=${question.image?.imageUrl ?? "null"}, hasImage=$hasImage',
    );

    return hasImage;
  }

  void _updateImageButtonVisibility() {
    final hasImage = _hasCurrentQuestionImage();
    print('👁️ [SpaceGame] Updating button visibility: hasImage=$hasImage');

    // Hide/show by moving off-screen or changing render position
    if (hasImage) {
      imageViewButton.position = Vector2(size.x - 160, 70);
      imageViewButtonText.position = Vector2(size.x - 90, 90);
    } else {
      imageViewButton.position = Vector2(-1000, -1000);
      imageViewButtonText.position = Vector2(-1000, -1000);
    }
  }

  String _getFullImageUrl(String imageUrl) {
    // If already a full URL, return as is
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    // If it's a relative path (starts with /), combine with base URL
    final baseUrl = PlatformConfig.getBaseUrl();
    // Keep /api in baseUrl since backend serves images at /api/uploads/
    final rootUrl = baseUrl;

    // Ensure no double slashes
    if (imageUrl.startsWith('/')) {
      return '$rootUrl$imageUrl';
    } else {
      return '$rootUrl/$imageUrl';
    }
  }

  void _openImageModal() {
    if (isImageModalOpen || !_hasCurrentQuestionImage()) return;

    isImageModalOpen = true;
    final question = questions[currentQuestionIndex];
    final fullImageUrl = _getFullImageUrl(question.image!.imageUrl);

    print('🖼️ [SpaceGame] Opening image modal for: $fullImageUrl');

    // Call Flutter widget overlay to show image
    onShowImageModal?.call(fullImageUrl);
  }

  void closeImageModal() {
    isImageModalOpen = false;
    print('✅ [SpaceGame] Image modal closed');
  }
}

// Helper class for tappable image view button
class _ImageViewButton extends PositionComponent with TapCallbacks {
  final VoidCallback onTap;

  _ImageViewButton({
    required Vector2 size,
    required Vector2 position,
    required this.onTap,
  }) : super(size: size, position: position);

  bool _pressed = false;

  @override
  Future<void> onLoad() async {
    // Painter component untuk gambar button rounded + shadow + border + highlight
    final painter = _RoundedButtonPainter(size: size, radius: 14);
    add(painter);
  }

  @override
  void onTapDown(TapDownEvent event) {
    _pressed = true;
    position += Vector2(0, 1.5);
    scale = Vector2.all(0.98);
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (_pressed) {
      _pressed = false;
      position -= Vector2(0, 1.5);
      scale = Vector2.all(1.0);
      onTap();
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    if (_pressed) {
      _pressed = false;
      position -= Vector2(0, 1.5);
      scale = Vector2.all(1.0);
    }
  }
}

class _RoundedButtonPainter extends PositionComponent {
  final double radius;

  _RoundedButtonPainter({required Vector2 size, this.radius = 14})
    : super(size: size);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    // 1) Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.save();
    canvas.translate(2.5, 3.5);
    canvas.drawRRect(rrect, shadowPaint);
    canvas.restore();

    // 2) Main background
    final bgPaint = Paint()..color = const Color(0xFF1565C0);
    canvas.drawRRect(rrect, bgPaint);

    // 3) Top highlight (glossy)
    final topRect = Rect.fromLTWH(0, 0, size.x, size.y * 0.52);
    final topRRect = RRect.fromRectAndRadius(topRect, Radius.circular(radius));
    final highlightPaint = Paint()
      ..color = const Color(0xFF42A5F5).withOpacity(0.55);
    canvas.drawRRect(topRRect, highlightPaint);

    // 4) Border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF90CAF9).withOpacity(0.9);
    canvas.drawRRect(rrect, borderPaint);

    // 5) Bottom glow line
    final glowRect = Rect.fromLTWH(5, size.y - 6, size.x - 10, 2);
    final glowRRect = RRect.fromRectAndRadius(
      glowRect,
      const Radius.circular(10),
    );
    final glowPaint = Paint()..color = Colors.white.withOpacity(0.22);
    canvas.drawRRect(glowRRect, glowPaint);
  }
}
