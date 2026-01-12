import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/domain/repositories/teacher_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/generate_question/generate_question_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/teacher/generate_question/generate_question_state.dart';

class GenerateQuestionBloc
    extends Bloc<GenerateQuestionEvent, GenerateQuestionState> {
  final TeacherRepository _teacherRepository;

  GenerateQuestionBloc({
    required TeacherRepository teacherRepository,
  }) : _teacherRepository = teacherRepository,
       super(GenerateQuestionInitial()) {
    on<GenerateQuestionWithAIEvent>(_onGenerateQuestionWithAI);
  }

  Future<void> _onGenerateQuestionWithAI(
    GenerateQuestionWithAIEvent event,
    Emitter<GenerateQuestionState> emit,
  ) async {
    emit(GenerateQuestionLoading());

    try {
      final aiGeneratedQuestions = await _teacherRepository.generateQuestion(
        type: event.type,
        difficulty: event.difficulty,
        category: event.category,
        topic: event.topic,
        language: event.language,
        context: event.context,
        ageGroup: event.ageGroup,
        avoidTopics: event.avoidTopics,
        includeExplanation: event.includeExplanation,
        questionStyle: event.questionStyle,
      );

      emit(GenerateQuestionSuccess(question: aiGeneratedQuestions));
    } catch (e) {
      emit(
        GenerateQuestionFailure(
          error: 'Failed to generate questions with AI: ${e.toString()}',
        ),
      );
    }
  }
}
