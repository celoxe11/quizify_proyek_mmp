class PaymentStatusModel {
  final String orderId;
  final String status; // 'pending', 'success', 'failed', 'cancelled'
  final String type;
  final double amount;
  final String? paymentMethod;
  final DateTime createdAt;
  final DateTime? paidAt;

  PaymentStatusModel({
    required this.orderId,
    required this.status,
    required this.type,
    required this.amount,
    this.paymentMethod,
    required this.createdAt,
    this.paidAt,
  });

  factory PaymentStatusModel.fromJson(Map<String, dynamic> json) {
    return PaymentStatusModel(
      orderId: json['order_id'] as String,
      status: json['status'] as String? ?? 'pending',
      type: json['type'] as String? ?? 'subscription',
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'status': status,
      'type': type,
      'amount': amount,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
    };
  }
}
