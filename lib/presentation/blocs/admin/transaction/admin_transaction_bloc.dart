import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:quizify_proyek_mmp/data/models/transaction_model.dart';
import 'package:quizify_proyek_mmp/data/repositories/admin_repository.dart';
import 'package:quizify_proyek_mmp/domain/repositories/admin_repository.dart';

// --- EVENT ---
abstract class AdminTransactionEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class LoadAdminTransactions extends AdminTransactionEvent {}

// --- STATE ---
abstract class AdminTransactionState extends Equatable {
  @override
  List<Object> get props => [];
}
class TransactionInitial extends AdminTransactionState {}
class TransactionLoading extends AdminTransactionState {}
class TransactionLoaded extends AdminTransactionState {
  final List<TransactionModel> transactions;
  TransactionLoaded(this.transactions);
}
class TransactionError extends AdminTransactionState {
  final String message;
  TransactionError(this.message);
}

// --- BLOC ---
class AdminTransactionBloc extends Bloc<AdminTransactionEvent, AdminTransactionState> {
  final AdminRepository repository;

  AdminTransactionBloc(this.repository) : super(TransactionInitial()) {
    on<LoadAdminTransactions>((event, emit) async {
      emit(TransactionLoading());
      try {
        // Pastikan Anda sudah membuat fungsi fetchAllTransactions di repo admin
        final data = await repository.fetchAllTransactions(); 
        emit(TransactionLoaded(data));
      } catch (e) {
        emit(TransactionError(e.toString()));
      }
    });
  }
}