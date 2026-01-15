import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/repositories/admin_repository.dart';

import 'package:quizify_proyek_mmp/presentation/blocs/admin/transaction/admin_transaction_bloc.dart';

import 'admin_transaction_desktop.dart';
import 'admin_transaction_mobile.dart';

class AdminTransactionPage extends StatefulWidget {
  final bool isEmbedded;

  const AdminTransactionPage({super.key, this.isEmbedded = false});

  @override
  State<AdminTransactionPage> createState() => _AdminTransactionPageState();
}

class _AdminTransactionPageState extends State<AdminTransactionPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _groupBy = 'None'; // None | User | Item

  Future<void> _pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  void _applyFilters(BuildContext context) {
    context.read<AdminTransactionBloc>().add(
      FilterAdminTransactions(startDate: _startDate, endDate: _endDate?.add(const Duration(hours: 23, minutes: 59, seconds: 59))),
    );
  }

  void _resetFilters(BuildContext context) {
    setState(() {
      _startDate = null;
      _endDate = null;
      _groupBy = 'None';
    });
    context.read<AdminTransactionBloc>().add(LoadAdminTransactions());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminTransactionBloc(
        context.read<AdminRepositoryImpl>(),
      )..add(LoadAdminTransactions()),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: widget.isEmbedded
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
        body: Column(
          children: [
            // Filter Bar (use Builder so buttons get a context that's a descendant of BlocProvider)
            Builder(
              builder: (ctx) => Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _pickStartDate(ctx),
                      child: Text(_startDate == null ? 'Start Date' : _startDate!.toLocal().toString().split(' ')[0]),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _pickEndDate(ctx),
                      child: Text(_endDate == null ? 'End Date' : _endDate!.toLocal().toString().split(' ')[0]),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _groupBy,
                      items: const [
                        DropdownMenuItem(value: 'None', child: Text('Group: None')),
                        DropdownMenuItem(value: 'User', child: Text('Group: User')),
                        DropdownMenuItem(value: 'Item', child: Text('Group: Item')),
                      ],
                      onChanged: (v) => setState(() => _groupBy = v ?? 'None'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => _applyFilters(ctx),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkAzure),
                      child: const Text('Apply'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => _resetFilters(ctx),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ),
            ),
            // Results
            Expanded(
              child: BlocBuilder<AdminTransactionBloc, AdminTransactionState>(
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
                          return AdminTransactionDesktopPage(transactions: state.transactions, groupBy: _groupBy);
                        } else {
                          return AdminTransactionMobilePage(transactions: state.transactions, groupBy: _groupBy);
                        }
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}