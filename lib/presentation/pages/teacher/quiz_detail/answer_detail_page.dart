import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';

class TeacherAnswerDetailPage extends StatefulWidget {
  const TeacherAnswerDetailPage({super.key, required this.quiz});

  final QuizModel quiz;

  @override
  State<TeacherAnswerDetailPage> createState() => _TeacherAnswerDetailPageState();
}

class _TeacherAnswerDetailPageState extends State<TeacherAnswerDetailPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}