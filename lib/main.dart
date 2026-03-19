import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'core/config/app_config.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = AppConfig.stripePublishableKey;
  await Stripe.instance.applySettings();

  runApp(const TeesamsMarketApp());
}
