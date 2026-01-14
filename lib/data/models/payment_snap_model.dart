class PaymentSnapModel {
  final String snapToken;
  final String orderId;
  final String type; // 'subscription' or 'avatar'
  final String? avatarId;
  final String? subscriptionPlan;
  final double amount;
  final String currency;

  PaymentSnapModel({
    required this.snapToken,
    required this.orderId,
    required this.type,
    this.avatarId,
    this.subscriptionPlan,
    required this.amount,
    required this.currency,
  });

  factory PaymentSnapModel.fromJson(Map<String, dynamic> json) {
        final snapTokenValue = (json['snap_token'] ?? json['token']) as String?;
        final orderIdValue = (json['order_id'] ?? json['transaction_id']) as String?;
        dynamic amountValue = json['amount'];
        if (amountValue == null && json['item'] is Map && json['item']['price'] != null) {
          amountValue = json['item']['price'];
        }

        final currencyValue = json['currency'] as String? ?? 'IDR';
        final subscriptionPlanValue = json['subscription_plan'] as String? ?? (json['item'] is Map ? json['item']['name'] as String? : null);

        return PaymentSnapModel(
          snapToken: snapTokenValue ?? 'NO_TOKEN',
          orderId: orderIdValue ?? 'NO_ORDER_ID',
          type: json['type'] as String? ?? 'subscription',
          avatarId: json['avatar_id'] as String?,
          subscriptionPlan: subscriptionPlanValue,
          amount: amountValue != null 
              ? (amountValue is num ? amountValue.toDouble() : double.tryParse(amountValue.toString()) ?? 0.0)
              : 0.0,
          currency: currencyValue,
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
    };
  }
}
