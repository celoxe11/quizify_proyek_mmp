class AdminAnalyticsModel {
  final List<TeacherTrend> teacherTrends;
  final StudentParticipation studentParticipation;
  final List<QuizFlow> quizFlow;
  final List<UserActivity> userActivity;

  AdminAnalyticsModel({
    required this.teacherTrends,
    required this.studentParticipation,
    required this.quizFlow,
    required this.userActivity,
  });

  factory AdminAnalyticsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    // 1. Parsing Teacher Trends (Map ke List)
    // Backend kirim: {"Mr A": {"Math": 5}, "Mrs B": {...}}
    List<TeacherTrend> teachers = [];
    if (data['teacher_trends'] != null) {
      (data['teacher_trends'] as Map<String, dynamic>).forEach((name, cats) {
        teachers.add(TeacherTrend.fromJson(name, cats));
      });
    }

    // 2. Parsing Student Participation
    final studentPart = StudentParticipation.fromJson(data['student_participation'] ?? {});

    // 3. Parsing Quiz Flow
    List<QuizFlow> qFlow = [];
    if (data['quiz_flow'] != null) {
      qFlow = (data['quiz_flow'] as List).map((e) => QuizFlow.fromJson(e)).toList();
    }

    // 4. Parsing User Activity
    List<UserActivity> uActivity = [];
    if (data['user_activity'] != null) {
      uActivity = (data['user_activity'] as List).map((e) => UserActivity.fromJson(e)).toList();
    }

    return AdminAnalyticsModel(
      teacherTrends: teachers,
      studentParticipation: studentPart,
      quizFlow: qFlow,
      userActivity: uActivity,
    );
  }
}

class TeacherTrend {
  final String name;
  final double math;
  final double science;
  final double history;
  final double other;

  TeacherTrend({required this.name, required this.math, required this.science, required this.history, required this.other});

  factory TeacherTrend.fromJson(String name, Map<String, dynamic> json) {
    // Mapping kategori dinamis dari backend ke field tetap
    return TeacherTrend(
      name: name,
      math: (json['Math'] ?? 0).toDouble(),
      science: (json['Science'] ?? 0).toDouble(),
      history: (json['History'] ?? 0).toDouble(),
      other: (json['Uncategorized'] ?? 0).toDouble(),
    );
  }
}

class StudentParticipation {
  final int total;
  final int active;
  final int pending;

  StudentParticipation({required this.total, required this.active, required this.pending});

  factory StudentParticipation.fromJson(Map<String, dynamic> json) {
    return StudentParticipation(
      total: json['total'] ?? 0,
      active: json['active'] ?? 0,
      pending: json['pending'] ?? 0,
    );
  }
}

class QuizFlow {
  final String label; // "Q001"
  final double difficulty;
  final double failures;

  QuizFlow({required this.label, required this.difficulty, required this.failures});

  factory QuizFlow.fromJson(Map<String, dynamic> json) {
    return QuizFlow(
      label: json['label'] ?? 'Q?',
      difficulty: (json['difficulty'] ?? 0).toDouble(),
      failures: (json['failures'] ?? 0).toDouble(),
    );
  }
}

class UserActivity {
  final String day; // "Mon"
  final double registers;
  final double logins;

  UserActivity({required this.day, required this.registers, required this.logins});

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    return UserActivity(
      day: json['day'] ?? '',
      registers: (json['registers'] ?? 0).toDouble(),
      logins: (json['logins'] ?? 0).toDouble(),
    );
  }
}