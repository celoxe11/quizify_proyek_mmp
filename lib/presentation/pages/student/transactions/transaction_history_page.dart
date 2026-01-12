import 'package:flutter/material.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Bloc/Repo disini nanti
    // ...

    return Scaffold(
      appBar: AppBar(title: const Text("Payment History")),
      body: ListView.builder(
        itemCount: 2, // Dummy count, ganti dengan state.transactions.length
        itemBuilder: (context, index) {
          // Dummy Data
          final status = index == 0 ? "success" : "pending";
          final color = status == "success" ? Colors.green : Colors.orange;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(Icons.receipt_long, color: color),
              ),
              title: const Text("Premium Plan", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("12 Jan 2026 • Bank Transfer"),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Rp 50.000", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    status.toUpperCase(),
                    style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}