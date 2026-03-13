import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    Stripe.publishableKey = "pk_test_your_key_here";
    await Stripe.instance.applySettings();
    debugPrint('Stripe initialized successfully');
  } catch (e, st) {
    debugPrint('Stripe initialization failed: $e');
    debugPrint('$st');
  }

  runApp(const TeesamsMarketApp());
}
