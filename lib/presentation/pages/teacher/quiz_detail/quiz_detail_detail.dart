import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';
import 'package:quizify_proyek_mmp/presentation/pages/teacher/quiz_detail/edit_quiz_page.dart';

class TeacherQuizDetailPage extends StatefulWidget {
  static const double _kMobileBreakpoint = 600;
  static const double _kDesktopMaxWidth = 900;

  const TeacherQuizDetailPage({super.key, required this.quiz});

  final QuizModel quiz;

  @override
  State<TeacherQuizDetailPage> createState() => _TeacherQuizDetailPageState();
}

class _TeacherQuizDetailPageState extends State<TeacherQuizDetailPage>
    with SingleTickerProviderStateMixin {
  final List<QuestionModel> _questions = [];
  bool _isLoading = false;

  // Tab Controller
  late TabController _tabController;

  // TODO: Get this from authenticated user data
  // For now, set to true to show the Accuracy tab for testing
  bool _isPremiumUser = true;

  // Students who attended the quiz
  // TODO: Load from backend using getQuizResult endpoint
  final List<Map<String, dynamic>> _students = [];
  bool _isLoadingStudents = false;

  // Accuracy results (premium only)
  // TODO: Load from backend using getQuizAccuracy endpoint
  final List<Map<String, dynamic>> _accuracyResults = [];
  bool _isLoadingAccuracy = false;

  @override
  void initState() {
    super.initState();
    // Initialize TabController with dynamic length based on premium status
    _tabController = TabController(length: _isPremiumUser ? 3 : 2, vsync: this);
    _loadQuestions();
    _loadStudents();
    if (_isPremiumUser) {
      _loadAccuracyResults();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Implement backend call to load questions
    // Example: final questions = await questionRepository.getByQuizId(widget.quiz.id);
    // setState(() {
    //   _questions.addAll(questions);
    //   _isLoading = false;
    // });

    // Simulate loading delay for now
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoadingStudents = true;
    });

    // TODO: Implement backend call to load students who attended the quiz
    // Use the getQuizResult endpoint: GET /api/teacher/quiz/:quiz_id/result
    // Example:
    // final response = await http.get('/api/teacher/quiz/${widget.quiz.id}/result');
    // setState(() {
    //   _students.addAll(response.results);
    //   _isLoadingStudents = false;
    // });

    // Simulate loading with dummy data for now
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      // Dummy data for testing
      _students.addAll([
        {
          'student': 'John Doe',
          'score': 85,
          'started_at': '2024-12-10T10:00:00',
          'ended_at': '2024-12-10T10:30:00',
        },
        {
          'student': 'Jane Smith',
          'score': 92,
          'started_at': '2024-12-10T11:00:00',
          'ended_at': '2024-12-10T11:25:00',
        },
        {
          'student': 'Bob Johnson',
          'score': 78,
          'started_at': '2024-12-10T14:00:00',
          'ended_at': '2024-12-10T14:35:00',
        },
      ]);
      _isLoadingStudents = false;
    });
  }

  Future<void> _loadAccuracyResults() async {
    setState(() {
      _isLoadingAccuracy = true;
    });

    // TODO: Implement backend call to load accuracy results (premium only)
    // Use the getQuizAccuracy endpoint: GET /api/teacher/quiz/:quiz_id/accuracy
    // Example:
    // final response = await http.get('/api/teacher/quiz/${widget.quiz.id}/accuracy');
    // setState(() {
    //   _accuracyResults.addAll(response.question_stats);
    //   _isLoadingAccuracy = false;
    // });

    // Simulate loading with dummy data for now
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      // Dummy data for testing
      _accuracyResults.addAll([
        {
          'question_id': 'Q001',
          'question': 'What is 2 + 2?',
          'total_answered': 10,
          'correct_answers': 9,
          'accuracy': 90,
        },
        {
          'question_id': 'Q002',
          'question': 'What is the capital of France?',
          'total_answered': 10,
          'correct_answers': 7,
          'accuracy': 70,
        },
        {
          'question_id': 'Q003',
          'question': 'What is H2O?',
          'total_answered': 10,
          'correct_answers': 10,
          'accuracy': 100,
        },
      ]);
      _isLoadingAccuracy = false;
    });
  }

  void _copyCodeToClipboard() {
    // For now, use the quiz ID as code since there's no dedicated code field
    // TODO: Update this when quiz code field is added to QuizModel
    final code = widget.quiz.id.substring(0, 8).toUpperCase();
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Quiz code copied to clipboard!'),
        backgroundColor: AppColors.darkAzure,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'public':
        return 'Public';
      case 'private':
        return 'Private';
      case 'draft':
        return 'Draft';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'public':
        return Colors.green;
      case 'private':
        return Colors.orange;
      case 'draft':
        return Colors.grey;
      default:
        return AppColors.darkAzure;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.of(context).size.width >=
        TeacherQuizDetailPage._kMobileBreakpoint;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = isDesktop
        ? TeacherQuizDetailPage._kDesktopMaxWidth
        : double.infinity;

    return Scaffold(
      backgroundColor: AppColors.dirtyCyan,
      appBar: AppBar(
        backgroundColor: AppColors.darkAzure,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go("/teacher/quizzes"),
        ),
        automaticallyImplyLeading: false,
        title: const Text(
          'Quiz Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeacherEditQuizPage(quiz: widget.quiz),
                ),
              );
            },
            tooltip: 'Edit Quiz',
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              _showDeleteConfirmation();
            },
            tooltip: 'Delete Quiz',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          width: screenWidth,
          child: Column(
            children: [
              // Quiz Info Card (scrollable header)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 16.0 : 12.0,
                  vertical: 16.0,
                ),
                child: _buildQuizInfoCard(isDesktop),
              ),

              // Tab Bar
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 16.0 : 12.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.darkAzure,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.darkAzure,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  tabs: [
                    const Tab(
                      icon: Icon(Icons.quiz_outlined),
                      text: 'Questions',
                    ),
                    const Tab(
                      icon: Icon(Icons.people_outline),
                      text: 'Students',
                    ),
                    if (_isPremiumUser)
                      const Tab(
                        icon: Icon(Icons.analytics_outlined),
                        text: 'Accuracy',
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Tab Bar View
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Questions Tab
                    SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 16.0 : 12.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildQuestionsList(isDesktop),
                          const SizedBox(height: 16.0),
                        ],
                      ),
                    ),

                    // Students Tab
                    SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 16.0 : 12.0,
                      ),
                      child: _buildStudentsTab(isDesktop),
                    ),

                    // Accuracy Tab (only for premium users)
                    if (_isPremiumUser)
                      SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 16.0 : 12.0,
                        ),
                        child: _buildAccuracyTab(isDesktop),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Students Tab
  // ============================================================
  Widget _buildStudentsTab(bool isDesktop) {
    if (_isLoadingStudents) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.darkAzure),
        ),
      );
    }

    if (_students.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: AppColors.darkAzure.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No students have taken this quiz yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_students.length} Students Attended',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkAzure,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _students.length,
          itemBuilder: (context, index) {
            final student = _students[index];
            return _buildStudentCard(student, index);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student, int index) {
    final score = student['score'] as int;
    final scoreColor = score >= 80
        ? Colors.green
        : (score >= 60 ? Colors.orange : Colors.red);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.darkAzure,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Student Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['student'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Completed on ${_formatDateTime(student['ended_at'])}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textDark.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          // Score Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: scoreColor, width: 1.5),
            ),
            child: Text(
              '$score%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: scoreColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Accuracy Tab (Premium Only)
  // ============================================================
  Widget _buildAccuracyTab(bool isDesktop) {
    if (_isLoadingAccuracy) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.darkAzure),
        ),
      );
    }

    if (_accuracyResults.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 64,
                color: AppColors.darkAzure.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No accuracy data available yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Accuracy data will appear after students complete the quiz',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textDark.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Premium Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.amber, Colors.orange],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text(
                'Premium Feature',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Question Accuracy Analysis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkAzure,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _accuracyResults.length,
          itemBuilder: (context, index) {
            final result = _accuracyResults[index];
            return _buildAccuracyCard(result, index);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAccuracyCard(Map<String, dynamic> result, int index) {
    final accuracy = result['accuracy'] as int;
    final correctAnswers = result['correct_answers'] as int;
    final totalAnswered = result['total_answered'] as int;
    final accuracyColor = accuracy >= 80
        ? Colors.green
        : (accuracy >= 60 ? Colors.orange : Colors.red);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Question Number
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.darkAzure,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Question Text
              Expanded(
                child: Text(
                  result['question'] ?? 'Unknown question',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Accuracy Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$correctAnswers / $totalAnswered correct',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textDark.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    '$accuracy%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: accuracyColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: accuracy / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(accuracyColor),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'Unknown';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  Widget _buildQuizInfoCard(bool isDesktop) {
    final quizCode = widget.quiz.id.length >= 8
        ? widget.quiz.id.substring(0, 8).toUpperCase()
        : widget.quiz.id.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Status Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.quiz.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkAzure,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          widget.quiz.status,
                        ).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(widget.quiz.status),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.quiz.status.toLowerCase() == 'public'
                                ? Icons.public
                                : Icons.lock,
                            size: 16,
                            color: _getStatusColor(widget.quiz.status),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getStatusLabel(widget.quiz.status),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(widget.quiz.status),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Edit Button in Header Card
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TeacherEditQuizPage(quiz: widget.quiz),
                    ),
                  );
                },
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkAzure,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20.0),

          // Description
          if (widget.quiz.description != null &&
              widget.quiz.description!.isNotEmpty) ...[
            Text(
              widget.quiz.description!,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textDark.withOpacity(0.8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20.0),
          ],

          const Divider(height: 1, color: AppColors.lightCyan),
          const SizedBox(height: 20.0),

          // Quiz Details Grid
          if (isDesktop)
            _buildDesktopDetailsGrid(quizCode)
          else
            _buildMobileDetailsColumn(quizCode),

          // Created/Updated Date
          if (widget.quiz.createdAt != null) ...[
            const SizedBox(height: 20.0),
            const Divider(height: 1, color: AppColors.lightCyan),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textDark.withOpacity(0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  'Created: ${_formatDate(widget.quiz.createdAt!)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textDark.withOpacity(0.5),
                  ),
                ),
                if (widget.quiz.updatedAt != null) ...[
                  const SizedBox(width: 16),
                  Text(
                    '•',
                    style: TextStyle(
                      color: AppColors.textDark.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Updated: ${_formatDate(widget.quiz.updatedAt!)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textDark.withOpacity(0.5),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDesktopDetailsGrid(String quizCode) {
    return Row(
      children: [
        // Quiz Code
        Expanded(
          child: _buildDetailItem(
            icon: Icons.qr_code,
            label: 'Quiz Code',
            value: quizCode,
            onCopy: _copyCodeToClipboard,
          ),
        ),
        const SizedBox(width: 16),
        // Category
        Expanded(
          child: _buildDetailItem(
            icon: Icons.category,
            label: 'Category',
            value: widget.quiz.category ?? 'Uncategorized',
          ),
        ),
        const SizedBox(width: 16),
        // Total Questions
        Expanded(
          child: _buildDetailItem(
            icon: Icons.quiz,
            label: 'Questions',
            value: '${_questions.length}',
          ),
        ),
      ],
    );
  }

  Widget _buildMobileDetailsColumn(String quizCode) {
    return Column(
      children: [
        _buildDetailItem(
          icon: Icons.qr_code,
          label: 'Quiz Code',
          value: quizCode,
          onCopy: _copyCodeToClipboard,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                icon: Icons.category,
                label: 'Category',
                value: widget.quiz.category ?? 'Uncategorized',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDetailItem(
                icon: Icons.quiz,
                label: 'Questions',
                value: '${_questions.length}',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightCyan.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.darkAzure.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.darkAzure),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textDark.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkAzure,
                  ),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              icon: const Icon(Icons.copy, size: 20),
              onPressed: onCopy,
              color: AppColors.darkAzure,
              tooltip: 'Copy',
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList(bool isDesktop) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            children: [
              CircularProgressIndicator(color: AppColors.darkAzure),
              SizedBox(height: 16),
              Text(
                'Loading questions...',
                style: TextStyle(color: AppColors.darkAzure),
              ),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.quiz_outlined,
                size: 64,
                color: AppColors.darkAzure.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No questions yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Click "Add Question" to create your first question',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textDark.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _questions.length,
      itemBuilder: (context, index) {
        final question = _questions[index];
        return _buildQuestionCard(question, index);
      },
    );
  }

  Widget _buildQuestionCard(QuestionModel question, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.darkAzure,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Text(
          question.questionText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              _buildQuestionTag(
                question.type == 'multiple' ? 'Multiple Choice' : 'True/False',
              ),
              const SizedBox(width: 8),
              _buildQuestionTag(question.difficulty, isColored: true),
            ],
          ),
        ),
        children: [
          const Divider(),
          const SizedBox(height: 8),
          // Options
          ...question.options.asMap().entries.map((entry) {
            final optionIndex = entry.key;
            final option = entry.value;
            final isCorrect = option == question.correctAnswer;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isCorrect
                    ? Colors.green.withOpacity(0.1)
                    : AppColors.lightCyan.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCorrect ? Colors.green : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? Colors.green
                          : AppColors.darkAzure.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCorrect
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : Text(
                              String.fromCharCode(
                                65 + optionIndex,
                              ), // A, B, C, D
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkAzure.withOpacity(0.7),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 14,
                        color: isCorrect
                            ? Colors.green.shade700
                            : AppColors.textDark,
                        fontWeight: isCorrect
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isCorrect)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Correct',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  // TODO: Edit question
                },
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.darkAzure,
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  // TODO: Delete question
                },
                icon: const Icon(Icons.delete, size: 18),
                label: const Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionTag(String text, {bool isColored = false}) {
    Color bgColor;
    Color textColor;

    if (isColored) {
      switch (text.toLowerCase()) {
        case 'easy':
          bgColor = Colors.green.withOpacity(0.1);
          textColor = Colors.green;
          break;
        case 'medium':
          bgColor = Colors.orange.withOpacity(0.1);
          textColor = Colors.orange;
          break;
        case 'hard':
          bgColor = Colors.red.withOpacity(0.1);
          textColor = Colors.red;
          break;
        default:
          bgColor = AppColors.lightCyan.withOpacity(0.5);
          textColor = AppColors.darkAzure;
      }
    } else {
      bgColor = AppColors.lightCyan.withOpacity(0.5);
      textColor = AppColors.darkAzure;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Delete Quiz'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${widget.quiz.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement delete logic
              Navigator.pop(context);
              context.go('/teacher/quizzes');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
