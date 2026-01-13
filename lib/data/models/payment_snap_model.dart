class PaymentSnapModel {
  final String snapToken;
  final String orderId;
  final String type; // 'subscription' or 'avatar'
  final String? avatarId;
  final String? subscriptionPlan;
  final double amount;
  final String currency;
  final DateTime createdAt;

  PaymentSnapModel({
    required this.snapToken,
    required this.orderId,
    required this.type,
    this.avatarId,
    this.subscriptionPlan,
    required this.amount,
    required this.currency,
    required this.createdAt,
  });

  factory PaymentSnapModel.fromJson(Map<String, dynamic> json) {
    return PaymentSnapModel(
      snapToken: json['snap_token'] as String? ?? json['token'] as String,
      orderId: json['order_id'] as String,
      type: json['type'] as String? ?? 'subscription',
      avatarId: json['avatar_id'] as String?,
      subscriptionPlan: json['subscription_plan'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'IDR',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'snap_token': snapToken,
      'order_id': orderId,
      'type': type,
      'avatar_id': avatarId,
      'subscription_plan': subscriptionPlan,
      'amount': amount,
      'currency': currency,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
