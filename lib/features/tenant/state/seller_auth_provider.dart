import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../data/seller_auth_storage.dart';
import '../services/seller_auth_repository.dart';

class SellerAuthProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  String? _token;
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _tenant;

  bool get loading => _loading;
  String? get error => _error;
  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  Map<String, dynamic>? get tenant => _tenant;
  bool get isAuthenticated => _token != null && _token!.trim().isNotEmpty;

  Future<void> register({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final apiClient = await ApiClient.create();
      final repository = SellerAuthRepository(apiClient);

      final json = await repository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      await _handleAuthResponse(json, apiClient);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login({required String email, required String password}) async {
    _setLoading(true);
    _error = null;

    try {
      final apiClient = await ApiClient.create();
      final repository = SellerAuthRepository(apiClient);

      final json = await repository.login(email: email, password: password);

      await _handleAuthResponse(json, apiClient);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMe() async {
    if (!isAuthenticated) return;

    _setLoading(true);
    _error = null;

    try {
      final apiClient = await ApiClient.create(authToken: _token);
      final repository = SellerAuthRepository(apiClient);

      final json = await repository.me();

      _user = json['user'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['user'] as Map)
          : null;

      _tenant = json['tenant'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['tenant'] as Map)
          : null;

      notifyListeners();
    } catch (e) {
      _token = null;
      _user = null;
      _tenant = null;
      _error = e.toString().replaceFirst('Exception: ', '');
      await SellerAuthStorage().clearToken();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      if (_token != null) {
        final apiClient = await ApiClient.create(authToken: _token);
        final repository = SellerAuthRepository(apiClient);
        await repository.logout();
      }
    } catch (_) {
      // ignore remote logout errors
    }

    _token = null;
    _user = null;
    _tenant = null;
    _error = null;

    await SellerAuthStorage().clearToken();
    notifyListeners();
  }

  Future<void> restoreToken() async {
    final token = await SellerAuthStorage().getToken();

    if (token != null && token.trim().isNotEmpty) {
      _token = token;
      notifyListeners();
    }
  }

  Future<void> _handleAuthResponse(
    Map<String, dynamic> json,
    ApiClient apiClient,
  ) async {
    final token = (json['token'] ?? json['access_token'])?.toString();

    if (token == null || token.trim().isEmpty) {
      throw Exception('Authentication token missing from response.');
    }

    _token = token;
    await SellerAuthStorage().saveToken(token);
    await apiClient.setAuthToken(token);

    if (json['user'] is Map<String, dynamic>) {
      _user = Map<String, dynamic>.from(json['user'] as Map);
    }

    if (json['tenant'] is Map<String, dynamic>) {
      _tenant = Map<String, dynamic>.from(json['tenant'] as Map);
    }

    notifyListeners();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
