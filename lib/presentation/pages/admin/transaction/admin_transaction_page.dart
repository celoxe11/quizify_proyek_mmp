import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/repositories/admin_repository.dart';

import 'package:quizify_proyek_mmp/presentation/blocs/admin/transaction/admin_transaction_bloc.dart';

import 'admin_transaction_desktop.dart';
import 'admin_transaction_mobile.dart';

class AdminTransactionPage extends StatelessWidget {
  final bool isEmbedded; 

  const AdminTransactionPage({super.key, this.isEmbedded = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminTransactionBloc(
        context.read<AdminRepositoryImpl>(), 
      )..add(LoadAdminTransactions()),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        // Logic AppBar: Jika embedded di Tab Settings, hilangkan AppBar
        appBar: isEmbedded 
            ? null 
            : AppBar(
                title: const Text('Transactions', style: TextStyle(fontWeight: FontWeight.bold)),
                backgroundColor: Colors.white,
                foregroundColor: AppColors.darkAzure,
                elevation: 0.5,
                actions: [
                  Builder(
                    builder: (ctx) => IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => ctx.read<AdminTransactionBloc>().add(LoadAdminTransactions()),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
        body: BlocBuilder<AdminTransactionBloc, AdminTransactionState>(
          builder: (context, state) {
            if (state is TransactionLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.darkAzure));
            }
            if (state is TransactionError) {
              return Center(child: Text("Error: ${state.message}"));
            }
            if (state is TransactionLoaded) {
              if (state.transactions.isEmpty) {
                return const Center(child: Text("No transactions found."));
              }
              return LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 900) {
                    return AdminTransactionDesktopPage(transactions: state.transactions);
                  } else {
                    return AdminTransactionMobilePage(transactions: state.transactions);
                  }
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}