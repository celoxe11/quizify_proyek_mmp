class PaymentStatusModel {
  final String orderId;
  final String status; // 'pending', 'success', 'failed', 'cancelled'
  final String type;
  final double amount;
  final String? paymentMethod;
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? snapToken;
  final String? itemName;

  PaymentStatusModel({
    required this.orderId,
    required this.status,
    required this.type,
    required this.amount,
    this.paymentMethod,
    required this.createdAt,
    this.paidAt,
    this.snapToken,
    this.itemName,
  });

  factory PaymentStatusModel.fromJson(Map<String, dynamic> json) {
    final orderIdValue = json['order_id'] as String? ?? json['transaction_id'] as String? ?? '';
    dynamic amountValue = json['amount'];
    if (amountValue == null && json['item'] is Map && json['item']['price'] != null) {
      amountValue = json['item']['price'];
    }
    return PaymentStatusModel(
      orderId: orderIdValue,
      status: json['status'] as String? ?? 'pending',
      type: json['category'] as String? ?? 'subscription',
      amount: amountValue != null
          ? (amountValue is num ? amountValue.toDouble() : double.tryParse(amountValue.toString()) ?? 0.0)
          : 0.0,
      paymentMethod: json['payment_method'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      snapToken: json['snap_token'] as String?,
      itemName: json['item_name'] as String?,
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
      'snap_token': snapToken,
      'item_name': itemName,
    };
  }
}
