import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/space_game.dart';

class Spaceship extends SpriteComponent
    with HasGameReference<SpaceGame>, KeyboardHandler {
  Vector2 keyboardMovement = Vector2.zero();
  late List<double> availableX = [];
  late int currentIndex = 2;
  int totalOptions = 4; // Number of options (2 for boolean, 4 for multiple)
  double shootAnimationTime = 0;
  bool isShooting = false;

  @override
  FutureOr<void> onLoad() async {
    sprite = await game.loadSprite('spaceship.png');
    size *= 0.3;

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (availableX.isNotEmpty) {
      position.x = availableX[currentIndex];
    }

    // Handle shoot animation
    if (isShooting) {
      shootAnimationTime += dt;
      // Quick recoil effect
      if (shootAnimationTime < 0.1) {
        position.y += 3;
      } else if (shootAnimationTime < 0.2) {
        position.y -= 3;
      } else {
        isShooting = false;
        shootAnimationTime = 0;
      }
    }

    super.update(dt);
  }

  void shoot() {
    isShooting = true;
    shootAnimationTime = 0;
    game.shootBullet();
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Calculate positions based on total options
    if (totalOptions == 2) {
      // For boolean questions (2 options) - center positions
      availableX = [game.size.x * 0.3, game.size.x * 0.6];
      // Reset to first position if currentIndex is invalid
      if (currentIndex >= availableX.length) {
        currentIndex = 0;
      }
    } else {
      // For multiple choice (4 options) - only 4 positions (skip middle)
      availableX = [
        game.size.x / 10, // Position 0 -> Alien A
        game.size.x * 3 / 10, // Position 1 -> Alien B
        game.size.x * 6 / 10, // Position 2 -> Alien C
        game.size.x * 8 / 10, // Position 3 -> Alien D
      ];
      // Start at position 1 (second from left) for 4 options
      if (currentIndex >= availableX.length) {
        currentIndex = 1;
      }
    }

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.keyA) {
        moveLeft();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.keyD) {
        moveRight();
      } else if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.enter) {
        shoot();
      }
    }
    return true;
  }

  void resetPosition() {
    // Reset to middle position for both 2 and 4 options
    if (totalOptions == 2) {
      currentIndex = 0; // First position for 2 options
      availableX = [game.size.x * 0.3, game.size.x * 0.7];
    } else {
      currentIndex = 1; // Second position (Alien B) for 4 options
      availableX = [
        game.size.x / 10,
        game.size.x * 3 / 10,
        game.size.x * 6 / 10,
        game.size.x * 8 / 10,
      ];
    }
    if (availableX.isNotEmpty && currentIndex < availableX.length) {
      position.x = availableX[currentIndex];
    }
  }

  void moveLeft() {
    if (currentIndex > 0 && availableX.isNotEmpty) {
      currentIndex--;
      if (currentIndex >= 0 && currentIndex < availableX.length) {
        position.x = availableX[currentIndex];
      }
    }
  }

  void moveRight() {
    if (availableX.isNotEmpty && currentIndex < availableX.length - 1) {
      currentIndex++;
      if (currentIndex >= 0 && currentIndex < availableX.length) {
        position.x = availableX[currentIndex];
      }
    }
  }
}
