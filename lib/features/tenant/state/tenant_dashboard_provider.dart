import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/tenant_dashboard_api.dart';
import '../models/tenant_dashboard.dart';

class TenantDashboardProvider extends ChangeNotifier {
  final TenantDashboardApi _api = TenantDashboardApi();

  bool _loading = false;
  String? _error;
  TenantDashboard? _dashboard;

  bool get loading => _loading;
  String? get error => _error;
  TenantDashboard? get dashboard => _dashboard;

  Future<void> loadDashboard({
    required String tenantSlug,
    required String authToken,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint(
        'DASHBOARD LOAD START -> tenant=$tenantSlug tokenPresent=${authToken.isNotEmpty}',
      );

      final result = await _api.fetchDashboard(
        tenantSlug: tenantSlug,
        authToken: authToken,
      );

      _dashboard = result;
      debugPrint('DASHBOARD PARSED OK');
    } on DioException catch (e) {
      final data = e.response?.data;

      debugPrint(
        'DASHBOARD DIO ERROR -> status=${e.response?.statusCode} data=$data',
      );

      if (data is Map && data['message'] != null) {
        _error = data['message'].toString();
      } else {
        _error = e.message ?? 'Unable to load dashboard';
      }
    } catch (e) {
      debugPrint('DASHBOARD GENERAL ERROR -> $e');
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clear() {
    _loading = false;
    _error = null;
    _dashboard = null;
    notifyListeners();
  }
}
