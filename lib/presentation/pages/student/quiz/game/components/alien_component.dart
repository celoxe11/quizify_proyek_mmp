import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/space_game.dart';

class AlienComponent extends PositionComponent
    with TapCallbacks, HasGameReference<SpaceGame> {
  final Function() onTapped;
  late RectangleComponent body;
  double speed = 50;

  AlienComponent({required Vector2 position, required this.onTapped})
    : super(position: position, size: Vector2(50, 50));

  @override
  Future<void> onLoad() async {
    body = RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xFFFF3366),
    );
    add(body);

    // Add eyes
    final leftEye = CircleComponent(
      radius: 5,
      position: Vector2(12, 15),
      paint: Paint()..color = Colors.white,
    );
    final rightEye = CircleComponent(
      radius: 5,
      position: Vector2(33, 15),
      paint: Paint()..color = Colors.white,
    );
    add(leftEye);
    add(rightEye);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move alien down slowly
    position.y += speed * dt;

    // Remove if off screen and spawn new one
    if (position.y > (parent as SpaceGame).size.y) {
      removeFromParent();
      (parent as SpaceGame).addAlien;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTapped();
    removeFromParent();
    super.onTapDown(event);
  }
}
