import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class Star extends PositionComponent {
  final double speed;
  final double radius;
  final Color color;
  final double maxY;
  final double maxX;

  Star({
    required Vector2 position,
    required this.radius,
    required this.speed,
    required this.color,
    required this.maxY,
    required this.maxX,
  }) : super(position: position, size: Vector2.all(radius * 2));

  late CircleComponent circle;

  @override
  Future<void> onLoad() async {
    circle = CircleComponent(
      radius: radius,
      position: Vector2(radius, radius),
      anchor: Anchor.center,
      paint: Paint()..color = color,
    );
    add(circle);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move star downward
    position.y += speed * dt;

    // Reset to top when star goes off screen
    if (position.y > maxY + radius) {
      position.y = -radius;
      // Randomize x position when resetting
      final random = math.Random();
      position.x = random.nextDouble() * maxX;
    }
  }
}
