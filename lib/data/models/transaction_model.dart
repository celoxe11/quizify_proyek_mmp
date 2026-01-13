class TransactionModel {
  final String id;
  final String? userId;
  final String item; // Nama barang (Entah itu Paket atau Item)
  final String category; // [BARU] 'subscription' atau 'item'
  final double amount;
  final String status;
  final String method;
  final DateTime date;

  TransactionModel({
    required this.id,
    this.userId,
    required this.item,
    required this.category,
    required this.amount,
    required this.status,
    required this.method,
    required this.date,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      
      // [LOGIC BARU] Menentukan nama barang berdasarkan kategori
      item: json['item_name'] ?? 'Unknown Item', 
      
      // [BARU] Kategori
      category: json['category']?.toString() ?? 'subscription',
      
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? 'pending',
      method: json['payment_method'] ?? '-',
      date: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}