import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';
import 'package:quizify_proyek_mmp/domain/repositories/teacher_repository.dart';

part 'create_quiz_event.dart';
part 'create_quiz_state.dart';

class CreateQuizBloc extends Bloc<CreateQuizEvent, CreateQuizState> {
  final TeacherRepository _teacherRepository;

  CreateQuizBloc({required TeacherRepository teacherRepository})
      : _teacherRepository = teacherRepository,
        super(CreateQuizInitial()) {
    on<ValidateQuizEvent>(_onValidateQuiz);
    on<SubmitQuizEvent>(_onSubmitQuiz);
  }

  Future<void> _onSubmitQuiz(
    SubmitQuizEvent event,
    Emitter<CreateQuizState> emit,
  ) async {
    // First validate
    final validationError = _validateQuiz(
      event.title,
      event.questions,
    );

    if (validationError != null) {
      emit(CreateQuizValidationError(validationError));
      return;
    }

    emit(CreateQuizLoading());
    
    try {
      final savedQuiz = await _teacherRepository.saveQuiz(
        quizId: event.quizId,
        title: event.title,
        description: event.description,
        category: event.category,
        status: event.status,
        quizCode: event.quizCode,
        questions: event.questions,
      );

      emit(CreateQuizSuccess(quiz: savedQuiz));
    } catch (e) {
      // Parse error messages for user-friendly display
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception: ')) {
        errorMessage = errorMessage.replaceAll('Exception: ', '');
      }
      
      // Handle specific error cases
      if (errorMessage.contains('Anda sudah membuat kuis hari ini')) {
        errorMessage = 'You have reached your daily quiz creation limit. Upgrade to premium for unlimited quizzes.';
      } else if (errorMessage.contains('Kode kuis sudah digunakan')) {
        errorMessage = 'This quiz code is already in use. Please choose a different code.';
      }

      emit(CreateQuizFailure(errorMessage));
    }
  }

  void _onValidateQuiz(
    ValidateQuizEvent event,
    Emitter<CreateQuizState> emit,
  ) {
    final validationError = _validateQuiz(event.title, event.questions);

    if (validationError != null) {
      emit(CreateQuizValidationError(validationError));
    } else {
      emit(CreateQuizInitial());
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

    // Count total images for free tier validation (max 3 per quiz)
    int totalImagesCount = questions.where((q) => q.image != null && q.image!.isNotEmpty).length;

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

    // Note: Backend will enforce 3 images per quiz limit for free users
    // This is just a helpful client-side info
    if (totalImagesCount > 0) {
      print('Quiz has $totalImagesCount question(s) with images');
    }

    return null; // No validation errors
  }
}
