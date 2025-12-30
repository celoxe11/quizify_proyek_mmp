import 'dart:async';

import 'package:flame/components.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/space_game.dart';

class Spaceship extends SpriteComponent with HasGameReference<SpaceGame>, KeyboardHandler {
  Vector2 keyboardMovement = Vector2.zero();

  @override
  FutureOr<void> onLoad() async {
    sprite = await game.loadSprite('spaceship.png');
    size *= 0.3;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
  }
}