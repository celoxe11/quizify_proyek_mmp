import 'package:equatable/equatable.dart';

abstract class AdminUsersEvent extends Equatable {
  const AdminUsersEvent();
  @override
  List<Object> get props => [];
}

class FetchAllUsersEvent extends AdminUsersEvent {}

class ToggleUserStatusEvent extends AdminUsersEvent {
  final String userId;
  final bool currentStatus; // true = active, false = blocked

  const ToggleUserStatusEvent({
    required this.userId,
    required this.currentStatus,
  });
}

class FilterUsersEvent extends AdminUsersEvent {
  final String filterType; // 'All', 'Teacher', 'Student', 'Active', 'Blocked'
  const FilterUsersEvent(this.filterType);

  @override
  List<Object> get props => [filterType];
}
