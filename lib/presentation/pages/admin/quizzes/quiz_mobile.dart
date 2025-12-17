import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quizify_proyek_mmp/core/api/api_client.dart';
import 'package:quizify_proyek_mmp/core/api/quiz/quiz_api.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';

class AdminQuizMobilePage extends StatefulWidget {
  const AdminQuizMobilePage({super.key});

  @override
  State<AdminQuizMobilePage> createState() => _AdminQuizMobilePageState();
}

class _AdminQuizMobilePageState extends State<AdminQuizMobilePage> {
  late final QuizApi _quizApi;
  late Future<List<QuizModel>> _futureQuizzes;

  @override
  void initState() {
    super.initState();
    _quizApi = QuizApi(ApiClient());
    _futureQuizzes = _quizApi.getAllQuizzes();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF007C89); // warna teks "Quizify" & FAB
    const Color lightTeal = Color(0xFFD6F2F3); // background area list

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _Header(primaryColor: primaryTeal),
          Expanded(
            child: Container(
              width: double.infinity,
              color: lightTeal,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quizzes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ====== PANGGIL API DI SINI ======
                        Expanded(
                          child: FutureBuilder<List<QuizModel>>(
                            future: _futureQuizzes,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    'Failed to load quizzes: ${snapshot.error}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                );
                              }

                              final quizzes = snapshot.data ?? [];

                              if (quizzes.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No quizzes found.',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                );
                              }

                              return ListView.separated(
                                itemCount: quizzes.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final quiz = quizzes[index];
                                  return _QuizCard(
                                    title: quiz.title,
                                    onTap: () {
                                      // contoh: ke halaman detail quiz
                                      context.go('/admin/quizz/${quiz.id}');
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // FAB di kanan bawah, sedikit di atas bottom nav
                  Positioned(
                    right: 20,
                    bottom: 10,
                    child: FloatingActionButton(
                      onPressed: () {
                        // ke halaman create quiz
                        context.go('/admin/quizz/create');
                      },
                      backgroundColor: primaryTeal,
                      shape: const CircleBorder(),
                      child: const Icon(Icons.add, size: 30),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

/// Header putih dengan teks "Quizify" & ikon toko di kanan
class _Header extends StatelessWidget {
  final Color primaryColor;
  const _Header({required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(
            'Quizify',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: primaryColor,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              // TODO: ke halaman toko / admin lainnya
            },
            icon: const Icon(Icons.storefront_outlined, size: 28),
          ),
        ],
      ),
    );
  }
}

/// Card untuk tiap quiz
class _QuizCard extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const _QuizCard({
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.teal.shade200, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              // title diset via parent; biar simpel tetap pakai const teks default di design,
              // kalau mau pakai dynamic title, hapus const dan ganti jadi: Text(title, ...)
              'Quiz Title',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom navigation bar seperti di desain
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    const Color bottomBarColor = Color(0xFF00596B);
    const Color iconColor = Colors.black;

    return Container(
      height: 60,
      color: bottomBarColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: IconButton(
              onPressed: () {
                // TODO: ke home
              },
              icon: const Icon(Icons.home, color: iconColor, size: 28),
            ),
          ),
          Expanded(
            child: IconButton(
              onPressed: () {
                // TODO: ke daftar quiz / library
              },
              icon: const Icon(Icons.menu_book, color: iconColor, size: 28),
            ),
          ),
          Expanded(
            child: IconButton(
              onPressed: () {
                // TODO: ke profil
              },
              icon: const Icon(Icons.person, color: iconColor, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}
