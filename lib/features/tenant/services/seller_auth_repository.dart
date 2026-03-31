import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';

class SellerAuthRepository {
  final ApiClient apiClient;

  SellerAuthRepository(this.apiClient);

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? passwordConfirmation,
  }) async {
    final response = await apiClient.dio.post(
      Endpoints.sellerRegister,
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation ?? password,
      },
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.dio.post(
      Endpoints.sellerLogin,
      data: {'email': email, 'password': password},
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> me() async {
    final response = await apiClient.dio.get(Endpoints.sellerMe);
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> logout() async {
    await apiClient.dio.post(Endpoints.sellerLogout);
  }
}
