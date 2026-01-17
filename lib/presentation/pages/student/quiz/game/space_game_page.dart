import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
  final Map<String, String>? answeredQuestions;
  final int? startingQuestionIndex;
  final bool isResuming;

  const SpaceGamePage({
    super.key,
    required this.sessionId,
    required this.quizId,
    this.answeredQuestions,
    this.startingQuestionIndex,
    this.isResuming = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          QuizSessionBloc(context.read<StudentRepository>())..add(
            LoadQuizSessionEvent(
              sessionId: sessionId,
              quizId: quizId,
              answeredQuestions: answeredQuestions ?? {},
              startingQuestionIndex: startingQuestionIndex ?? 0,
            ),
          ),
      child: BlocConsumer<QuizSessionBloc, QuizSessionState>(
        listener: (context, state) {
          // Listen to state changes but don't rebuild during submission
          if (state is QuizSessionSubmitting) {
            print('📤 [SpaceGamePage] Quiz is submitting...');
          }
        },
        buildWhen: (previous, current) {
          // Don't rebuild when submitting, ending, or ended - keep game visible
          // Only rebuild for initial loading states
          return current is! QuizSessionSubmitting &&
              current is! QuizSessionEnding &&
              current is! QuizSessionEnded;
        },
        builder: (context, state) {
          if (state is QuizSessionLoading) {
            return Scaffold(
              backgroundColor: const Color(0xFF001233),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    if (isResuming) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Melanjutkan quiz...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ],
                ),
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
              answeredQuestions: state.selectedAnswers,
              startingQuestionIndex: state.currentQuestionIndex,
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
  final Map<String, String> answeredQuestions;
  final int startingQuestionIndex;

  const _SpaceGameView({
    required this.sessionId,
    required this.quizId,
    required this.questions,
    this.answeredQuestions = const {},
    this.startingQuestionIndex = 0,
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
  BuildContext? _dialogContext;

  // Image modal state
  String? _imageModalUrl;
  bool _isImageModalVisible = false;

  @override
  void initState() {
    super.initState();
    game = SpaceGame(
      questions: widget.questions,
      onAnswerSubmit: _onSingleAnswerSubmit,
      onAnswersSubmit: _onAnswersSubmit,
      onGameComplete: _onGameComplete,
      onShowImageModal: _showImageModal,
      startingQuestionIndex: widget.startingQuestionIndex,
      answeredQuestions: widget.answeredQuestions,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save references to avoid accessing deactivated context later
    _quizBloc = context.read<QuizSessionBloc>();
    _navigator = Navigator.of(context, rootNavigator: true);
    _repository = context.read<StudentRepository>();
  }

  @override
  void dispose() {
    print('🗑️ [SpaceGamePage] Disposing game');
    game.pauseEngine();
    super.dispose();
  }

  void _showImageModal(String imageUrl) {
    setState(() {
      _imageModalUrl = imageUrl;
      _isImageModalVisible = true;
    });
  }

  void _hideImageModal() {
    setState(() {
      _isImageModalVisible = false;
      _imageModalUrl = null;
    });
    // Notify game that modal is closed
    game.closeImageModal();
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
    // This is called BEFORE onGameComplete, so we do nothing here
    print(
      '📋 [SpaceGame] onAnswersSubmit called with ${answers.length} answers',
    );
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

    // Show loading dialog FIRST
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        // Save dialog context for later use
        _dialogContext = dialogContext;
        return const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Menyelesaikan quiz...'),
            ],
          ),
        );
      },
    );

    // THEN end quiz session (with small delay to ensure dialog is shown)
    print('🏁 [SpaceGame] Ending quiz session...');
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _quizBloc.add(const EndQuizSessionEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QuizSessionBloc, QuizSessionState>(
      listener: (context, state) {
        print('🔄 [SpaceGamePage] State changed: ${state.runtimeType}');

        if (state is QuizSessionEnded) {
          print('🏆 [SpaceGamePage] Quiz ended: ${state.message}');
          print('📊 [SpaceGamePage] Score: ${state.score}');

          // Close loading dialog and show result
          if (_isCompleting && mounted) {
            print('🚪 [SpaceGamePage] Closing loading dialog...');

            // Close loading dialog using saved context
            if (_dialogContext != null && _dialogContext!.mounted) {
              Navigator.of(_dialogContext!).pop();
              _dialogContext = null;
            } else {
              // Fallback: use root navigator
              _navigator.pop();
            }

            // Use a small delay to ensure smooth transition
            Future.delayed(const Duration(milliseconds: 100), () {
              if (!mounted) return;

              // Show result dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Quiz Selesai!'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(state.message, textAlign: TextAlign.center),
                      if (state.score != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Score: ${state.score}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        print('🏠 [SpaceGamePage] Navigating to home...');

                        // Close result dialog
                        Navigator.of(dialogContext).pop();

                        // Reset quiz session
                        try {
                          context.read<QuizSessionBloc>().add(
                            const ResetQuizSessionEvent(),
                          );
                          print('✅ [SpaceGamePage] Quiz session reset');
                        } catch (e) {
                          print(
                            '⚠️ [SpaceGamePage] Error resetting session: $e',
                          );
                        }

                        // Navigate back to home using GoRouter
                        try {
                          context.go('/student/home');
                          print('✅ [SpaceGamePage] Navigated to student/home');
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
        } else if (state is QuizSessionError && _isCompleting) {
          print('❌ [SpaceGamePage] Error: ${state.message}');

          // Close loading dialog
          if (mounted) {
            print('🚪 [SpaceGamePage] Closing loading dialog (error)...');

            // Close loading dialog using saved context
            if (_dialogContext != null && _dialogContext!.mounted) {
              Navigator.of(_dialogContext!).pop();
              _dialogContext = null;
            } else {
              _navigator.pop();
            }

            Future.delayed(const Duration(milliseconds: 100), () {
              if (!mounted) return;

              // Show error dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Error'),
                  content: Text(state.message),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        context.go('/student/home');
                      },
                      child: const Text('Kembali ke Beranda'),
                    ),
                  ],
                ),
              );
            });
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF001233),
        body: Stack(
          children: [
            GameWidget(key: _gameKey, game: game),
            // Image modal overlay
            if (_isImageModalVisible && _imageModalUrl != null)
              _ImageModalOverlay(
                imageUrl: _imageModalUrl!,
                onClose: _hideImageModal,
              ),
          ],
        ),
      ),
    );
  }
}

// Image modal overlay widget
class _ImageModalOverlay extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onClose;

  const _ImageModalOverlay({required this.imageUrl, required this.onClose});

  @override
  Widget build(BuildContext context) {
    print('🖼️ [ImageModal] Attempting to load image from: $imageUrl');

    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent closing when tapping on the content
            child: Container(
              margin: const EdgeInsets.all(20),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Close button
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text(
                            'Gambar Soal',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: onClose,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                  // Image
                  Flexible(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print('❌ [ImageModal] Error loading image: $error');
                          print('❌ [ImageModal] URL was: $imageUrl');
                          return Container(
                            height: 200,
                            padding: const EdgeInsets.all(20),
                            color: Colors.grey.shade300,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.broken_image,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Gagal memuat gambar',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    imageUrl,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
