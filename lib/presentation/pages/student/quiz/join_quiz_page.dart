import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quizify_proyek_mmp/core/api/api_client.dart';
import 'package:quizify_proyek_mmp/core/api/quiz/quiz_api.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';
import 'package:quizify_proyek_mmp/presentation/pages/student/quiz/quiz_page.dart';

class JoinQuizPage extends StatefulWidget {
  const JoinQuizPage({super.key});

  @override
  State<JoinQuizPage> createState() => _JoinQuizPageState();
}

class _JoinQuizPageState extends State<JoinQuizPage> {
  final TextEditingController _quizCodeController = TextEditingController();
  final QuizApi _quizApi = QuizApi(ApiClient());
  bool _isLoading = false;

  @override
  void dispose() {
    _quizCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleJoinQuiz() async {
    final code = _quizCodeController.text.trim();

    if (code.isEmpty) {
      _showErrorDialog('Silakan masukkan kode quiz');
      return;
    }

    // Check if user is authenticated
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showErrorDialog('Anda harus login terlebih dahulu');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Refresh token to ensure it's valid
      await currentUser.getIdToken(true);

      // Start quiz session by code
      final response = await _quizApi.startQuizByCode(code);

      if (!mounted) return;

      // Extract session_id from response
      final sessionId = response['session_id'] as String?;
      if (sessionId == null) {
        _showErrorDialog('Session ID tidak ditemukan dalam response');
        return;
      }

      // Navigate to quiz page with session ID
      // Note: You might need to fetch the quiz details using the session
      // For now, we'll navigate with the session ID
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QuizPage(sessionId: sessionId)),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      _showErrorDialog(e.message);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showErrorDialog('Authentication error: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Terjadi kesalahan: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                        enabled: !_isLoading,
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
                        onPressed: _isLoading ? null : _handleJoinQuiz,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
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
