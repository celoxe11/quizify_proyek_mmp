import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String? userId;
  final String itemName; 
  final String category;
  final double amount;
  final String status;
  final String method;
  final DateTime date;

  const TransactionEntity({
    required this.id,
    this.userId,
    required this.itemName,
    required this.category,
    required this.amount,
    required this.status,
    required this.method,
    required this.date,
  });

  @override
  List<Object?> get props => [id, userId, itemName, category, amount, status, method, date];
}