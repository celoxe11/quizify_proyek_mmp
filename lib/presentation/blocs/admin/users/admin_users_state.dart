import 'package:equatable/equatable.dart';
import '../../../../domain/entities/user.dart'; 

abstract class AdminUsersState extends Equatable {
  const AdminUsersState();
  @override
  List<Object> get props => [];
}

class AdminUsersInitial extends AdminUsersState {}

class AdminUsersLoading extends AdminUsersState {}

class AdminUsersLoaded extends AdminUsersState {
  final List<User> allUsers;      // List asli (Backup)
  final List<User> filteredUsers; // List yang ditampilkan di UI

  const AdminUsersLoaded({
    required this.allUsers,
    required this.filteredUsers,
  });

  @override
  List<Object> get props => [allUsers, filteredUsers];
}

class AdminUsersError extends AdminUsersState {
  final String message;
  const AdminUsersError(this.message);
  @override
  List<Object> get props => [message];
}