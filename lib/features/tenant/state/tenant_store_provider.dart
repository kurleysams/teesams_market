import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/tenant_store_api.dart';
import '../models/tenant_store_status.dart';

class TenantStoreProvider extends ChangeNotifier {
  final TenantStoreApi _api = TenantStoreApi();

  bool _loading = false;
  bool _saving = false;
  String? _error;
  TenantStoreStatus? _store;

  bool get loading => _loading;
  bool get saving => _saving;
  String? get error => _error;
  TenantStoreStatus? get store => _store;

  Future<void> loadStore({
    required String tenantSlug,
    required String authToken,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _store = await _api.fetchStore(
        tenantSlug: tenantSlug,
        authToken: authToken,
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        _error = data['message'].toString();
      } else {
        _error = e.message ?? 'Unable to load store';
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatus({
    required String tenantSlug,
    required String authToken,
    required bool isOpen,
  }) async {
    _saving = true;
    _error = null;
    notifyListeners();

    try {
      _store = await _api.updateStoreStatus(
        tenantSlug: tenantSlug,
        authToken: authToken,
        isOpen: isOpen,
      );
      return true;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        _error = data['message'].toString();
      } else {
        _error = e.message ?? 'Unable to update store status';
      }
      return false;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}
