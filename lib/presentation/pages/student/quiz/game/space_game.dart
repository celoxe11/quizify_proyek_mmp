import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/components/alien_component.dart';

class SpaceGame extends FlameGame with TapDetector {
  late TextComponent scoreText;
  late PositionComponent spaceship;
  int score = 0;
  int targetScore = 10;
  final List<Vector2> alienPositions = [];
  final math.Random random = math.Random();
  bool gameCompleted = false;

  Function()? onGameComplete;

  SpaceGame({this.onGameComplete});

  @override
  Future<void> onLoad() async {
    // Add background
    final background = RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xFF001233),
    );
    add(background);

    // Add stars
    for (int i = 0; i < 50; i++) {
      final star = CircleComponent(
        radius: random.nextDouble() * 2 + 1,
        position: Vector2(
          random.nextDouble() * size.x,
          random.nextDouble() * size.y,
        ),
        paint: Paint()..color = Colors.white.withOpacity(0.8),
      );
      add(star);
    }

    // Add spaceship
    spaceship = PositionComponent(
      size: Vector2(60, 60),
      position: Vector2(size.x / 2 - 30, size.y - 100),
    );

    // Create spaceship visual
    final spaceshipShape = RectangleComponent(
      size: Vector2(60, 60),
      paint: Paint()..color = const Color(0xFF00D9FF),
    );
    spaceship.add(spaceshipShape);
    add(spaceship);

    // Add score text
    scoreText = TextComponent(
      text: 'Score: $score / $targetScore',
      position: Vector2(20, 50),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(scoreText);

    // Add instruction text
    final instructionText = TextComponent(
      text: 'Tap aliens to destroy them!',
      position: Vector2(size.x / 2, 100),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white70, fontSize: 18),
      ),
    );
    add(instructionText);

    // Spawn aliens
    _spawnAliens();
  }

  void _spawnAliens() {
    for (int i = 0; i < 5; i++) {
      _addAlien();
    }
  }

  void _addAlien() {
    AlienComponent alienComponent = AlienComponent(
      position: Vector2(
        random.nextDouble() * (size.x - 50),
        random.nextDouble() * (size.y / 2 - 100),
      ),
      onTapped: _onAlienTapped,
    );
    add(alienComponent);
  }

  // getter for _addAlien
  void get addAlien => _addAlien();

  void _onAlienTapped() {
    score++;
    scoreText.text = 'Score: $score / $targetScore';

    if (score >= targetScore && !gameCompleted) {
      gameCompleted = true;
      _showVictory();
    } else if (score < targetScore) {
      _addAlien();
    }
  }

  void _showVictory() {
    final victoryText = TextComponent(
      text: 'Victory! Starting Quiz...',
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.green,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(victoryText);

    Future.delayed(const Duration(seconds: 2), () {
      onGameComplete?.call();
    });
  }

  @override
  void onTapDown(TapDownInfo info) {
    // Tap detection is handled by individual alien components
    super.onTapDown(info);
  }
}
