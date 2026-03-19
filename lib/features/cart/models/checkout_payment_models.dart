class CreatePaymentRequest {
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final String fulfilmentType;
  final String deliveryAddress;
  final String? customerNote;
  final List<CheckoutPaymentItem> items;

  const CreatePaymentRequest({
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    required this.fulfilmentType,
    required this.deliveryAddress,
    this.customerNote,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    'customer_name': customerName,
    'customer_phone': customerPhone,
    'customer_email': customerEmail?.trim().isEmpty == true
        ? null
        : customerEmail?.trim(),
    'fulfilment_type': fulfilmentType,
    'delivery_address': deliveryAddress,
    'customer_note': customerNote?.trim().isEmpty == true
        ? null
        : customerNote?.trim(),
    'items': items.map((e) => e.toJson()).toList(),
  };
}

class CheckoutPaymentItem {
  final int variantId;
  final int qty;

  const CheckoutPaymentItem({required this.variantId, required this.qty});

  Map<String, dynamic> toJson() => {'variant_id': variantId, 'qty': qty};
}

class CreatePaymentResponse {
  final int orderId;
  final String orderNumber;
  final String paymentIntentId;
  final String clientSecret;
  final int amount;
  final String currency;
  final String status;

  const CreatePaymentResponse({
    required this.orderId,
    required this.orderNumber,
    required this.paymentIntentId,
    required this.clientSecret,
    required this.amount,
    required this.currency,
    required this.status,
  });

  factory CreatePaymentResponse.fromJson(Map<String, dynamic> json) {
    return CreatePaymentResponse(
      orderId: json['order_id'] as int,
      orderNumber: json['order_number'] as String,
      paymentIntentId: json['payment_intent_id'] as String,
      clientSecret: json['client_secret'] as String,
      amount: json['amount'] as int,
      currency: json['currency'] as String,
      status: json['status'] as String,
    );
  }
}
