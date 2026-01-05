import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:quizify_proyek_mmp/data/models/student_history_model.dart';
import 'package:quizify_proyek_mmp/data/repositories/student_repository.dart'; // Pastikan path ini benar

part 'student_history_event.dart';
part 'student_history_state.dart';

class StudentHistoryBloc extends Bloc<StudentHistoryEvent, StudentHistoryState> {
  final StudentRepository repository; // <--- Tipe data harus StudentRepository

  StudentHistoryBloc(this.repository) : super(StudentHistoryInitial()) {
    on<LoadStudentHistory>((event, emit) async {
      emit(StudentHistoryLoading());
      try {
        // Panggil fungsi fetchHistory yang sudah diperbaiki di Repository
        final data = await repository.fetchHistory();
        
        // Emit state loaded dengan data
        emit(StudentHistoryLoaded(data));
      } catch (e) {
        // Emit error jika gagal
        emit(StudentHistoryError(e.toString()));
      }
    });
  }
}