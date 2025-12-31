import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/core/api/api_client.dart';
import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/data/repositories/student_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/quiz_session/quiz_session_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/quiz_session/quiz_session_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/quiz_session/quiz_session_state.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/space_game.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/quiz_page.dart';

class SpaceGamePage extends StatelessWidget {
  final String sessionId;
  final String quizId;

  const SpaceGamePage({
    super.key,
    required this.sessionId,
    required this.quizId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          QuizSessionBloc(StudentRepository(ApiClient()))
            ..add(LoadQuizSessionEvent(sessionId: sessionId, quizId: quizId)),
      child: BlocConsumer<QuizSessionBloc, QuizSessionState>(
        listener: (context, state) {
          // Listen to state changes but don't rebuild during submission
          if (state is QuizSessionSubmitting) {
            print('📤 [SpaceGamePage] Quiz is submitting...');
          }
        },
        buildWhen: (previous, current) {
          // Don't rebuild when submitting - keep game visible
          return current is! QuizSessionSubmitting;
        },
        builder: (context, state) {
          if (state is QuizSessionLoading) {
            return const Scaffold(
              backgroundColor: Color(0xFF001233),
              body: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }

          if (state is QuizSessionError) {
            return Scaffold(
              backgroundColor: const Color(0xFF001233),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Kembali'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is QuizSessionLoaded) {
            return _SpaceGameView(
              sessionId: sessionId,
              quizId: quizId,
              questions: state.questions,
            );
          }

          return const Scaffold(
            backgroundColor: Color(0xFF001233),
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        },
      ),
    );
  }
}

class _SpaceGameView extends StatefulWidget {
  final String sessionId;
  final String quizId;
  final List<QuestionModel> questions;

  const _SpaceGameView({
    required this.sessionId,
    required this.quizId,
    required this.questions,
  });

  @override
  State<_SpaceGameView> createState() => _SpaceGameViewState();
}

class _SpaceGameViewState extends State<_SpaceGameView> {
  late SpaceGame game;
  bool _isCompleting = false;
  final GlobalKey _gameKey = GlobalKey();
  late QuizSessionBloc _quizBloc;
  late NavigatorState _navigator;
  late StudentRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = StudentRepository(ApiClient());
    game = SpaceGame(
      questions: widget.questions,
      onAnswerSubmit: _onSingleAnswerSubmit,
      onAnswersSubmit: _onAnswersSubmit,
      onGameComplete: _onGameComplete,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save references to avoid accessing deactivated context later
    _quizBloc = context.read<QuizSessionBloc>();
    _navigator = Navigator.of(context, rootNavigator: true);
  }

  @override
  void dispose() {
    print('🗑️ [SpaceGamePage] Disposing game');
    game.pauseEngine();
    super.dispose();
  }

  // Submit single answer immediately when question is answered
  void _onSingleAnswerSubmit(String questionId, String answer) async {
    print(
      '🚀 [SpaceGame] Submitting single answer: questionId=$questionId, answer=$answer',
    );

    try {
      await _repository.submitAnswer(
        sessionId: widget.sessionId,
        questionId: questionId,
        selectedAnswer: answer,
      );
      print('✅ [SpaceGame] Answer submitted successfully to database');
    } catch (e) {
      print('❌ [SpaceGame] Error submitting answer: $e');
    }
  }

  void _onAnswersSubmit(Map<int, String> answers) {
    // All answers already submitted per question, just end the quiz session
    print(
      '🏁 [SpaceGame] All answers already submitted, ending quiz session...',
    );

    // End quiz session using BLoC (calls _onEndQuizSession)
    _quizBloc.add(const EndQuizSessionEvent());
  }

  void _onGameComplete() {
    if (!mounted || _isCompleting) {
      print('⚠️ [SpaceGamePage] Already completing or not mounted, ignoring');
      return;
    }

    _isCompleting = true;
    print('🎬 [SpaceGamePage] Game completion triggered');

    // Pause game immediately
    game.pauseEngine();

    // Save context before async operations
    final savedContext = context;

    // Use SchedulerBinding to ensure dialog shows after current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        print('⚠️ [SpaceGamePage] Widget unmounted before dialog');
        return;
      }

      // Show completion dialog and navigate
      showDialog(
        context: savedContext,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Quiz Selesai!'),
          content: const Text('Semua jawaban telah disubmit. Terima kasih!'),
          actions: [
            ElevatedButton(
              onPressed: () {
                print('🏠 [SpaceGamePage] Navigating to home...');

                // Close dialog using its own context
                Navigator.of(dialogContext).pop();

                // Reset quiz session using saved BLoC reference
                try {
                  _quizBloc.add(const ResetQuizSessionEvent());
                  print('✅ [SpaceGamePage] Quiz session reset');
                } catch (e) {
                  print('⚠️ [SpaceGamePage] Error resetting session: $e');
                }

                // Navigate back to home using saved navigator
                try {
                  _navigator.popUntil((route) => route.isFirst);
                  print('✅ [SpaceGamePage] Navigated to home');
                } catch (e) {
                  print('⚠️ [SpaceGamePage] Navigation error: $e');
                }
              },
              child: const Text('Kembali ke Beranda'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QuizSessionBloc, QuizSessionState>(
      listener: (context, state) {
        if (state is QuizSessionEnded) {
          print('🏆 [SpaceGamePage] Quiz ended: ${state.message}');
          print('📊 [SpaceGamePage] Score: ${state.score}');
        } else if (state is QuizSessionError) {
          print('❌ [SpaceGamePage] Error: ${state.message}');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF001233),
        body: GameWidget(key: _gameKey, game: game),
      ),
    );
  }
}
