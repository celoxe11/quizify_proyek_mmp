import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/space_game.dart';

class ShootButton extends PositionComponent
    with HasGameReference<SpaceGame>, TapCallbacks {
  late CircleComponent buttonBackground;
  late CircleComponent buttonBorder;
  late TextComponent buttonText;
  late TextComponent buttonIcon;
  bool isPressed = false;

  @override
  Future<void> onLoad() async {
    size = Vector2(90, 90);

    // Outer border/glow
    buttonBorder = CircleComponent(
      radius: 45,
      position: Vector2(45, 45),
      anchor: Anchor.center,
      paint: Paint()
        ..color = Colors.redAccent.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    add(buttonBorder);

    // Main button background
    buttonBackground = CircleComponent(
      radius: 42,
      position: Vector2(45, 45),
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFFD32F2F),
    );
    add(buttonBackground);

    // Inner circle for depth
    final innerCircle = CircleComponent(
      radius: 35,
      position: Vector2(45, 45),
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFFE53935),
    );
    add(innerCircle);

    // Icon/emoji
    buttonIcon = TextComponent(
      text: '🎯',
      position: Vector2(45, 30),
      anchor: Anchor.center,
      textRenderer: TextPaint(style: const TextStyle(fontSize: 24)),
    );
    add(buttonIcon);

    // Text label
    buttonText = TextComponent(
      text: 'TEMBAK',
      position: Vector2(45, 55),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(buttonText);

    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    isPressed = true;
    game.spaceship.shoot();
    buttonBackground.paint.color = const Color(0xFFB71C1C);
    buttonBackground.scale = Vector2.all(0.95);
  }

  @override
  void onTapUp(TapUpEvent event) {
    isPressed = false;
    buttonBackground.paint.color = const Color(0xFFD32F2F);
    buttonBackground.scale = Vector2.all(1.0);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    isPressed = false;
    buttonBackground.paint.color = const Color(0xFFD32F2F);
    buttonBackground.scale = Vector2.all(1.0);
  }
}
