import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/src/services/hardware_keyboard.dart';
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/space_game.dart';

class Spaceship extends SpriteComponent
    with HasGameReference<SpaceGame>, KeyboardHandler {
  Vector2 keyboardMovement = Vector2.zero();

  @override
  FutureOr<void> onLoad() async {
    sprite = await game.loadSprite('assets/games/space/spaceship.png');
    size *= 0.3;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    keyboardMovement.x = 0;

    keyboardMovement.x -= keysPressed.contains(LogicalKeyboardKey.keyA) ? 1 : 0;
    keyboardMovement.x += keysPressed.contains(LogicalKeyboardKey.keyD) ? 1 : 0;
    keyboardMovement.x -= keysPressed.contains(LogicalKeyboardKey.arrowLeft)
        ? 1
        : 0;
    keyboardMovement.x += keysPressed.contains(LogicalKeyboardKey.arrowRight)
        ? 1
        : 0;
    return true;
  }
}
