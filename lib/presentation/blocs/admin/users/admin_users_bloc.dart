import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/domain/entities/user.dart';
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
        // Awalnya filteredUsers sama dengan allUsers
        emit(AdminUsersLoaded(allUsers: users, filteredUsers: users));
      } catch (e) {
        emit(AdminUsersError(e.toString()));
      }
    });

    on<FilterUsersEvent>((event, emit) {
      if (state is AdminUsersLoaded) {
        final currentState = state as AdminUsersLoaded;
        List<User> result = [];

        switch (event.filterType) {
          case 'Teacher':
            result = currentState.allUsers.where((u) => u.role == 'teacher').toList();
            break;
          case 'Student':
            result = currentState.allUsers.where((u) => u.role == 'student').toList();
            break;
          case 'Active':
            result = currentState.allUsers.where((u) => u.isActive).toList();
            break;
          case 'Blocked':
            result = currentState.allUsers.where((u) => !u.isActive).toList();
            break;
          default: // 'All'
            result = currentState.allUsers;
        }

        // Emit state baru dengan list yang sudah disaring, TAPI list asli tetap dijaga
        emit(AdminUsersLoaded(
          allUsers: currentState.allUsers, 
          filteredUsers: result
        ));
      }
    });

    // Handler: Block/Unblock User
    on<ToggleUserStatusEvent>((event, emit) async {
      // Optimistic update atau Refresh setelah aksi
      try {
        // Panggil Repo
        await adminRepository.toggleUserBlockStatus(event.userId, event.currentStatus);
        
        // Refresh List User agar tampilan terupdate otomatis
        add(FetchAllUsersEvent()); 
      } catch (e) {
        emit(AdminUsersError("Gagal update status: ${e.toString()}"));
        // Kembalikan ke load ulang agar state kembali konsisten
        add(FetchAllUsersEvent());
      }
    });
  }
}