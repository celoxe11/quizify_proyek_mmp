import 'package:bloc/bloc.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_session_model.dart';
import 'package:quizify_proyek_mmp/data/models/submission_answer_model.dart';
import 'package:quizify_proyek_mmp/domain/repositories/admin_repository.dart';

part 'admin_student_answers_event.dart';
part 'admin_student_answers_state.dart';

class AdminStudentAnswersBloc
    extends Bloc<AdminStudentAnswersEvent, AdminStudentAnswersState> {
  final AdminRepository adminRepository;

  AdminStudentAnswersBloc({required this.adminRepository})
    : super(AdminStudentAnswersInitial()) {
    on<LoadAdminStudentAnswersEvent>(_onLoadStudentAnswers);
  }

  /// Load student's answers for a specific quiz
  Future<void> _onLoadStudentAnswers(
    LoadAdminStudentAnswersEvent event,
    Emitter<AdminStudentAnswersState> emit,
  ) async {
    emit(AdminStudentAnswersLoading());

    print('[AdminStudentAnswersBloc] Loading answers for:');
    print('  Quiz ID: ${event.quizId}');
    print('  Student ID: "${event.studentId}"');
    print('  Session ID: "${event.sessionId}"');
    print('  Student ID length: ${event.studentId.length}');
    print('  Student ID isEmpty: ${event.studentId.isEmpty}');

    if (event.studentId.isEmpty) {
      emit(
        AdminStudentAnswersError(
          message: 'Student ID is empty. Cannot fetch answers.',
        ),
      );
      return;
    }

    try {
      final response = await adminRepository.fetchStudentAnswers(
        studentId: event.studentId,
        quizId: event.quizId,
        sessionId: event.sessionId,
      );

      print('[AdminStudentAnswersBloc] Response received:');
      print('  Response keys: ${response.keys}');

      // Parse single session object
      final sessionJson = response['session'] as Map<String, dynamic>;
      final session = QuizSessionModel.fromJson(sessionJson);

      // Parse answers array (each answer includes nested Question object)
      final answersList = (response['answers'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();

      print('[AdminStudentAnswersBloc] Answers count: ${answersList.length}');

      final answers = answersList.map((json) {
        print(
          '  Answer: question_id=${json['question_id']}, selected_answer=${json['selected_answer']}',
        );
        return SubmissionAnswerModel.fromJsonWithQuestion(json);
      }).toList();

      print(
        '[AdminStudentAnswersBloc] Parsed answers count: ${answers.length}',
      );

      emit(AdminStudentAnswersLoaded(session: session, answers: answers));
    } catch (e) {
      print('Error loading student answers: $e');
      emit(
        AdminStudentAnswersError(
          message: 'Failed to load student answers: ${e.toString()}',
        ),
      );
    }
  }
}
