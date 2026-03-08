import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../../core/config/app_config.dart';

class StripeService {
  Future<void> init() async {
    Stripe.publishableKey = AppConfig.stripePublishableKey;
    Stripe.merchantIdentifier = AppConfig.stripeMerchantIdentifier;
    await Stripe.instance.applySettings();
  }

  Future<void> presentPaymentSheet({required String clientSecret}) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: AppConfig.merchantDisplayName,
        applePay: const PaymentSheetApplePay(
          merchantCountryCode: AppConfig.merchantCountryCode,
        ),
        googlePay: const PaymentSheetGooglePay(
          merchantCountryCode: AppConfig.merchantCountryCode,
          testEnv: true,
        ),
        style: ThemeMode.system,
      ),
    );

    await Stripe.instance.presentPaymentSheet();
  }
}
