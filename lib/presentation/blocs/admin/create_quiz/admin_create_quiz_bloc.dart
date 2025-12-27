import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';
import 'package:quizify_proyek_mmp/domain/repositories/admin_repository.dart';
import 'package:quizify_proyek_mmp/domain/repositories/auth_repository.dart';

part 'admin_create_quiz_event.dart';
part 'admin_create_quiz_state.dart';

class AdminCreateQuizBloc
    extends Bloc<AdminCreateQuizEvent, AdminCreateQuizState> {
  final AdminRepository _adminRepository;
  final AuthenticationRepository _authRepository;

  AdminCreateQuizBloc({
    required AdminRepository adminRepository,
    required AuthenticationRepository authRepository,
  }) : _adminRepository = adminRepository,
       _authRepository = authRepository,
       super(AdminCreateQuizInitial()) {
    on<AdminValidateQuizEvent>(_onValidateQuiz);
    on<AdminSubmitQuizEvent>(_onSubmitQuiz);
  }

  Future<void> _onSubmitQuiz(
    AdminSubmitQuizEvent event,
    Emitter<AdminCreateQuizState> emit,
  ) async {
    // First validate
    final validationError = _validateQuiz(event.title, event.questions);

    if (validationError != null) {
      emit(AdminCreateQuizValidationError(validationError));
      return;
    }

    emit(AdminCreateQuizLoading());

    try {
      // Admin can create quiz without restrictions
      // TODO: Implement admin-specific quiz creation through AdminRepository
      // For now, this is a placeholder - you'll need to add saveQuiz method to AdminRepository

      // Simulated success
      final savedQuiz = QuizModel(
        id: event.quizId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: event.title,
        description: event.description,
        category: event.category,
        status: event.status ?? 'public',
        quizCode: event.quizCode ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: _authRepository.currentUser.id,
      );

      emit(AdminCreateQuizSuccess(quiz: savedQuiz));
    } catch (e) {
      // Parse error messages for user-friendly display
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception: ')) {
        errorMessage = errorMessage.replaceAll('Exception: ', '');
      }

      emit(AdminCreateQuizFailure(errorMessage));
    }
  }

  void _onValidateQuiz(
    AdminValidateQuizEvent event,
    Emitter<AdminCreateQuizState> emit,
  ) {
    final validationError = _validateQuiz(event.title, event.questions);

    if (validationError != null) {
      emit(AdminCreateQuizValidationError(validationError));
    } else {
      emit(AdminCreateQuizInitial());
    }
  }

  /// Validate quiz data and return error message if invalid
  String? _validateQuiz(String title, List<QuestionModel> questions) {
    // Validate title
    if (title.trim().isEmpty) {
      return 'Quiz title cannot be empty';
    }

    if (title.trim().length < 3) {
      return 'Quiz title must be at least 3 characters';
    }

    // Validate questions
    if (questions.isEmpty) {
      return 'Quiz must have at least one question';
    }

    // Validate each question
    for (var i = 0; i < questions.length; i++) {
      final question = questions[i];
      final questionNumber = i + 1;

      if (question.questionText.trim().isEmpty) {
        return 'Question $questionNumber: Question text cannot be empty';
      }

      if (question.correctAnswer.trim().isEmpty) {
        return 'Question $questionNumber: Must have a correct answer selected';
      }

      if (question.options.length < 2) {
        return 'Question $questionNumber: Must have at least 2 options';
      }

      // Validate that correct answer exists in options
      if (!question.options.contains(question.correctAnswer)) {
        return 'Question $questionNumber: Correct answer must be one of the options';
      }

      // Validate that all options are non-empty
      for (var j = 0; j < question.options.length; j++) {
        if (question.options[j].trim().isEmpty) {
          return 'Question $questionNumber: Option ${j + 1} cannot be empty';
        }
      }

      // validate that options are unique
      final uniqueOptions = question.options.map((e) => e.trim()).toSet();
      if (uniqueOptions.length != question.options.length) {
        return 'Question $questionNumber: All options must be unique';
      }
    }

    return null; // No validation errors
  }
}
