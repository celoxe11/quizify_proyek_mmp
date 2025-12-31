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
    availableX = [
      game.size.x / 10,
      game.size.x * 3 / 10,
      game.size.x / 2,
      game.size.x * 6 / 10,
      game.size.x * 8 / 10,
    ];

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
    currentIndex = 2;
    position.x = availableX[currentIndex];
  }

  void moveLeft() {
    if (currentIndex > 0) {
      currentIndex--;
      if (currentIndex == 2) {
        currentIndex--;
      }
      position.x = availableX[currentIndex];
    }
  }

  void moveRight() {
    if (currentIndex < availableX.length - 1) {
      currentIndex++;
      if (currentIndex == 2) {
        currentIndex++;
      }
      position.x = availableX[currentIndex];
    }
  }
}
