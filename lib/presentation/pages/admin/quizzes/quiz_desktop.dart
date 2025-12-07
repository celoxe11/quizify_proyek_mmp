import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quizify_proyek_mmp/core/api/api_client.dart';
import 'package:quizify_proyek_mmp/core/api/quiz/quiz_api.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';

class AdminQuizDesktopPage extends StatefulWidget {
  const AdminQuizDesktopPage({super.key});

  static const double _kMobileBreakpoint = 600;

  @override
  State<AdminQuizDesktopPage> createState() => _AdminQuizDesktopPageState();
}

class _AdminQuizDesktopPageState extends State<AdminQuizDesktopPage> {
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
    const Color primaryTeal = Color(0xFF007C89);
    const Color lightTeal = Color(0xFFD6F2F3);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              children: [
                Text(
                  'Quizify',
                  style: TextStyle(
                    fontSize: 26,
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

          // BODY
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                color: lightTeal,
                padding: const EdgeInsets.fromLTRB(32, 24, 32, 120),
                height: MediaQuery.of(context).size.height - 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quizzes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ======= PANGGIL API DI SINI =======
                    FutureBuilder<List<QuizModel>>(
                      future: _futureQuizzes,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Text(
                            'Failed to load quizzes: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          );
                        }

                        final quizzes = snapshot.data ?? [];

                        if (quizzes.isEmpty) {
                          return const Text(
                            'No quizzes found.',
                            style: TextStyle(color: Colors.black54),
                          );
                        }

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final isMobile =
                                constraints.maxWidth <=
                                AdminQuizDesktopPage._kMobileBreakpoint;

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: quizzes.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final quiz = quizzes[index];
                                return _QuizCard(
                                  title: quiz.title,
                                  isCompact: isMobile,
                                  onTap: () {
                                    // contoh ke halaman detail
                                    // sesuaikan route kalau perlu
                                    context.go('/admin/quizz/${quiz.id}');
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/admin/quizz/create');
        },
        backgroundColor: primaryTeal,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _QuizCard extends StatelessWidget {
  final String title;
  final bool isCompact;
  final VoidCallback? onTap;

  const _QuizCard({required this.title, required this.isCompact, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.teal.shade200, width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 12 : 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
