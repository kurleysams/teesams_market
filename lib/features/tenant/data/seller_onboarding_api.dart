import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../models/tenant_onboarding_status.dart';

class SellerStripeConnectResponse {
  final String? url;
  final int? expiresAt;
  final OnboardingStatus status;

  const SellerStripeConnectResponse({
    required this.url,
    required this.expiresAt,
    required this.status,
  });

  factory SellerStripeConnectResponse.fromJson(Map<String, dynamic> json) {
    return SellerStripeConnectResponse(
      url: json['url']?.toString(),
      expiresAt: (json['expires_at'] as num?)?.toInt(),
      status: OnboardingStatus.fromApiResponse(json),
    );
  }
}

class SellerOnboardingApi {
  Future<OnboardingStatus> fetchStatus({
    required String tenantSlug,
    required String authToken,
  }) async {
    final api = ApiClient.create(tenantSlug: tenantSlug, authToken: authToken);

    final response = await api.dio.get(Endpoints.sellerOnboardingStatus);
    final data = response.data;

    if (data is! Map<String, dynamic> || data['data'] is! Map) {
      throw Exception('Invalid seller onboarding status response');
    }

    return OnboardingStatus.fromApiResponse(data);
  }

  Future<OnboardingStatus> fetchStripeStatus({
    required String tenantSlug,
    required String authToken,
  }) async {
    final api = ApiClient.create(tenantSlug: tenantSlug, authToken: authToken);

    final response = await api.dio.get(Endpoints.sellerStripeStatus);
    final data = response.data;

    if (data is! Map<String, dynamic> || data['data'] is! Map) {
      throw Exception('Invalid seller Stripe status response');
    }

    return OnboardingStatus.fromApiResponse(data);
  }

  Future<SellerStripeConnectResponse> connectStripe({
    required String tenantSlug,
    required String authToken,
  }) async {
    final api = ApiClient.create(tenantSlug: tenantSlug, authToken: authToken);

    final response = await api.dio.post(
      Endpoints.sellerStripeConnect,
      data: const <String, dynamic>{},
    );

    final data = response.data;
    if (data is! Map<String, dynamic> || data['data'] is! Map) {
      throw Exception('Invalid seller Stripe connect response');
    }

    return SellerStripeConnectResponse.fromJson(data);
  }

  Future<OnboardingStatus> refreshStripe({
    required String tenantSlug,
    required String authToken,
  }) async {
    final api = ApiClient.create(tenantSlug: tenantSlug, authToken: authToken);

    final response = await api.dio.post(
      Endpoints.sellerStripeRefresh,
      data: const <String, dynamic>{},
    );

    final data = response.data;
    if (data is! Map<String, dynamic> || data['data'] is! Map) {
      throw Exception('Invalid seller Stripe refresh response');
    }

    return OnboardingStatus.fromApiResponse(data);
  }
}
