class CheckoutCustomer {
  final String name;
  final String? email;
  final String? phone;

  const CheckoutCustomer({required this.name, this.email, this.phone});

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
  };
}

class CheckoutItem {
  final int productId;
  final int quantity;

  const CheckoutItem({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'quantity': quantity,
  };
}

class CheckoutAddress {
  final String? line1;
  final String? line2;
  final String? city;
  final String? postcode;

  const CheckoutAddress({this.line1, this.line2, this.city, this.postcode});

  Map<String, dynamic> toJson() => {
    'line1': line1,
    'line2': line2,
    'city': city,
    'postcode': postcode,
  };
}

class CreatePaymentRequest {
  final CheckoutCustomer customer;
  final List<CheckoutItem> items;
  final String deliveryMethod; // delivery | pickup
  final int? deliveryZoneId;
  final CheckoutAddress? address;
  final String? notes;

  const CreatePaymentRequest({
    required this.customer,
    required this.items,
    required this.deliveryMethod,
    this.deliveryZoneId,
    this.address,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'customer': customer.toJson(),
    'items': items.map((e) => e.toJson()).toList(),
    'delivery_method': deliveryMethod,
    'delivery_zone_id': deliveryZoneId,
    'address': address?.toJson(),
    'notes': notes,
  };
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
