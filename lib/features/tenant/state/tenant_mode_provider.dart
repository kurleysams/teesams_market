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

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid bootstrap response');
      }

      _bootstrap = AppBootstrap.fromJson(data);

      final storedMode = await StorageService.readString('selected_app_mode');
      final storedStoreId = await StorageService.readString(
        'selected_tenant_store_id',
      );

      if (storedMode != null &&
          _bootstrap!.availableModes.contains(storedMode)) {
        _selectedMode = storedMode;
      } else if (_bootstrap!.availableModes.length == 1) {
        _selectedMode = _bootstrap!.defaultMode;
      } else {
        _selectedMode = null;
      }

      if (_bootstrap!.tenantMemberships.isNotEmpty) {
        TenantMembership? selected;

        if (storedStoreId != null) {
          final parsedStoreId = int.tryParse(storedStoreId);
          if (parsedStoreId != null) {
            for (final membership in _bootstrap!.tenantMemberships) {
              if (membership.storeId == parsedStoreId) {
                selected = membership;
                break;
              }
            }
          }
        }

        selected ??= _bootstrap!.tenantMemberships.first;
        _selectedMembership = selected;
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        _error = data['message'].toString();
      } else {
        _error = e.message ?? 'Unable to load tenant mode';
      }
    } catch (e) {
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
