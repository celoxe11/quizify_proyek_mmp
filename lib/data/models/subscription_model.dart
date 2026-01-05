class SubscriptionModel {
  final int id;
  final String status;

  SubscriptionModel({required this.id, required this.status});

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id_subs'] ?? 0,
      status: json['status'] ?? '',
    );
  }
}