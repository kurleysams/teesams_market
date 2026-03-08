import 'package:flutter/foundation.dart';

import '../../tenant/state/tenant_provider.dart';
import '../data/payment_repository.dart';
import '../services/stripe_service.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentRepository _repository = PaymentRepository();
  final StripeService _stripeService = StripeService();

  String _tenantSlug = 'default';
  bool _loading = false;
  String? _error;
  bool _initialized = false;

  bool get loading => _loading;
  String? get error => _error;

  void bindTenant(TenantProvider tenantProvider) {
    _tenantSlug = tenantProvider.slug;
  }

  Future<void> init() async {
    if (_initialized) return;
    await _stripeService.init();
    _initialized = true;
  }

  Future<bool> payForOrder(int orderId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await init();
      final payment = await _repository.createPaymentIntent(
        tenantSlug: _tenantSlug,
        orderId: orderId,
      );
      final clientSecret = payment['client_secret'] as String;
      await _stripeService.presentPaymentSheet(clientSecret: clientSecret);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
