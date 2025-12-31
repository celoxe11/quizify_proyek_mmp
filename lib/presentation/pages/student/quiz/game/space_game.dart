import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/components/alien.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/components/bullet.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/components/left_arrow.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/components/right_arrow.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/components/shoot_button.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/components/shooting_star.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/components/spaceship.dart';

class SpaceGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  late TextComponent questionText;
  late TextComponent questionCounter;
  late RectangleComponent progressBar;
  late Spaceship spaceship;
  final List<Vector2> alienPositions = [];
  final math.Random random = math.Random();
  bool gameCompleted = false;
  double shootingStarTimer = 0;
  final double shootingStarInterval = 3.0;

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
    this.questions = const [],
  });

  @override
  Future<void> onLoad() async {
    final background = RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xFF0A1628),
    );
    add(background);

    // Add stars with varied sizes for depth
    for (int i = 0; i < 80; i++) {
      final star = CircleComponent(
        radius: random.nextDouble() * 2.5 + 0.5,
        position: Vector2(
          random.nextDouble() * size.x,
          random.nextDouble() * size.y,
        ),
        paint: Paint()
          ..color = Colors.white.withOpacity(random.nextDouble() * 0.5 + 0.5),
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
    final counterBg = RectangleComponent(
      size: Vector2(150, 35),
      position: Vector2(size.x / 2, 50),
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFF1E3A5F),
    );
    add(counterBg);

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
    final questionBg = RectangleComponent(
      size: Vector2(size.x - 40, 90),
      position: Vector2(20, 85),
      paint: Paint()..color = Colors.black.withOpacity(0.75),
    );
    add(questionBg);

    questionText = TextComponent(
      text: _getCurrentQuestionText(),
      position: Vector2(size.x / 2, 130),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
      ),
    );
    add(questionText);

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

    // Spawn aliens with options
    _spawnAliens();
    _createSpaceship();
    return super.onLoad();
  }

  String _getCurrentQuestionText() {
    if (questions.isEmpty || currentQuestionIndex >= questions.length) {
      return 'Memuat soal...';
    }
    final question = questions[currentQuestionIndex];
    // Truncate long questions for better display
    if (question.questionText.length > 100) {
      return '${question.questionText.substring(0, 97)}...';
    }
    return question.questionText;
  }

  void _createSpaceship() {
    spaceship = Spaceship();
    spaceship.position = Vector2(size.x / 2 - 100, size.y - 220);
    add(spaceship);
  }

  void _spawnAliens() {
    if (questions.isEmpty || currentQuestionIndex >= questions.length) return;

    final question = questions[currentQuestionIndex];
    final optionLabels = ['A', 'B', 'C', 'D'];

    // Get option texts from the options list
    final optionTexts = question.options.length >= 4
        ? question.options
        : [
            ...question.options,
            ...List.filled(4 - question.options.length, ''),
          ];

    for (int i = 0; i < optionLabels.length && i < optionTexts.length; i++) {
      final optionValue = optionLabels[i];
      final optionText = optionTexts[i];
      final alien = Alien(
        optionValue: optionValue,
        optionText: optionText,
        onHit: () => _handleAnswer(optionValue),
      );
      aliens[optionValue] = alien;
      add(alien);
    }
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

    // Save answer
    print(
      '💾 [SpaceGame] Saving answer for question $currentQuestionIndex: $answer',
    );
    answers[currentQuestionIndex] = answer;

    // Submit this answer immediately to backend
    if (onAnswerSubmit != null && currentQuestionIndex < questions.length) {
      final questionId = questions[currentQuestionIndex].id;
      print(
        '📤 [SpaceGame] Submitting answer immediately: questionId=$questionId, answer=$answer',
      );
      onAnswerSubmit?.call(questionId, answer);
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
}
