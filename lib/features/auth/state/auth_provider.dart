import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../data/auth_storage.dart';
import '../models/auth_user.dart';

class AuthProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  String? _token;
  AuthUser? _user;

  bool get loading => _loading;
  String? get error => _error;
  String? get token => _token;
  AuthUser? get user => _user;

  bool get isAuthenticated =>
      _token != null && _token!.isNotEmpty && _user != null;

  Future<void> loadSession({required String tenantSlug}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _token = await AuthStorage().getToken();

      if (_token == null || _token!.isEmpty) {
        _token = null;
        _user = null;
        return;
      }

      final api = await ApiClient.create(
        tenantSlug: tenantSlug,
        authToken: _token,
      );

      final response = await api.dio.get(Endpoints.authMe);
      final data = response.data;

      if (data is Map<String, dynamic> &&
          data['user'] is Map<String, dynamic>) {
        _user = AuthUser.fromJson(Map<String, dynamic>.from(data['user']));
      } else {
        _token = null;
        _user = null;
        await AuthStorage().clearToken();
      }
    } catch (_) {
      _token = null;
      _user = null;
      await AuthStorage().clearToken();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> login({
    required String tenantSlug,
    required String email,
    required String password,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final api = await ApiClient.create(tenantSlug: tenantSlug);

      final response = await api.dio.post(
        Endpoints.authLogin,
        data: {'email': email.trim(), 'password': password},
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid login response');
      }

      final token = data['token']?.toString();
      final userJson = data['user'];

      if (token == null || token.isEmpty || userJson is! Map<String, dynamic>) {
        throw Exception('Invalid login response');
      }

      _token = token;
      _user = AuthUser.fromJson(Map<String, dynamic>.from(userJson));
      await AuthStorage().saveToken(token);
      debugPrint('LOGIN TOKEN SAVED 1 -> $token');
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map && data['message'] != null) {
        _error = data['message'].toString();
      } else if (e.response?.statusCode == 422) {
        _error = 'Invalid email or password';
      } else {
        _error = e.message ?? 'Unable to login';
      }

      throw Exception(_error);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      throw Exception(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String tenantSlug,
    required String name,
    required String email,
    String? phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final api = await ApiClient.create(tenantSlug: tenantSlug);

      final response = await api.dio.post(
        Endpoints.authRegister,
        data: {
          'name': name.trim(),
          'email': email.trim(),
          'phone': phone?.trim(),
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid register response');
      }

      final token = data['token']?.toString();
      final userJson = data['user'];

      if (token == null || token.isEmpty || userJson is! Map<String, dynamic>) {
        throw Exception('Invalid register response');
      }

      _token = token;
      _user = AuthUser.fromJson(Map<String, dynamic>.from(userJson));
      await AuthStorage().saveToken(token);
      debugPrint('LOGIN TOKEN SAVED 2 -> $token');
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map && data['message'] != null) {
        _error = data['message'].toString();
      } else {
        _error = e.message ?? 'Unable to register';
      }

      throw Exception(_error);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      throw Exception(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout({required String tenantSlug}) async {
    try {
      if (_token != null && _token!.isNotEmpty) {
        final api = await ApiClient.create(
          tenantSlug: tenantSlug,
          authToken: _token,
        );
        await api.dio.post(Endpoints.authLogout);
      }
    } catch (_) {
      // Ignore logout failure and clear local session anyway
    } finally {
      _token = null;
      _user = null;
      _error = null;
      await AuthStorage().clearToken();
      notifyListeners();
    }
  }

  Future<void> forceClearSession() async {
    _token = null;
    _user = null;
    _error = null;
    await AuthStorage().clearToken();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
