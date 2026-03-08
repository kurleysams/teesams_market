import '../config/tenant_config.dart';
import 'storage_service.dart';

class TenantService {
  static const _tenantKey = 'selected_tenant_slug';

  Future<String> loadTenantSlug() async {
    return await StorageService.readString(_tenantKey) ??
        supportedTenants.first.slug;
  }

  Future<void> saveTenantSlug(String slug) async {
    await StorageService.writeString(_tenantKey, slug);
  }
}
