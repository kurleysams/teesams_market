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

  Tenant get tenant => _tenant;
  String get slug => _tenant.slug;

  Future<void> load() async {
    final slug = await _tenantService.loadTenantSlug();
    final found = supportedTenants.firstWhere(
      (t) => t.slug == slug,
      orElse: () => supportedTenants.first,
    );
    _tenant = Tenant(slug: found.slug, displayName: found.displayName);
    notifyListeners();
  }

  Future<void> select(Tenant tenant) async {
    _tenant = tenant;
    await _tenantService.saveTenantSlug(tenant.slug);
    notifyListeners();
  }
}
