import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';
import 'package:quizify_proyek_mmp/domain/repositories/admin_repository.dart';

part 'admin_edit_quiz_event.dart';
part 'admin_edit_quiz_state.dart';

class AdminEditQuizBloc extends Bloc<AdminEditQuizEvent, AdminEditQuizState> {
  final AdminRepository _adminRepository;

  AdminEditQuizBloc({required AdminRepository adminRepository})
    : _adminRepository = adminRepository,
      super(AdminEditQuizInitial()) {
    on<AdminInitializeEditQuizEvent>(_onInitialize);
    on<AdminSaveQuizEvent>(_onSaveQuiz);
    on<AdminMarkChangesEvent>(_onMarkChanges);
  }

  /// Initialize the edit form with quiz data
  void _onInitialize(
    AdminInitializeEditQuizEvent event,
    Emitter<AdminEditQuizState> emit,
  ) {
    final quiz = event.quiz;

    // Generate quiz code from ID if not available
    final quizCode =
        quiz.quizCode ??
        (quiz.id.length >= 8
            ? quiz.id.substring(0, 8).toUpperCase()
            : quiz.id.toUpperCase());

    emit(
      AdminEditQuizReady(
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
    AdminSaveQuizEvent event,
    Emitter<AdminEditQuizState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AdminEditQuizReady) return;

    // Validate
    if (currentState.title.trim().isEmpty) {
      emit(const AdminEditQuizError('Please enter a quiz title'));
      emit(currentState); // Return to ready state
      return;
    }

    emit(currentState.copyWith(isSaving: true));

    try {
      // Save quiz using AdminRepository
      final response = await _adminRepository.saveQuizWithQuestions(
        quizId: event.quizId,
        title: event.title,
        description: event.description,
        category: event.category,
        status: event.status ?? 'public',
        quizCode: event.quizCode,
        questions: event.questions,
      );

      final updatedQuiz = QuizModel(
        id: response['quiz_id'] ?? event.quizId ?? '',
        title: event.title,
        description: event.description,
        category: event.category,
        status: event.status ?? 'public',
        quizCode: event.quizCode ?? '',
        createdAt: currentState.originalQuiz.createdAt,
        updatedAt: DateTime.now(),
        createdBy: currentState.originalQuiz.createdBy,
      );

      emit(AdminEditQuizSaved(updatedQuiz));
    } catch (e) {
      // Parse error messages for user-friendly display
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception: ')) {
        errorMessage = errorMessage.replaceAll('Exception: ', '');
      }

      emit(AdminEditQuizError('Failed to save quiz: ${e.toString()}'));
      emit(currentState.copyWith(isSaving: false));
    }
  }

  /// Mark that changes have been made
  void _onMarkChanges(
    AdminMarkChangesEvent event,
    Emitter<AdminEditQuizState> emit,
  ) {
    final currentState = state;
    if (currentState is AdminEditQuizReady && !currentState.hasChanges) {
      emit(currentState.copyWith(hasChanges: true));
    }
  }
}
