class SubscriptionModel {
  final int id;
  final double price;
  final String status;
  final DateTime? createdAt;

  SubscriptionModel({
    required this.id,
    required this.price,
    required this.status,
    this.createdAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id_subs'] ?? json['id'] ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_subs': id,
      'price': price,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}