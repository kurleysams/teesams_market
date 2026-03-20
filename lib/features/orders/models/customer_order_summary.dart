class CustomerOrderSummary {
  final int id;
  final String orderNumber;
  final String status;
  final String? paymentStatus;
  final double? total;
  final String? currency;
  final String? placedAt;

  CustomerOrderSummary({
    required this.id,
    required this.orderNumber,
    required this.status,
    this.paymentStatus,
    this.total,
    this.currency,
    this.placedAt,
  });

  factory CustomerOrderSummary.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return CustomerOrderSummary(
      id: int.tryParse(json['id'].toString()) ?? 0,
      orderNumber: json['order_number']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      paymentStatus: json['payment_status']?.toString(),
      total: toDouble(json['total']),
      currency: json['currency']?.toString(),
      placedAt: json['placed_at']?.toString(),
    );
  }
}
