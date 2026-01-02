import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/core/api/api_client.dart';
import 'package:quizify_proyek_mmp/data/repositories/student_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/join_quiz/join_quiz_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/join_quiz/join_quiz_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/join_quiz/join_quiz_state.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/game/space_game_page.dart';

class JoinQuizPage extends StatefulWidget {
  const JoinQuizPage({super.key});

  @override
  State<JoinQuizPage> createState() => _JoinQuizPageState();
}

class _JoinQuizPageState extends State<JoinQuizPage> {
  final TextEditingController _quizCodeController = TextEditingController();

  @override
  void dispose() {
    _quizCodeController.dispose();
    super.dispose();
  }

  void _handleJoinQuiz(BuildContext context) {
    final code = _quizCodeController.text.trim();

    if (code.isEmpty) {
      _showErrorDialog('Silakan masukkan kode quiz');
      return;
    }

    context.read<JoinQuizBloc>().add(JoinQuizByCodeEvent(code));
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF007C89);
    const Color bodyTeal = Color(0xFF63C5C5);
    const Color bottomBarColor = Color(0xFF00596B);

    return BlocProvider(
      create: (context) => JoinQuizBloc(context.read<StudentRepository>()),
      child: BlocListener<JoinQuizBloc, JoinQuizState>(
        listener: (context, state) {
          if (state is JoinQuizSuccess) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SpaceGamePage(
                  sessionId: state.sessionId,
                  quizId: state.quizId,
                ),
              ),
            );
          } else if (state is JoinQuizError) {
            _showErrorDialog(state.message);
          }
        },
        child: BlocBuilder<JoinQuizBloc, JoinQuizState>(
          builder: (context, state) {
            final isLoading = state is JoinQuizLoading;

            return _buildScaffold(context, isLoading, primaryTeal, bodyTeal);
          },
        ),
      ),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    bool isLoading,
    Color primaryTeal,
    Color bodyTeal,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // HEADER
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Text(
                  'Quizify',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: primaryTeal,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    // TODO: ke halaman merchant
                  },
                  icon: const Icon(Icons.storefront_outlined, size: 28),
                ),
              ],
            ),
          ),

          // BODY TEAL
          Expanded(
            child: Container(
              width: double.infinity,
              color: bodyTeal,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Quizify',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF004A59),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // INPUT QUIZ CODE
                    SizedBox(
                      width: 350,
                      child: TextField(
                        controller: _quizCodeController,
                        textAlign: TextAlign.center,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          hintText: 'Enter Quiz Code',
                          hintStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF007C89),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // BUTTON JOIN
                    SizedBox(
                      width: 350,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () => _handleJoinQuiz(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Join',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // TOMBOL BULAT DI TENGAH BOTTOM BAR
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: SizedBox(
      //   height: 64,
      //   width: 64,
      //   child: FloatingActionButton(
      //     onPressed: () {
      //       // TODO: aksi utama (misal scan / start)
      //     },
      //     backgroundColor: bottomBarColor,
      //     elevation: 4,
      //     child: Container(
      //       decoration: BoxDecoration(
      //         shape: BoxShape.circle,
      //         border: Border.all(color: Colors.white, width: 4),
      //         color: bottomBarColor,
      //       ),
      //     ),
      //   ),
      // ),

      // BOTTOM NAV
      // bottomNavigationBar: BottomAppBar(
      //   color: bottomBarColor,
      //   shape: const CircularNotchedRectangle(),
      //   notchMargin: 6,
      //   child: SizedBox(
      //     height: 60,
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceAround,
      //       children: [
      //         IconButton(
      //           onPressed: () {
      //             // TODO: home
      //           },
      //           icon: const Icon(Icons.home, color: Colors.black),
      //         ),
      //         IconButton(
      //           onPressed: () {
      //             // TODO: history / recent
      //           },
      //           icon: const Icon(Icons.history, color: Colors.black),
      //         ),
      //         const SizedBox(width: 40), // ruang untuk FAB tengah
      //         IconButton(
      //           onPressed: () {
      //             // TODO: search
      //           },
      //           icon: const Icon(Icons.search, color: Colors.black),
      //         ),
      //         IconButton(
      //           onPressed: () {
      //             // TODO: profile
      //           },
      //           icon: const Icon(Icons.person, color: Colors.black),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}
