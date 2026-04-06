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
      // Restore customer session first.
      await authProvider.loadSession(tenantSlug: tenantSlug);

      // Restore seller session.
      await sellerAuthProvider.restoreToken();

      if (sellerAuthProvider.isAuthenticated) {
        try {
          await sellerAuthProvider.loadMe();
          await sellerOnboardingProvider.loadStatus();
        } catch (_) {
          // Continue; bootstrap may still work if token is present,
          // but seller-to-store matching may fail later if /me is unavailable.
        }
      }

      final sellerToken = sellerAuthProvider.token;
      final customerToken = authProvider.token;

      final effectiveToken =
          (sellerToken != null && sellerToken.trim().isNotEmpty)
          ? sellerToken
          : (customerToken != null && customerToken.trim().isNotEmpty)
          ? customerToken
          : null;

      if (effectiveToken != null) {
        await tenantModeProvider.loadBootstrap(
          tenantSlug: tenantSlug,
          authToken: effectiveToken,
        );

        if (sellerAuthProvider.isAuthenticated) {
          final rawTenantId = sellerAuthProvider.tenant?['id'];
          final sellerTenantId = rawTenantId is int
              ? rawTenantId
              : int.tryParse(rawTenantId?.toString() ?? '');

          await tenantModeProvider.selectMembershipForSellerOrFail(
            sellerTenantId: sellerTenantId,
          );

          if (tenantModeProvider.error == null) {
            await tenantModeProvider.setSelectedMode('tenant');
          }
        } else {
          await tenantModeProvider.selectStoredMembershipIfValid();

          final hasTenantMemberships =
              (tenantModeProvider.bootstrap?.tenantMemberships.length ?? 0) > 0;

          if (hasTenantMemberships &&
              tenantModeProvider.selectedMembership != null) {
            await tenantModeProvider.setSelectedMode('tenant');
          } else if (tenantModeProvider.bootstrap?.hasCustomerMode == true) {
            await tenantModeProvider.setSelectedMode('customer');
          }
        }
      } else {
        tenantModeProvider.clear();
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
