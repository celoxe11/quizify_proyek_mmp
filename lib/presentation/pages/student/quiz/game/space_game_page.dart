import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/space_game.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/quiz_page.dart';

class SpaceGamePage extends StatefulWidget {
  final String sessionId;
  final String quizId;

  const SpaceGamePage({
    super.key,
    required this.sessionId,
    required this.quizId,
  });

  @override
  State<SpaceGamePage> createState() => _SpaceGamePageState();
}

class _SpaceGamePageState extends State<SpaceGamePage> {
  late SpaceGame game;

  @override
  void initState() {
    super.initState();
    game = SpaceGame(onGameComplete: _onGameComplete);
  }

  void _onGameComplete() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            QuizPage(sessionId: widget.sessionId, quizId: widget.quizId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001233),
      body: Stack(
        children: [
          GameWidget(game: game),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 32),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Skip Game?'),
                    content: const Text(
                      'Do you want to skip the game and go directly to the quiz?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _onGameComplete();
                        },
                        child: const Text('Skip to Quiz'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
