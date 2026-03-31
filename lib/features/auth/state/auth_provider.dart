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
      final storedToken = await AuthStorage().getToken();

      if (storedToken == null || storedToken.isEmpty) {
        _token = null;
        _user = null;
        return;
      }

      _token = storedToken;

      final api = await ApiClient.create(
        tenantSlug: tenantSlug,
        authToken: _token,
      );

      final response = await api.dio.get(Endpoints.authMe);
      final data = response.data;

      if (data is Map<String, dynamic> &&
          data['user'] is Map<String, dynamic>) {
        final userJson = Map<String, dynamic>.from(data['user']);
        final profileJson = data['profile'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(data['profile'])
            : null;

        _user = AuthUser.fromJson(userJson, profileJson: profileJson);
      } else {
        _token = null;
        _user = null;
        await AuthStorage().clearToken();
      }
    } catch (e) {
      _token = null;
      _user = null;
      _error = e.toString().replaceFirst('Exception: ', '');
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
      await AuthStorage().saveToken(token);

      final profileJson = data['profile'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(data['profile'])
          : null;

      _user = AuthUser.fromJson(
        Map<String, dynamic>.from(userJson),
        profileJson: profileJson,
      );
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map && data['message'] != null) {
        _error = data['message'].toString();
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
      await AuthStorage().saveToken(token);

      final profileJson = data['profile'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(data['profile'])
          : null;

      _user = AuthUser.fromJson(
        Map<String, dynamic>.from(userJson),
        profileJson: profileJson,
      );
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

  Future<void> updateProfile({
    required String tenantSlug,
    String? name,
    String? phone,
    String? defaultDeliveryAddress,
    String? defaultFulfilmentType,
  }) async {
    if (_token == null || _token!.isEmpty) {
      throw Exception('Not authenticated');
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final api = await ApiClient.create(
        tenantSlug: tenantSlug,
        authToken: _token,
      );

      final response = await api.dio.patch(
        Endpoints.myProfile,
        data: {
          'name': name,
          'phone': phone,
          'default_delivery_address': defaultDeliveryAddress,
          'default_fulfilment_type': defaultFulfilmentType,
        },
      );

      final data = response.data;
      if (data is! Map<String, dynamic> ||
          data['profile'] is! Map<String, dynamic>) {
        throw Exception('Invalid profile response');
      }

      final profileJson = Map<String, dynamic>.from(data['profile']);

      _user = (_user ?? const AuthUser(id: 0, name: '', email: '')).copyWith(
        name: profileJson['name']?.toString(),
        phone: profileJson['phone']?.toString(),
        defaultDeliveryAddress: profileJson['default_delivery_address']
            ?.toString(),
        defaultFulfilmentType: profileJson['default_fulfilment_type']
            ?.toString(),
      );
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map && data['message'] != null) {
        _error = data['message'].toString();
      } else {
        _error = e.message ?? 'Unable to update profile';
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
      // ignore remote logout errors
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
