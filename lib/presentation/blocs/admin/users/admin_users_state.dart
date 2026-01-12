import 'package:equatable/equatable.dart';
import 'package:quizify_proyek_mmp/data/models/subscription_model.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/users/admin_users_event.dart';
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
  final List<SubscriptionModel> availableSubscriptions;
  
  const AdminUsersLoaded({
    required this.allUsers,
    required this.filteredUsers,
    this.availableSubscriptions = const [],
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

class LoadSubscriptionsEvent extends AdminUsersEvent {}

class UpdateUserEvent extends AdminUsersEvent {
  final String userId;
  final String role;
  final int subscriptionId;
  
  const UpdateUserEvent({required this.userId, required this.role, required this.subscriptionId});
}