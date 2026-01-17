import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/space_game.dart';

class LeftArrow extends PositionComponent
    with HasGameReference<SpaceGame>, TapCallbacks {
  late CircleComponent buttonBg;
  late TextComponent arrow;
  bool isPressed = false;

  @override
  Future<void> onLoad() async {
    size = Vector2(80, 80);

    // Button border/glow
    final border = CircleComponent(
      radius: 40,
      position: Vector2(40, 40),
      anchor: Anchor.center,
      paint: Paint()
        ..color = Colors.blueAccent.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    add(border);

    // Main button background
    buttonBg = CircleComponent(
      radius: 37,
      position: Vector2(40, 40),
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFF1976D2),
    );
    add(buttonBg);

    // Inner circle
    final innerCircle = CircleComponent(
      radius: 32,
      position: Vector2(40, 40),
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFF2196F3),
    );
    add(innerCircle);

    // Arrow icon
    arrow = TextBoxComponent(
      text: '◀',
      position: Vector2(38, 38),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      align: Anchor.center,
    );
    add(arrow);

    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    isPressed = true;
    buttonBg.paint.color = const Color(0xFF0D47A1);
    buttonBg.scale = Vector2.all(0.95);
    game.spaceship.moveLeft();
  }

  @override
  void onTapUp(TapUpEvent event) {
    isPressed = false;
    buttonBg.paint.color = const Color(0xFF1976D2);
    buttonBg.scale = Vector2.all(1.0);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    isPressed = false;
    buttonBg.paint.color = const Color(0xFF1976D2);
    buttonBg.scale = Vector2.all(1.0);
  }
}
