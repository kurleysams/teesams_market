import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'checkout_api.dart';
import '../models/checkout_payment_models.dart';

class CheckoutResult {
  final int orderId;
  final String orderNumber;
  final String paymentIntentId;

  const CheckoutResult({
    required this.orderId,
    required this.orderNumber,
    required this.paymentIntentId,
  });
}

class StripeCheckoutService {
  final CheckoutApi api;

  StripeCheckoutService(this.api);

  Future<CheckoutResult> pay({
    required CreatePaymentRequest request,
    String merchantDisplayName = 'Teesams Market',
  }) async {
    final payment = await api.createPaymentIntent(request);

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: payment.clientSecret,
        merchantDisplayName: merchantDisplayName,
        allowsDelayedPaymentMethods: true,
        style: ThemeMode.system,
      ),
    );

    await Stripe.instance.presentPaymentSheet();

    return CheckoutResult(
      orderId: payment.orderId,
      orderNumber: payment.orderNumber,
      paymentIntentId: payment.paymentIntentId,
    );
  }
}
