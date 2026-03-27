class TenantOrderDetails {
  final int id;
  final String orderNumber;
  final String orderType;
  final String status;
  final String statusLabel;

  final TenantOrderCustomer customer;
  final TenantOrderTiming timing;
  final TenantOrderPayment payment;
  final TenantOrderTotals totals;
  final TenantOrderNotes notes;
  final TenantOrderDelivery delivery;

  final List<TenantOrderItem> items;
  final List<TenantOrderHistoryItem> history;
  final List<TenantOrderActionSummary> allowedActions;

  const TenantOrderDetails({
    required this.id,
    required this.orderNumber,
    required this.orderType,
    required this.status,
    required this.statusLabel,
    required this.customer,
    required this.timing,
    required this.payment,
    required this.totals,
    required this.notes,
    required this.delivery,
    required this.items,
    required this.history,
    required this.allowedActions,
  });

  factory TenantOrderDetails.fromJson(Map<String, dynamic> json) {
    return TenantOrderDetails(
      id: (json['id'] as num).toInt(),
      orderNumber: json['order_number']?.toString() ?? '',
      orderType: json['order_type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? '',
      customer: TenantOrderCustomer.fromJson(
        Map<String, dynamic>.from(json['customer'] as Map? ?? {}),
      ),
      timing: TenantOrderTiming.fromJson(
        Map<String, dynamic>.from(json['timing'] as Map? ?? {}),
      ),
      payment: TenantOrderPayment.fromJson(
        Map<String, dynamic>.from(json['payment'] as Map? ?? {}),
      ),
      totals: TenantOrderTotals.fromJson(
        Map<String, dynamic>.from(json['totals'] as Map? ?? {}),
      ),
      notes: TenantOrderNotes.fromJson(
        Map<String, dynamic>.from(json['notes'] as Map? ?? {}),
      ),
      delivery: TenantOrderDelivery.fromJson(
        Map<String, dynamic>.from(json['delivery'] as Map? ?? {}),
      ),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => TenantOrderItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      history: (json['history'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                TenantOrderHistoryItem.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
      allowedActions: (json['allowed_actions'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                TenantOrderActionSummary.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
    );
  }
}

class TenantOrderCustomer {
  final int? id;
  final String name;
  final String phone;
  final String email;

  const TenantOrderCustomer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
  });

  factory TenantOrderCustomer.fromJson(Map<String, dynamic> json) {
    return TenantOrderCustomer(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}

class TenantOrderTiming {
  final String createdAt;
  final String? scheduledFor;

  const TenantOrderTiming({
    required this.createdAt,
    required this.scheduledFor,
  });

  factory TenantOrderTiming.fromJson(Map<String, dynamic> json) {
    return TenantOrderTiming(
      createdAt: json['created_at']?.toString() ?? '',
      scheduledFor: json['scheduled_for']?.toString(),
    );
  }
}

class TenantOrderPayment {
  final String status;
  final String method;
  final String stripePaymentIntentId;

  const TenantOrderPayment({
    required this.status,
    required this.method,
    required this.stripePaymentIntentId,
  });

  factory TenantOrderPayment.fromJson(Map<String, dynamic> json) {
    return TenantOrderPayment(
      status: json['status']?.toString() ?? '',
      method: json['method']?.toString() ?? '',
      stripePaymentIntentId: json['stripe_payment_intent_id']?.toString() ?? '',
    );
  }
}

class TenantOrderTotals {
  final double subtotal;
  final double deliveryFee;
  final double discountTotal;
  final double total;
  final String currency;

  const TenantOrderTotals({
    required this.subtotal,
    required this.deliveryFee,
    required this.discountTotal,
    required this.total,
    required this.currency,
  });

  factory TenantOrderTotals.fromJson(Map<String, dynamic> json) {
    return TenantOrderTotals(
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0,
      discountTotal: (json['discount_total'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? 'GBP',
    );
  }
}

class TenantOrderNotes {
  final String customerNote;

  const TenantOrderNotes({required this.customerNote});

  factory TenantOrderNotes.fromJson(Map<String, dynamic> json) {
    return TenantOrderNotes(
      customerNote: json['customer_note']?.toString() ?? '',
    );
  }
}

class TenantOrderDelivery {
  final String fulfilmentType;
  final String deliveryAddress;

  const TenantOrderDelivery({
    required this.fulfilmentType,
    required this.deliveryAddress,
  });

  factory TenantOrderDelivery.fromJson(Map<String, dynamic> json) {
    return TenantOrderDelivery(
      fulfilmentType: json['fulfilment_type']?.toString() ?? '',
      deliveryAddress: json['delivery_address']?.toString() ?? '',
    );
  }
}

class TenantOrderItem {
  final int id;
  final String name;
  final int quantity;
  final double price;
  final double lineTotal;
  final String notes;
  final List<TenantOrderModifier> modifiers;

  const TenantOrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.lineTotal,
    required this.notes,
    required this.modifiers,
  });

  factory TenantOrderItem.fromJson(Map<String, dynamic> json) {
    return TenantOrderItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      lineTotal: (json['line_total'] as num?)?.toDouble() ?? 0,
      notes: json['notes']?.toString() ?? '',
      modifiers: (json['modifiers'] as List<dynamic>? ?? [])
          .map(
            (e) => TenantOrderModifier.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
    );
  }
}

class TenantOrderModifier {
  final String name;
  final double price;
  final int quantity;

  const TenantOrderModifier({
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory TenantOrderModifier.fromJson(Map<String, dynamic> json) {
    return TenantOrderModifier(
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    );
  }
}

class TenantOrderHistoryItem {
  final String? fromStatus;
  final String toStatus;
  final String? actionKey;
  final String? reasonCode;
  final String? note;
  final String? changedByName;
  final String createdAt;

  const TenantOrderHistoryItem({
    required this.fromStatus,
    required this.toStatus,
    required this.actionKey,
    required this.reasonCode,
    required this.note,
    required this.changedByName,
    required this.createdAt,
  });

  factory TenantOrderHistoryItem.fromJson(Map<String, dynamic> json) {
    return TenantOrderHistoryItem(
      fromStatus: json['from_status']?.toString(),
      toStatus: json['to_status']?.toString() ?? '',
      actionKey: json['action_key']?.toString(),
      reasonCode: json['reason_code']?.toString(),
      note: json['note']?.toString(),
      changedByName: json['changed_by_name']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
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

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
