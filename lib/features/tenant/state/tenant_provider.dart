import 'package:flutter/foundation.dart';

import '../../../core/config/tenant_config.dart';
import '../../../core/services/tenant_service.dart';
import '../models/tenant.dart';

class TenantProvider extends ChangeNotifier {
  final TenantService _tenantService = TenantService();

  Tenant _tenant = Tenant(
    slug: supportedTenants.first.slug,
    displayName: supportedTenants.first.displayName,
  );

  bool _isLoading = true;
  String? _errorMessage;

  Tenant get tenant => _tenant;
  String get slug => _tenant.slug;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final slug = await _tenantService.loadTenantSlug();

      final found = supportedTenants.firstWhere(
        (t) => t.slug == slug,
        orElse: () => supportedTenants.first,
      );

      _tenant = Tenant(slug: found.slug, displayName: found.displayName);
    } catch (e) {
      _errorMessage = 'Failed to load store configuration.';
      debugPrint('Tenant load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> select(Tenant tenant) async {
    try {
      _tenant = tenant;
      await _tenantService.saveTenantSlug(tenant.slug);
      notifyListeners();
    } catch (e) {
      debugPrint('Tenant select error: $e');
    }
  }
}
