class SubscriptionModel {
  final int id;
  final String status;
  final double price; 

  SubscriptionModel({required this.id, required this.status, this.price = 0.0,});

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id_subs'] ?? 0,
      status: json['status'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
    );
  }
}