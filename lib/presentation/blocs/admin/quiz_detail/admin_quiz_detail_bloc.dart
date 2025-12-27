import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:quizify_proyek_mmp/data/models/question_model.dart';
import 'package:quizify_proyek_mmp/data/models/quiz_model.dart';
import 'package:quizify_proyek_mmp/domain/repositories/admin_repository.dart';

part 'admin_quiz_detail_event.dart';
part 'admin_quiz_detail_state.dart';

class AdminQuizDetailBloc
    extends Bloc<AdminQuizDetailEvent, AdminQuizDetailState> {
  final AdminRepository adminRepository;

  AdminQuizDetailBloc({required this.adminRepository})
    : super(AdminQuizDetailInitial()) {
    on<LoadAdminQuizDetail>(_onLoadQuizDetail);
    on<DeleteQuestionEvent>(_onDeleteQuestion);
    on<RefreshAdminQuizDetailEvent>(_onRefresh);
    on<DeleteAdminQuizEvent>(_onDeleteQuiz);
  }

  /// Load quiz details and questions
  Future<void> _onLoadQuizDetail(
    LoadAdminQuizDetail event,
    Emitter<AdminQuizDetailState> emit,
  ) async {
    emit(AdminQuizDetailLoading());

    try {
      final response = await adminRepository.fetchQuizDetail(event.quizId);

      final quiz = response.quiz;
      final questions = response.questions;

      emit(AdminQuizDetailLoaded(quiz: quiz, questions: questions));
    } catch (e) {
      emit(
        AdminQuizDetailError(message: 'Failed to load quiz: ${e.toString()}'),
      );
    }
  }

  /// Delete a question from the quiz
  Future<void> _onDeleteQuestion(
    DeleteQuestionEvent event,
    Emitter<AdminQuizDetailState> emit,
  ) async {
    try {
      // Delete question through repository
      await adminRepository.deleteQuestion(event.questionId);

      // Refresh quiz detail after successful deletion
      add(LoadAdminQuizDetail(event.quizId));
    } catch (e) {
      emit(
        AdminQuizDetailError(
          message: 'Failed to delete question: ${e.toString()}',
        ),
      );
    }
  }

  /// Refresh all data
  Future<void> _onRefresh(
    RefreshAdminQuizDetailEvent event,
    Emitter<AdminQuizDetailState> emit,
  ) async {
    add(LoadAdminQuizDetail(event.quizId));
  }

  // delete quiz
  Future<void> _onDeleteQuiz(
    DeleteAdminQuizEvent event,
    Emitter<AdminQuizDetailState> emit,
  ) async {
    try {
      // Delete quiz through repository
      await adminRepository.deleteQuiz(event.quizId);

      // Emit a state indicating successful deletion
      emit(AdminQuizDetailDeleted());
    } catch (e) {
      emit(
        AdminQuizDetailError(message: 'Failed to delete quiz: ${e.toString()}'),
      );
    }
  }
}
