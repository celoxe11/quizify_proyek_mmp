import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/domain/entities/transaction.dart'; // Pakai Entity

class AdminTransactionDesktopPage extends StatelessWidget {
  final List<TransactionEntity> transactions; // Gunakan Entity
  const AdminTransactionDesktopPage({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(AppColors.darkAzure.withOpacity(0.05)),
            headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkAzure),
            dataRowMinHeight: 60,
            dataRowMaxHeight: 60,
            columns: const [
              DataColumn(label: Text('DATE')),
              DataColumn(label: Text('TRX ID')),
              DataColumn(label: Text('USER ID')),
              DataColumn(label: Text('ITEM / PACKAGE')), // Judul Kolom
              DataColumn(label: Text('TYPE')),           // Kolom Baru: Tipe
              DataColumn(label: Text('AMOUNT')),
              DataColumn(label: Text('STATUS')),
            ],
            rows: transactions.map((trx) {
              return DataRow(
                cells: [
                  DataCell(Text(trx.date.toString().substring(0, 16))),
                  DataCell(Text(trx.id, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold))),
                  DataCell(Text(trx.userId ?? '-', style: const TextStyle(color: Colors.grey))),
                  
                  // KOLOM ITEM NAME
                  DataCell(Text(trx.itemName, style: const TextStyle(fontWeight: FontWeight.w600))),
                  
                  // KOLOM CATEGORY (Icon + Text)
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trx.category == 'subscription' ? Icons.card_membership : Icons.checkroom, // Ikon beda
                          size: 16, 
                          color: Colors.grey
                        ),
                        const SizedBox(width: 8),
                        Text(trx.category.toUpperCase(), style: const TextStyle(fontSize: 11)),
                      ],
                    )
                  ),
                  
                  DataCell(Text(_formatCurrency(trx.amount), style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(StatusBadge(status: trx.status)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ... (Helper _StatusBadge dan _formatCurrency tetap sama) ...
// --- HELPER DILETAKKAN DISINI AGAR BISA DIAKSES ---

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'success':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'pending':
        color = Colors.orange;
        icon = Icons.access_time;
        break;
      case 'failed':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

String _formatCurrency(double amount) {
  return "Rp ${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
}