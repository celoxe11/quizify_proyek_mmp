import '../../domain/entities/transaction.dart'; // Import Entity

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    super.userId,
    required super.itemName, // Pass ke parent
    required super.category,
    required super.amount,
    required super.status,
    required super.method,
    required super.date,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      
      // [FIX] Mapping dari JSON 'item_name' ke variable 'itemName'
      itemName: json['item_name']?.toString() ?? 'Unknown Item', 
      
      category: json['category']?.toString() ?? 'subscription',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      status: json['status']?.toString() ?? 'pending',
      method: json['payment_method'] ?? '-',
      date: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}