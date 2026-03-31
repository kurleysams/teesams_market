import 'package:flutter/foundation.dart';

import '../../auth/state/auth_provider.dart';
import 'seller_auth_provider.dart';
import 'seller_onboarding_provider.dart';
import 'tenant_mode_provider.dart';

class AppSessionProvider extends ChangeNotifier {
  bool loading = false;
  bool initialized = false;
  String? error;

  Future<void> initialize({
    required String tenantSlug,
    required AuthProvider authProvider,
    required SellerAuthProvider sellerAuthProvider,
    required SellerOnboardingProvider sellerOnboardingProvider,
    required TenantModeProvider tenantModeProvider,
  }) async {
    if (loading) return;

    loading = true;
    error = null;
    notifyListeners();

    try {
      // Customer session restore
      await authProvider.loadSession(tenantSlug: tenantSlug);

      if (authProvider.isAuthenticated && authProvider.token != null) {
        await tenantModeProvider.loadBootstrap(
          tenantSlug: tenantSlug,
          authToken: authProvider.token,
        );
      } else {
        tenantModeProvider.clear();
      }

      // Seller session restore
      await sellerAuthProvider.restoreToken();

      if (sellerAuthProvider.isAuthenticated) {
        try {
          await sellerAuthProvider.loadMe();
          await sellerOnboardingProvider.loadStatus();
        } catch (_) {
          // seller token may be stale; seller provider can still surface state
        }
      }

      initialized = true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void reset() {
    loading = false;
    initialized = false;
    error = null;
    notifyListeners();
  }
}
