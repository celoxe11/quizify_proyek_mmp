import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/space_game.dart';

class ShootingStar extends PositionComponent with HasGameReference<SpaceGame> {
  final math.Random random = math.Random();
  late double speed;
  late double angle;
  double elapsedTime = 0;
  final double lifetime = 2.0;

  ShootingStar() {
    speed = 200 + random.nextDouble() * 100;
    angle = -math.pi / 6 + random.nextDouble() * (math.pi / 3);
  }

  @override
  Future<void> onLoad() async {
    position = Vector2(
      random.nextDouble() * game.size.x,
      random.nextDouble() * game.size.y / 2,
    );
    size = Vector2(40, 3);
    anchor = Anchor.centerLeft;

    // Star trail
    final trail = RectangleComponent(
      size: Vector2(40, 3),
      paint: Paint()
        ..shader = LinearGradient(
          colors: [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0)],
        ).createShader(const Rect.fromLTWH(0, 0, 40, 3)),
    );
    add(trail);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    elapsedTime += dt;

    position.x += speed * dt * math.cos(angle);
    position.y += speed * dt * math.sin(angle);

    // Fade out over time
    final opacity = 1 - (elapsedTime / lifetime);
    if (opacity <= 0 || position.x > game.size.x || position.y > game.size.y) {
      removeFromParent();
    }
  }
}
