import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/components/bullet.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/components/explosion_effect.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/space_game.dart';

class Alien extends PositionComponent
    with HasGameReference<SpaceGame>, CollisionCallbacks {
  String optionValue;
  String optionText;
  Function()? onHit;
  late TextComponent optionLabel;
  late TextComponent optionTextComponent;
  late SpriteComponent alienSprite;
  late Vector2 basePosition;
  double elapsedTime = 0;
  final double rotationAmplitude = 0.15;
  final double rotationSpeed = 2;
  final alienSize = Vector2(145, 145);
  bool isHit = false;

  Alien({required this.optionValue, required this.optionText, this.onHit});

  @override
  Future<void> onLoad() async {
    // Use same positions as spaceship (skip middle position at index 2)
    final availableX = [
      game.size.x / 10, // index 0
      game.size.x * 3 / 10, // index 1
      game.size.x * 6 / 10, // index 3 (skip 2)
      game.size.x * 8 / 10, // index 4
    ];

    final spriteMap = {
      'A': ('alienA.png', availableX[0]),
      'B': ('alienB.png', availableX[1]),
      'C': ('alienC.png', availableX[2]),
      'D': ('alienD.png', availableX[3]),
    };

    final spriteInfo = spriteMap[optionValue];
    if (spriteInfo == null) return;

    final alienSpriteData = await game.loadSprite(spriteInfo.$1);
    basePosition = Vector2(spriteInfo.$2 + 170, 400);

    // Set this component's position
    position = basePosition.clone();
    size = alienSize;
    anchor = Anchor.center;

    // All children use relative positions (0,0 is center of this component)
    alienSprite = SpriteComponent(
      sprite: alienSpriteData,
      size: alienSize,
      position: Vector2.zero(),
      anchor: Anchor.center,
    );
    add(alienSprite);

    add(
      RectangleHitbox(
        size: alienSize,
        position: Vector2.zero(),
        anchor: Anchor.center,
      ),
    );

    // Add option label (A, B, C, D) with background
    final labelBg =
        RectangleComponent(
          size: Vector2(40, 40),
          position: Vector2(0, -alienSize.y / 2 - 40),
          anchor: Anchor.center,
          paint: Paint()..color = Colors.yellow.withOpacity(0.9),
        )..add(
          RectangleComponent(
            size: Vector2(36, 36),
            position: Vector2(20, 20),
            anchor: Anchor.center,
            paint: Paint()..color = const Color(0xFF004A59),
          ),
        );
    add(labelBg);

    optionLabel = TextComponent(
      text: optionValue,
      position: Vector2(0, -alienSize.y / 2 - 40),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellowAccent,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(optionLabel);

    // Add option text with background for better readability
    final optionTextBg = RectangleComponent(
      size: Vector2(140, 50),
      position: Vector2(0, alienSize.y / 2 + 30),
      anchor: Anchor.center,
      paint: Paint()..color = Colors.black54,
    );
    add(optionTextBg);

    optionTextComponent = TextComponent(
      text: _truncateText(optionText, 20),
      position: Vector2(0, alienSize.y / 2 + 15),
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    add(optionTextComponent);
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Bullet && !isHit && !game.gameCompleted) {
      isHit = true;

      // Add explosion effect at alien position
      final explosion = ExplosionEffect(explosionPosition: basePosition);
      game.add(explosion);

      other.removeFromParent();
      onHit?.call();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update elapsed time for animation
    elapsedTime += dt;

    // Calculate rotation angle using sine wave
    final rotationAngle =
        math.sin(elapsedTime * rotationSpeed) * rotationAmplitude;

    // Apply rotation to alien sprite only
    alienSprite.angle = rotationAngle;

    // Add subtle bounce effect to entire alien component (reduced amplitude)
    final bounceOffset = math.sin(elapsedTime * 3) * 3;
    position = basePosition.clone()..y += bounceOffset;
  }
}
