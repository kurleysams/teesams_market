import 'package:flutter/foundation.dart';

import '../models/tenant.dart';
import '../services/tenant_service.dart';

class TenantProvider extends ChangeNotifier {
  final TenantService _service = const TenantService();

  Tenant? _tenant;
  List<Tenant> _tenants = [];
  bool _loading = false;
  String? _error;
  String _slug = 'fishseafoods';

  Tenant get tenant =>
      _tenant ??
      Tenant(
        id: 0,
        name: 'Teesams Market',
        slug: _slug,
        tagline: 'Browse • Search • Cart • Checkout',
        logoUrl: null,
        bannerUrl: null,
        primaryColor: null,
        isActive: true,
        sortOrder: 0,
      );

  List<Tenant> get tenants => _tenants;

  bool get loading => _loading;
  bool get isLoading => _loading;

  String? get error => _error;
  String? get errorMessage => _error;

  String get slug => _tenant?.slug ?? _slug;

  Future<void> loadTenant({String? tenantSlug}) async {
    _loading = true;
    _error = null;

    if (tenantSlug != null && tenantSlug.trim().isNotEmpty) {
      _slug = tenantSlug.trim();
    }

    notifyListeners();

    try {
      final currentTenant = await _service.fetchCurrentTenant(
        tenantSlug: _slug,
      );

      _tenant = currentTenant;
      _slug = currentTenant.slug;

      final availableTenants = await _service.fetchTenants(tenantSlug: _slug);

      _tenants = availableTenants;

      if (_tenants.every((t) => t.id != _tenant!.id)) {
        _tentsInsertCurrent();
      }
    } catch (e) {
      _error = 'Failed to load tenant: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> load() async {
    await loadTenant();
  }

  Future<void> loadTenants() async {
    try {
      final availableTenants = await _service.fetchTenants(tenantSlug: _slug);

      _tenants = availableTenants;

      if (_tenant != null && _tenants.every((t) => t.id != _tenant!.id)) {
        _tentsInsertCurrent();
      }

      notifyListeners();
    } catch (e) {
      _error = 'Failed to load stores: $e';
      notifyListeners();
    }
  }

  Future<void> switchTenant(Tenant selectedTenant) async {
    if (_tenant?.id == selectedTenant.id) return;

    _tenant = selectedTenant;
    _slug = selectedTenant.slug;
    notifyListeners();

    await loadTenant(tenantSlug: selectedTenant.slug);
  }

  void setTenant(Tenant tenant) {
    _tenant = tenant;
    _slug = tenant.slug;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _tentsInsertCurrent() {
    if (_tenant == null) return;
    _tenants = [_tenant!, ..._tenants];
  }
}
