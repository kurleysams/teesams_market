import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'core/config/app_config.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint(details.exceptionAsString());
    debugPrintStack(stackTrace: details.stack);
  };

  runZonedGuarded(
    () async {
      try {
        debugPrint('Stripe key: ${AppConfig.stripePublishableKey}');

        Stripe.publishableKey = AppConfig.stripePublishableKey;
        await Stripe.instance.applySettings();

        runApp(const TeesamsMarketApp());
      } catch (e, st) {
        debugPrint('Startup error: $e');
        debugPrintStack(stackTrace: st);

        runApp(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Startup error: $e'),
                ),
              ),
            ),
          ),
        );
      }
    },
    (error, stack) {
      debugPrint('Zoned error: $error');
      debugPrintStack(stackTrace: stack);
    },
  );
}
