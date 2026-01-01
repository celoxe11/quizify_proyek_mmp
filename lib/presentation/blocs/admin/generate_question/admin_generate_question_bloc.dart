import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/domain/repositories/admin_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/generate_question/admin_generate_question_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/generate_question/admin_generate_question_state.dart';

class AdminGenerateQuestionBloc
    extends Bloc<AdminGenerateQuestionEvent, AdminGenerateQuestionState> {
  final AdminRepository _adminRepository;

  AdminGenerateQuestionBloc({required AdminRepository adminRepository})
    : _adminRepository = adminRepository,
      super(AdminGenerateQuestionInitial()) {
    on<AdminGenerateQuestionWithAIEvent>(_onGenerateQuestionWithAI);
  }

  Future<void> _onGenerateQuestionWithAI(
    AdminGenerateQuestionWithAIEvent event,
    Emitter<AdminGenerateQuestionState> emit,
  ) async {
    emit(AdminGenerateQuestionLoading());

    try {
      // TODO: Implement admin-specific question generation through AdminRepository
      // For now, this is a placeholder that shows admin can generate questions without limits

      // Simulated delay
      await Future.delayed(const Duration(seconds: 1));

      // This should call the admin repository to generate questions
      // Admin users might have unlimited AI generation or special privileges

      emit(
        AdminGenerateQuestionFailure(
          error:
              'Admin question generation not yet implemented in AdminRepository',
        ),
      );
    } catch (e) {
      emit(
        AdminGenerateQuestionFailure(
          error: 'Failed to generate questions with AI: ${e.toString()}',
        ),
      );
    }
  }
}
