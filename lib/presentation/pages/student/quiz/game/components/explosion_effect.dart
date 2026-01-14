import 'dart:math' as dart_math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/space_game.dart';

class ExplosionEffect extends PositionComponent
    with HasGameReference<SpaceGame> {
  final Vector2 explosionPosition;
  double elapsedTime = 0;
  final double duration = 0.5;

  ExplosionEffect({required this.explosionPosition})
    : super(position: explosionPosition);

  @override
  Future<void> onLoad() async {
    // Create particles effect
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * dart_math.pi * 2;
      final particle = _ExplosionParticle(
        angle: angle,
        speed: 150 + (i % 3) * 50,
      );
      add(particle);
    }

    // Add flash effect behind particles
    final flash = CircleComponent(
      radius: 50,
      position: Vector2(-80, -100),
      anchor: Anchor.center,
      paint: Paint()..color = Colors.yellow.withOpacity(0.8),
    )..priority = -1; // Lower priority to render behind
    add(flash);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    elapsedTime += dt;

    if (elapsedTime >= duration) {
      removeFromParent();
    }
  }
}

class _ExplosionParticle extends PositionComponent {
  final double angle;
  final double speed;
  double elapsedTime = 0;

  _ExplosionParticle({required this.angle, required this.speed})
    : super(position: Vector2.zero(), size: Vector2.all(8));

  late CircleComponent particle;

  @override
  Future<void> onLoad() async {
    particle = CircleComponent(
      radius: 4,
      anchor: Anchor.center,
      paint: Paint()..color = Colors.orangeAccent,
    );
    add(particle);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    elapsedTime += dt;

    position.x += speed * dt * dart_math.cos(angle);
    position.y += speed * dt * dart_math.sin(angle);

    // Fade out
    final opacity = 1 - (elapsedTime / 0.5);
    particle.paint.color = Colors.orangeAccent.withOpacity(opacity.clamp(0, 1));
  }
}
