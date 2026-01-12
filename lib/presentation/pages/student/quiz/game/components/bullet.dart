import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/space_game.dart';

class Bullet extends PositionComponent
    with HasGameReference<SpaceGame>, CollisionCallbacks {
  final double speed = 450;
  double elapsedTime = 0;

  Bullet({required Vector2 position})
    : super(position: position, size: Vector2(6, 20), anchor: Anchor.center);

  late CircleComponent glow;
  late RectangleComponent body;

  @override
  Future<void> onLoad() async {
    // Add glowing effect behind bullet
    glow = CircleComponent(
      radius: 8,
      position: Vector2(3, 10),
      anchor: Anchor.center,
      paint: Paint()..color = Colors.yellowAccent.withOpacity(0.4),
    );
    add(glow);

    // Main bullet body
    body = RectangleComponent(
      size: Vector2(6, 20),
      paint: Paint()
        ..color = Colors.yellowAccent
        ..style = PaintingStyle.fill,
      anchor: Anchor.topLeft,
    );
    add(body);

    add(RectangleHitbox());
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    elapsedTime += dt;

    position.y -= speed * dt;

    // Pulsing glow effect
    final pulseScale = 1.0 + (0.2 * (elapsedTime * 8) % 1);
    glow.scale = Vector2.all(pulseScale);

    // Remove bullet if it goes off screen
    if (position.y < -10) {
      removeFromParent();
    }
  }
}
