class TransactionModel {
  final String id;
  final String? userId; 
  final String item;
  final double amount;
  final String status;
  final String method;
  final DateTime date;


  TransactionModel({
    required this.id,
    this.userId,
    required this.item,
    required this.amount,
    required this.status,
    required this.method,
    required this.date,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final amountString = json['amount']?.toString() ?? '0.0';
    final amountValue = double.tryParse(amountString) ?? 0.0;

    return TransactionModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? null,
      item: json['item'] ?? 'Unknown',
      amount: amountValue, 
      status: json['status'] ?? 'pending',
      method: json['method'] ?? '-',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    );
  }
}