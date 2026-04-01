import 'package:flutter/foundation.dart';

import '../../../core/services/storage_service.dart';
import '../models/tenant.dart';
import '../services/tenant_service.dart';

class TenantProvider extends ChangeNotifier {
  final TenantService _service = const TenantService();

  static const String _selectedTenantSlugKey = 'selected_tenant_slug';

  Tenant? _tenant;
  List<Tenant> _tenants = [];
  bool _loading = false;
  String? _error;
  String? _slug;

  Tenant get tenant =>
      _tenant ??
      Tenant(
        id: 0,
        name: 'Teesams Market',
        slug: _slug ?? '',
        currency: 'GBP',
        tagline: 'Browse • Search • Cart • Checkout',
        logoUrl: null,
        bannerUrl: null,
        primaryColor: null,
      );

  List<Tenant> get tenants => List.unmodifiable(_tenants);

  bool get loading => _loading;
  bool get isLoading => _loading;

  String? get error => _error;
  String? get errorMessage => _error;

  String get slug => _tenant?.slug ?? (_slug ?? '');

  Future<void> loadTenant({String? tenantSlug}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final explicitSlug = tenantSlug?.trim();
      final storedSlug = await StorageService.readString(
        _selectedTenantSlugKey,
      );

      String? slugToUse;

      if (explicitSlug != null && explicitSlug.isNotEmpty) {
        slugToUse = explicitSlug;
      } else if (storedSlug != null && storedSlug.trim().isNotEmpty) {
        slugToUse = storedSlug.trim();
      } else if (_slug != null && _slug!.trim().isNotEmpty) {
        slugToUse = _slug!.trim();
      }

      if (slugToUse == null || slugToUse.isEmpty) {
        final availableTenants = await _service.fetchTenants(
          tenantSlug: 'fishseafoods',
        );

        _tenants = List<Tenant>.from(availableTenants);

        if (_tenants.isEmpty) {
          throw Exception('No stores available');
        }

        final fallbackTenant = _tenants.first;
        _tenant = fallbackTenant;
        _slug = fallbackTenant.slug;

        await StorageService.writeString(
          _selectedTenantSlugKey,
          fallbackTenant.slug,
        );

        notifyListeners();
        return;
      }

      _slug = slugToUse;

      final currentTenant = await _service.fetchCurrentTenant(
        tenantSlug: slugToUse,
      );

      _tenant = currentTenant;
      _slug = currentTenant.slug;

      await StorageService.writeString(
        _selectedTenantSlugKey,
        currentTenant.slug,
      );

      final availableTenants = await _service.fetchTenants(
        tenantSlug: currentTenant.slug,
      );

      _tenants = List<Tenant>.from(availableTenants);

      if (_tenants.every((t) => t.id != currentTenant.id)) {
        _insertCurrentTenant();
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
      final slugForRequest = _slug?.trim();

      if (slugForRequest == null || slugForRequest.isEmpty) {
        final storedSlug = await StorageService.readString(
          _selectedTenantSlugKey,
        );
        _slug = storedSlug?.trim();
      }

      final availableTenants = await _service.fetchTenants(
        tenantSlug: (_slug != null && _slug!.isNotEmpty)
            ? _slug!
            : 'fishseafoods',
      );

      _tenants = List<Tenant>.from(availableTenants);

      if (_tenant != null && _tenants.every((t) => t.id != _tenant!.id)) {
        _insertCurrentTenant();
      }

      notifyListeners();
    } catch (e) {
      _error = 'Failed to load stores: $e';
      notifyListeners();
    }
  }

  Future<void> switchTenant(Tenant selectedTenant) async {
    if (_tenant?.id == selectedTenant.id) return;

    await StorageService.writeString(
      _selectedTenantSlugKey,
      selectedTenant.slug,
    );

    _tenant = selectedTenant;
    _slug = selectedTenant.slug;
    notifyListeners();

    await loadTenant(tenantSlug: selectedTenant.slug);
  }

  Future<void> setTenant(Tenant tenant) async {
    _tenant = tenant;
    _slug = tenant.slug;

    await StorageService.writeString(_selectedTenantSlugKey, tenant.slug);
    notifyListeners();
  }

  Future<void> clearSelectedTenant() async {
    _tenant = null;
    _slug = null;
    await StorageService.delete(_selectedTenantSlugKey);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _insertCurrentTenant() {
    if (_tenant == null) return;
    _tenants = [_tenant!, ..._tentsWithoutCurrent()];
  }

  List<Tenant> _tentsWithoutCurrent() {
    if (_tenant == null) return _tenants;
    return _tenants.where((t) => t.id != _tenant!.id).toList();
  }
}
