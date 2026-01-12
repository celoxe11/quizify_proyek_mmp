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

// Event Tambah
class CreateSubscriptionEvent extends AdminUsersEvent {
  final String name;
  final double price; // Tambah ini
  const CreateSubscriptionEvent(this.name, this.price);
  @override
  List<Object> get props => [name, price];
}

// Event Edit (Update) - Tambahkan jika belum ada
class UpdateSubscriptionEvent extends AdminUsersEvent {
  final int id;
  final String name;
  final double price;
  
  const UpdateSubscriptionEvent({
    required this.id, 
    required this.name, 
    required this.price
  });

  @override
  List<Object> get props => [id, name, price];
}

