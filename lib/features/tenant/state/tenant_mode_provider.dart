import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../../../core/services/storage_service.dart';
import '../../auth/models/app_bootstrap.dart';
import '../../auth/models/tenant_membership.dart';

class TenantModeProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;

  AppBootstrap? _bootstrap;
  String? _selectedMode;
  TenantMembership? _selectedMembership;

  bool get loading => _loading;
  String? get error => _error;

  AppBootstrap? get bootstrap => _bootstrap;
  String get selectedMode => _selectedMode ?? '';
  TenantMembership? get selectedMembership => _selectedMembership;

  bool get isTenantMode => _selectedMode == 'tenant';
  bool get isCustomerMode => _selectedMode == 'customer';

  int? get selectedStoreId => _selectedMembership?.storeId;
  String? get selectedStoreName => _selectedMembership?.storeName;
  String? get selectedTenantName => _selectedMembership?.tenantName;

  Future<void> loadBootstrap({
    required String tenantSlug,
    String? authToken,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final api = await ApiClient.create(
        tenantSlug: tenantSlug,
        authToken: authToken,
      );

      final response = await api.dio.get(Endpoints.appBootstrap);
      final data = response.data;

      debugPrint('BOOTSTRAP RESPONSE -> $data');

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid bootstrap response');
      }

      _bootstrap = AppBootstrap.fromJson(data);

      debugPrint(
        'BOOTSTRAP MODES -> '
        'available=${_bootstrap?.availableModes}, '
        'default=${_bootstrap?.defaultMode}',
      );

      debugPrint(
        'BOOTSTRAP MEMBERSHIP COUNT -> ${_bootstrap?.tenantMemberships.length ?? 0}',
      );

      for (final membership
          in _bootstrap?.tenantMemberships ?? <TenantMembership>[]) {
        debugPrint(
          'BOOTSTRAP MEMBERSHIP ITEM -> '
          'storeId=${membership.storeId}, '
          'storeName=${membership.storeName}, '
          'tenantName=${membership.tenantName}, '
          'role=${membership.role}, '
          'permissions=${membership.permissions}',
        );
      }

      final storedMode = await StorageService.readString('selected_app_mode');

      if (storedMode != null &&
          _bootstrap!.availableModes.contains(storedMode)) {
        _selectedMode = storedMode;
      } else if (_bootstrap!.availableModes.length == 1) {
        _selectedMode = _bootstrap!.defaultMode;
      } else {
        _selectedMode = null;
      }

      debugPrint('BOOTSTRAP SELECTED MODE -> $_selectedMode');

      // Important:
      // Do NOT silently pick the first membership here.
      // Seller identity / store selection must be handled explicitly.
      _selectedMembership = null;

      debugPrint(
        'BOOTSTRAP SELECTED MEMBERSHIP -> '
        'storeId=${_selectedMembership?.storeId}, '
        'storeName=${_selectedMembership?.storeName}, '
        'tenantName=${_selectedMembership?.tenantName}, '
        'role=${_selectedMembership?.role}, '
        'permissions=${_selectedMembership?.permissions}',
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      debugPrint(
        'BOOTSTRAP DIO ERROR -> status=${e.response?.statusCode} data=$data',
      );

      if (data is Map && data['message'] != null) {
        _error = data['message'].toString();
      } else {
        _error = e.message ?? 'Unable to load tenant mode';
      }
    } catch (e) {
      debugPrint('BOOTSTRAP GENERAL ERROR -> $e');
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> setSelectedMode(String mode) async {
    _selectedMode = mode;
    await StorageService.writeString('selected_app_mode', mode);
    notifyListeners();
  }

  Future<void> setSelectedMembership(TenantMembership membership) async {
    _selectedMembership = membership;

    if (membership.storeId != null) {
      await StorageService.writeString(
        'selected_tenant_store_id',
        membership.storeId.toString(),
      );
    }

    notifyListeners();
  }

  Future<void> selectMembershipForSellerOrFail({
    required int? sellerTenantId,
  }) async {
    final memberships =
        _bootstrap?.tenantMemberships ?? const <TenantMembership>[];

    if (sellerTenantId == null) {
      _selectedMembership = null;
      _error = 'Seller account is missing linked store information.';
      notifyListeners();
      return;
    }

    TenantMembership? matched;

    for (final membership in memberships) {
      if (membership.storeId == sellerTenantId) {
        matched = membership;
        break;
      }
    }

    if (matched == null) {
      _selectedMembership = null;
      _error = 'This seller account does not have access to its linked store.';
      notifyListeners();
      return;
    }

    _error = null;
    await setSelectedMembership(matched);
    await setSelectedMode('tenant');

    debugPrint(
      'SELLER MEMBERSHIP MATCHED -> '
      'storeId=${matched.storeId}, '
      'storeName=${matched.storeName}, '
      'role=${matched.role}, '
      'permissions=${matched.permissions}',
    );
  }

  Future<void> selectStoredMembershipIfValid() async {
    final memberships =
        _bootstrap?.tenantMemberships ?? const <TenantMembership>[];
    final storedStoreId = await StorageService.readString(
      'selected_tenant_store_id',
    );

    if (memberships.isEmpty || storedStoreId == null) return;

    final parsedStoreId = int.tryParse(storedStoreId);
    if (parsedStoreId == null) return;

    for (final membership in memberships) {
      if (membership.storeId == parsedStoreId) {
        await setSelectedMembership(membership);
        return;
      }
    }
  }

  Future<void> clearPersistedSelection() async {
    await StorageService.delete('selected_app_mode');
    await StorageService.delete('selected_tenant_store_id');
  }

  Future<void> resetAll() async {
    await clearPersistedSelection();

    _bootstrap = null;
    _selectedMode = null;
    _selectedMembership = null;
    _error = null;
    _loading = false;
    notifyListeners();
  }

  void clear() {
    _bootstrap = null;
    _selectedMode = null;
    _selectedMembership = null;
    _error = null;
    notifyListeners();
  }

  bool hasPermission(String permission) {
    final membership = _selectedMembership;
    if (membership == null) return false;
    return membership.permissions.contains(permission);
  }

  bool get canReadOrders => hasPermission('orders.read');
  bool get canUpdateOrderStatus => hasPermission('orders.update_status');
  bool get canCancelOrders => hasPermission('orders.cancel');
  bool get canManageStoreStatus => hasPermission('store_status.manage');
  bool get canManageProductAvailability =>
      hasPermission('product_availability.manage');
  bool get canManageStaff => hasPermission('staff.manage');
}
