import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/question.dart';
import '../../../../../domain/repositories/admin_repository.dart';

part 'admin_quiz_detail_event.dart';
part 'admin_quiz_detail_state.dart';

class AdminQuizDetailBloc extends Bloc<AdminQuizDetailEvent, AdminQuizDetailState> {
  final AdminRepository adminRepository;

  AdminQuizDetailBloc({required this.adminRepository}) : super(AdminQuizDetailInitial()) {
    on<LoadAdminQuizDetail>((event, emit) async {
      emit(AdminQuizDetailLoading());
      try {
        final questions = await adminRepository.fetchQuizDetail(event.quizId);
        emit(AdminQuizDetailLoaded(questions));
      } catch (e) {
        emit(AdminQuizDetailError(e.toString()));
      }
    });

    on<DeleteQuestionEvent>((event, emit) async {
      try {
        // 1. Panggil Repo Delete
        await adminRepository.deleteQuestion(event.questionId);
        
        // 2. Jika sukses, panggil ulang data Quiz (Refresh otomatis)
        add(LoadAdminQuizDetail(event.quizId));
        
      } catch (e) {
        // Opsional: Bisa emit state error khusus atau tampilkan snackbar di UI
        // Untuk simpelnya, kita print dulu atau biarkan state tetap loaded
        print("Gagal menghapus: $e");
      }
    });

  }
}