import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repositories/admin_repository.dart';
import 'admin_users_event.dart';
import 'admin_users_state.dart';

class AdminUsersBloc extends Bloc<AdminUsersEvent, AdminUsersState> {
  final AdminRepository adminRepository;

  AdminUsersBloc({required this.adminRepository}) : super(AdminUsersInitial()) {
    
    // Handler: Fetch Users
    on<FetchAllUsersEvent>((event, emit) async {
      emit(AdminUsersLoading());
      try {
        final users = await adminRepository.fetchAllUsers();
        // Kita perlu casting/mapping dari Entity ke Model jika repo return Entity
        // Anggap repo mengembalikan List<UserModel> atau bisa dikonversi
        emit(AdminUsersLoaded(users)); 
      } catch (e) {
        emit(AdminUsersError(e.toString()));
      }
    });

    // Handler: Block/Unblock User
    on<ToggleUserStatusEvent>((event, emit) async {
      // Optimistic update atau Refresh setelah aksi
      try {
        // Panggil fungsi di repository (pastikan repo punya fungsi ini)
        // await adminRepository.toggleUserBlockStatus(event.userId, !event.currentStatus);
        
        // Refresh data setelah update
        add(FetchAllUsersEvent()); 
      } catch (e) {
        emit(AdminUsersError("Gagal mengupdate status user"));
      }
    });
  }
}