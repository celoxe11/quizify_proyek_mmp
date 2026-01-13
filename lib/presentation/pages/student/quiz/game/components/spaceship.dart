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
    size *= 0.25;

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
    final isDesktop = game.size.x > 600;
    if (totalOptions == 2) {
      // currentIndex = 0; // First position for 2 options
      if (isDesktop) {
        availableX = [game.size.x * 0.3, game.size.x * 0.7];
      } else {
        availableX = [game.size.x / 30, game.size.x * 16 / 30];
      }
    } else {
      // currentIndex = 1; // Second position (Alien B) for 4 options
      if (isDesktop) {
        availableX = [
          game.size.x / 10,
          game.size.x * 3 / 10,
          game.size.x * 6 / 10,
          game.size.x * 8 / 10,
        ];
      } else {
        availableX = [
          game.size.x / 30,
          game.size.x * 6 / 30,
          game.size.x * 11 / 30,
          game.size.x * 16 / 30,
        ];
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
    print('Resetting spaceship position');
    final isDesktop = game.size.x > 600;
    if (totalOptions == 2) {
      currentIndex = 0; // First position for 2 options
      if (isDesktop) {
        availableX = [game.size.x * 0.3, game.size.x * 0.7];
      } else {
        availableX = [game.size.x / 30, game.size.x * 16 / 30];
      }
    } else {
      currentIndex = 1; // Second position (Alien B) for 4 options
      if (isDesktop) {
        availableX = [
          game.size.x / 10,
          game.size.x * 3 / 10,
          game.size.x * 6 / 10,
          game.size.x * 8 / 10,
        ];
      } else {
        availableX = [
          game.size.x / 30,
          game.size.x * 6 / 30,
          game.size.x * 11 / 30,
          game.size.x * 16 / 30,
        ];
      }
    }
    if (availableX.isNotEmpty && currentIndex < availableX.length) {
      position.x = availableX[currentIndex];
    }
  }

  void moveLeft() {
    if (currentIndex > 0 && availableX.isNotEmpty) {
      currentIndex--;
      print('Moved left to index $currentIndex');
      if (currentIndex >= 0 && currentIndex < availableX.length) {
        position.x = availableX[currentIndex];
        print('Moved left to index $currentIndex');
      }
    }
  }

  void moveRight() {
    if (availableX.isNotEmpty && currentIndex < availableX.length - 1) {
      currentIndex++;
      print('Moved right to index $currentIndex');
      if (currentIndex >= 0 && currentIndex < availableX.length) {
        position.x = availableX[currentIndex];
        print('Moved right to index $currentIndex');
      }
    }
  }
}
