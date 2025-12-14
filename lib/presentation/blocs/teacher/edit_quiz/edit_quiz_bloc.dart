import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';

part 'edit_quiz_event.dart';
part 'edit_quiz_state.dart';

/// BLoC for managing Edit Quiz page state
///
/// Handles all state changes for editing a quiz including:
/// - Initializing form fields with existing quiz data
/// - Tracking changes to title, description, category, status
/// - Managing questions (add, update, remove)
/// - Saving the quiz to the database
///
/// Usage:
/// ```dart
/// BlocProvider(
///   create: (context) => EditQuizBloc()
///     ..add(InitializeEditQuizEvent(quiz: quiz, questions: questions)),
///   child: TeacherEditQuizPage(quiz: quiz, questions: questions),
/// )
/// ```
class EditQuizBloc extends Bloc<EditQuizEvent, EditQuizState> {
  // TODO: Inject repositories when implementing backend integration
  // final QuizRepository quizRepository;
  // final QuestionRepository questionRepository;

  EditQuizBloc() : super(EditQuizInitial()) {
    on<InitializeEditQuizEvent>(_onInitialize);
    on<TitleChangedEvent>(_onTitleChanged);
    on<DescriptionChangedEvent>(_onDescriptionChanged);
    on<CategoryChangedEvent>(_onCategoryChanged);
    on<TogglePublicEvent>(_onTogglePublic);
    on<AddQuestionEvent>(_onAddQuestion);
    on<UpdateQuestionEvent>(_onUpdateQuestion);
    on<RemoveQuestionEvent>(_onRemoveQuestion);
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
        quiz.code ??
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

  /// Handle title change
  void _onTitleChanged(TitleChangedEvent event, Emitter<EditQuizState> emit) {
    final currentState = state;
    if (currentState is EditQuizReady) {
      emit(currentState.copyWith(title: event.title, hasChanges: true));
    }
  }

  /// Handle description change
  void _onDescriptionChanged(
    DescriptionChangedEvent event,
    Emitter<EditQuizState> emit,
  ) {
    final currentState = state;
    if (currentState is EditQuizReady) {
      emit(
        currentState.copyWith(description: event.description, hasChanges: true),
      );
    }
  }

  /// Handle category change
  void _onCategoryChanged(
    CategoryChangedEvent event,
    Emitter<EditQuizState> emit,
  ) {
    final currentState = state;
    if (currentState is EditQuizReady) {
      emit(currentState.copyWith(category: event.category, hasChanges: true));
    }
  }

  /// Handle public status toggle
  void _onTogglePublic(TogglePublicEvent event, Emitter<EditQuizState> emit) {
    final currentState = state;
    if (currentState is EditQuizReady) {
      emit(currentState.copyWith(isPublic: event.isPublic, hasChanges: true));
    }
  }

  /// Add a new empty question
  void _onAddQuestion(AddQuestionEvent event, Emitter<EditQuizState> emit) {
    final currentState = state;
    if (currentState is EditQuizReady) {
      final newQuestion = QuestionModel(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        quizId: currentState.originalQuiz.id,
        type: 'multiple',
        difficulty: 'easy',
        questionText: '',
        correctAnswer: '',
        options: ['', '', '', ''],
      );

      emit(
        currentState.copyWith(
          questions: [...currentState.questions, newQuestion],
          hasChanges: true,
        ),
      );
    }
  }

  /// Update a question at an index
  void _onUpdateQuestion(
    UpdateQuestionEvent event,
    Emitter<EditQuizState> emit,
  ) {
    final currentState = state;
    if (currentState is EditQuizReady) {
      if (event.index >= 0 && event.index < currentState.questions.length) {
        final updatedQuestions = List<QuestionModel>.from(
          currentState.questions,
        );
        updatedQuestions[event.index] = event.question;

        emit(
          currentState.copyWith(questions: updatedQuestions, hasChanges: true),
        );
      }
    }
  }

  /// Remove a question at an index
  void _onRemoveQuestion(
    RemoveQuestionEvent event,
    Emitter<EditQuizState> emit,
  ) {
    final currentState = state;
    if (currentState is EditQuizReady) {
      if (event.index >= 0 && event.index < currentState.questions.length) {
        final updatedQuestions = List<QuestionModel>.from(
          currentState.questions,
        );

        // TODO: If question has a real ID (not temp_), delete from database
        // final questionToRemove = updatedQuestions[event.index];
        // if (!questionToRemove.id.startsWith('temp_')) {
        //   await questionRepository.delete(questionToRemove.id);
        // }

        updatedQuestions.removeAt(event.index);

        emit(
          currentState.copyWith(questions: updatedQuestions, hasChanges: true),
        );
      }
    }
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
      // TODO: Create updated quiz model
      final updatedQuiz = currentState.originalQuiz.copyWith(
        title: currentState.title.trim(),
        description: currentState.description.trim().isEmpty
            ? null
            : currentState.description.trim(),
        category: currentState.category.trim().isEmpty
            ? null
            : currentState.category.trim(),
        status: currentState.isPublic ? 'public' : 'private',
        updatedAt: DateTime.now(),
      );

      // TODO: Update quiz in database
      // await quizRepository.update(updatedQuiz);

      // TODO: Update/create/delete questions
      // for (final question in currentState.questions) {
      //   if (question.id.startsWith('temp_')) {
      //     // New question - create with new ID
      //     await questionRepository.create(
      //       question.copyWith(quizId: updatedQuiz.id),
      //     );
      //   } else {
      //     // Existing question - update
      //     await questionRepository.update(question);
      //   }
      // }

      // Simulate save delay for development
      await Future.delayed(const Duration(seconds: 1));

      emit(EditQuizSaved(updatedQuiz));
    } catch (e) {
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
