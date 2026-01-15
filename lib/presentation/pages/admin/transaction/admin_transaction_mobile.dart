import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/transaction_model.dart'; // Pastikan Model sudah diupdate ke itemName

class AdminTransactionMobilePage extends StatelessWidget {
  final List<TransactionModel> transactions;
  final String groupBy; // 'None' | 'User' | 'Item'
  const AdminTransactionMobilePage({super.key, required this.transactions, this.groupBy = 'None'});

  @override
  Widget build(BuildContext context) {
    if (groupBy != 'None') {
      final Map<String, List<TransactionModel>> groups = {};
      for (var trx in transactions) {
        final key = groupBy == 'User' ? (trx.userId ?? 'Unknown') : trx.itemName;
        groups.putIfAbsent(key, () => []).add(trx);
      }

      final entries = groups.entries.toList()
        ..sort((a, b) => b.value.fold<double>(0, (p, e) => p + e.amount).compareTo(a.value.fold<double>(0, (p, e) => p + e.amount)));

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        itemBuilder: (context, idx) {
          final key = entries[idx].key;
          final list = entries[idx].value;
          final total = list.fold<double>(0, (p, e) => p + e.amount);
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
            child: ListTile(
              title: Text(key, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${list.length} transactions • Total: ${_formatCurrency(total)}'),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final trx = transactions[index];
        
        // Logika Ikon berdasarkan Kategori
        IconData categoryIcon = trx.category == 'subscription' 
            ? Icons.card_membership 
            : Icons.shopping_bag; // Ikon tas belanja untuk item

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris Atas: ID & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(trx.id, style: const TextStyle(fontFamily: 'monospace', color: Colors.grey, fontSize: 12)),
                    StatusBadge(status: trx.status),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Baris Bawah: Icon, Info, Harga
                Row(
                  children: [
                    // Icon Kategori (Dynamic)
                    CircleAvatar(
                      backgroundColor: AppColors.darkAzure.withOpacity(0.1),
                      child: Icon(categoryIcon, color: AppColors.darkAzure, size: 20),
                    ),
                    const SizedBox(width: 12),
                    
                    // Nama Item & User
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trx.itemName, // [FIX] Gunakan itemName (dari Entity/Model)
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "User: ${trx.userId ?? 'Unknown'}", 
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                    // Harga & Tanggal
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(_formatCurrency(trx.amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(trx.date.toString().substring(0, 10), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- HELPER (Tetap sama) ---

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