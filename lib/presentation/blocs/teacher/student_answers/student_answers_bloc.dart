import 'package:bloc/bloc.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_session_model.dart';
import 'package:quizify_proyek_mmp/data/models/submission_answer_model.dart';
import 'package:quizify_proyek_mmp/data/repositories/teacher_repository.dart';
import 'package:quizify_proyek_mmp/domain/repositories/teacher_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/student_answers/student_answers_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/student_answers/student_answers_state.dart';

class StudentAnswersBloc
    extends Bloc<StudentAnswersEvent, StudentAnswersState> {
  final TeacherRepository teacherRepository;

  StudentAnswersBloc({TeacherRepository? teacherRepository})
    : teacherRepository = teacherRepository ?? TeacherRepositoryImpl(),
      super(StudentAnswersInitial()) {
    on<LoadStudentAnswersEvent>(_onLoadStudentAnswers);
  }

  /// Load student's answers for a specific quiz
  Future<void> _onLoadStudentAnswers(
    LoadStudentAnswersEvent event,
    Emitter<StudentAnswersState> emit,
  ) async {
    emit(StudentAnswersLoading());

    try {
      final response = await teacherRepository.getStudentAnswers(
        studentId: event.studentId,
        quizId: event.quizId,
      );

      // Parse single session object
      final sessionJson = response['session'] as Map<String, dynamic>;
      final session = QuizSessionModel.fromJson(sessionJson);

      // Parse answers array (each answer includes nested Question object)
      final answersList = response['answers'] as List<Map<String, dynamic>>;
      final answers = answersList
          .map((json) => SubmissionAnswerModel.fromJsonWithQuestion(json))
          .toList();

      emit(
        StudentAnswersLoaded(
          session: session,
          answers: answers,
        ),
      );
    } catch (e) {
      print('Error loading student answers: $e');
      emit(
        StudentAnswersError(
          message: 'Failed to load student answers: ${e.toString()}',
        ),
      );
    }
  }
}
