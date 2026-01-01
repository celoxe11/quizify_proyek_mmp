import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';
import 'package:quizify_proyek_mmp/domain/repositories/teacher_repository.dart';

part 'edit_quiz_event.dart';
part 'edit_quiz_state.dart';

class EditQuizBloc extends Bloc<EditQuizEvent, EditQuizState> {
  final TeacherRepository _teacherRepository;

  EditQuizBloc({required TeacherRepository teacherRepository})
    : _teacherRepository = teacherRepository,
      super(EditQuizInitial()) {
    on<InitializeEditQuizEvent>(_onInitialize);
    on<SaveQuizEvent>(_onSaveQuiz);
    on<MarkChangesEvent>(_onMarkChanges);
  }

  /// Initialize the edit form with quiz data
  void _onInitialize(
    InitializeEditQuizEvent event,
    Emitter<EditQuizState> emit,
  ) {
    final quiz = event.quiz;

    // Generate quiz code from ID if not available
    final quizCode =
        quiz.quizCode ??
        (quiz.id.length >= 8
            ? quiz.id.substring(0, 8).toUpperCase()
            : quiz.id.toUpperCase());

    emit(
      EditQuizReady(
        originalQuiz: quiz,
        title: quiz.title,
        description: quiz.description ?? '',
        category: quiz.category ?? '',
        code: quizCode,
        isPublic: quiz.status.toLowerCase() == 'public',
        questions: List<QuestionModel>.from(event.questions),
        hasChanges: false,
        isSaving: false,
      ),
    );
  }

  /// Save the quiz and all questions
  Future<void> _onSaveQuiz(
    SaveQuizEvent event,
    Emitter<EditQuizState> emit,
  ) async {
    final currentState = state;
    if (currentState is! EditQuizReady) return;

    // Validate
    if (currentState.title.trim().isEmpty) {
      emit(const EditQuizError('Please enter a quiz title'));
      emit(currentState); // Return to ready state
      return;
    }

    emit(currentState.copyWith(isSaving: true));

    try {
      final updatedQuiz = await _teacherRepository.saveQuiz(
        quizId: event.quizId,
        title: event.title,
        description: event.description,
        category: event.category,
        status: event.status,
        quizCode: event.quizCode,
        questions: event.questions,
      );

      emit(EditQuizSaved(updatedQuiz));
    } catch (e) {
      // Parse error messages for user-friendly display
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception: ')) {
        errorMessage = errorMessage.replaceAll('Exception: ', '');
      }

      // Handle specific error cases
      if (errorMessage.contains('Anda sudah membuat kuis hari ini')) {
        errorMessage =
            'You have reached your daily quiz creation limit. Upgrade to premium for unlimited quizzes.';
      } else if (errorMessage.contains('Kode kuis sudah digunakan')) {
        errorMessage =
            'This quiz code is already in use. Please choose a different code.';
      }

      emit(EditQuizError('Failed to save quiz: ${e.toString()}'));
      emit(currentState.copyWith(isSaving: false));
    }
  }

  /// Mark that changes have been made
  void _onMarkChanges(MarkChangesEvent event, Emitter<EditQuizState> emit) {
    final currentState = state;
    if (currentState is EditQuizReady && !currentState.hasChanges) {
      emit(currentState.copyWith(hasChanges: true));
    }
  }
}
