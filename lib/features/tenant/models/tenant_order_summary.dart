class TenantOrderSummary {
  final int id;
  final String orderNumber;
  final String orderType;
  final String status;
  final String statusLabel;
  final String customerName;
  final String createdAt;
  final String? scheduledFor;
  final int itemsCount;
  final double total;
  final String paymentStatus;
  final bool hasNote;
  final List<TenantOrderActionSummary> allowedActions;

  const TenantOrderSummary({
    required this.id,
    required this.orderNumber,
    required this.orderType,
    required this.status,
    required this.statusLabel,
    required this.customerName,
    required this.createdAt,
    required this.scheduledFor,
    required this.itemsCount,
    required this.total,
    required this.paymentStatus,
    required this.hasNote,
    required this.allowedActions,
  });

  factory TenantOrderSummary.fromJson(Map<String, dynamic> json) {
    return TenantOrderSummary(
      id: (json['id'] as num).toInt(),
      orderNumber: json['order_number']?.toString() ?? '',
      orderType: json['order_type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? 'Customer',
      createdAt: json['created_at']?.toString() ?? '',
      scheduledFor: json['scheduled_for']?.toString(),
      itemsCount: (json['items_count'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      paymentStatus: json['payment_status']?.toString() ?? '',
      hasNote: json['has_note'] == true,
      allowedActions: (json['allowed_actions'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                TenantOrderActionSummary.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
    );
  }
}

class TenantOrderActionSummary {
  final String key;
  final String label;
  final bool destructive;

  const TenantOrderActionSummary({
    required this.key,
    required this.label,
    required this.destructive,
  });

  factory TenantOrderActionSummary.fromJson(Map<String, dynamic> json) {
    return TenantOrderActionSummary(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      destructive: json['destructive'] == true,
    );
  }
}
