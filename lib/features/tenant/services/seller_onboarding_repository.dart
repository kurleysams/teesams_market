import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../models/tenant_onboarding_status.dart';
import '../models/tenant_save_business_details.dart';
import '../models/tenant_save_catalog_setup.dart';
import '../models/tenant_save_operations.dart';
import '../models/tenant_save_store_profile.dart';
import '../models/tenant_upload_document.dart';

class SellerStripeConnectResult {
  final String? url;
  final int? expiresAt;
  final OnboardingStatus status;

  const SellerStripeConnectResult({
    required this.url,
    required this.expiresAt,
    required this.status,
  });

  factory SellerStripeConnectResult.fromJson(Map<String, dynamic> json) {
    return SellerStripeConnectResult(
      url: json['url']?.toString(),
      expiresAt: (json['expires_at'] as num?)?.toInt(),
      status: OnboardingStatus.fromApiResponse(json),
    );
  }
}

class SellerOnboardingRepository {
  final ApiClient apiClient;

  SellerOnboardingRepository(this.apiClient);

  Future<OnboardingStatus> getStatus() async {
    final response = await apiClient.dio.get(Endpoints.sellerOnboardingStatus);
    final data = response.data;

    if (data is! Map<String, dynamic> || data['data'] is! Map) {
      throw Exception('Invalid onboarding status response');
    }

    return OnboardingStatus.fromApiResponse(data);
  }

  Future<OnboardingStatus> getStripeStatus() async {
    final response = await apiClient.dio.get(Endpoints.sellerStripeStatus);
    final data = response.data;

    if (data is! Map<String, dynamic> || data['data'] is! Map) {
      throw Exception('Invalid Stripe status response');
    }

    return OnboardingStatus.fromApiResponse(data);
  }

  Future<SellerStripeConnectResult> connectStripe() async {
    final response = await apiClient.dio.post(
      Endpoints.sellerStripeConnect,
      data: const <String, dynamic>{},
    );

    final data = response.data;
    if (data is! Map<String, dynamic> || data['data'] is! Map) {
      throw Exception('Invalid Stripe connect response');
    }

    return SellerStripeConnectResult.fromJson(data);
  }

  Future<OnboardingStatus> refreshStripe() async {
    final response = await apiClient.dio.post(
      Endpoints.sellerStripeRefresh,
      data: const <String, dynamic>{},
    );

    final data = response.data;
    if (data is! Map<String, dynamic> || data['data'] is! Map) {
      throw Exception('Invalid Stripe refresh response');
    }

    return OnboardingStatus.fromApiResponse(data);
  }

  Future<OnboardingStatus> saveBusinessDetails(
    SaveBusinessDetailsRequest request,
  ) async {
    final response = await apiClient.dio.patch(
      Endpoints.sellerBusinessDetails,
      data: request.toJson(),
    );

    final data = response.data;
    if (data is! Map<String, dynamic> || data['data'] is! Map) {
      throw Exception('Invalid business details response');
    }

    return OnboardingStatus.fromApiResponse(data);
  }

  Future<OnboardingStatus> saveStoreProfile(
    SaveStoreProfileRequest request,
  ) async {
    final response = await apiClient.dio.patch(
      Endpoints.sellerStoreProfile,
      data: request.toJson(),
    );

    final data = response.data;
    if (data is! Map<String, dynamic> || data['data'] is! Map) {
      throw Exception('Invalid store profile response');
    }

    return OnboardingStatus.fromApiResponse(data);
  }

  Future<OnboardingStatus> saveOperations(SaveOperationsRequest request) async {
    final response = await apiClient.dio.patch(
      Endpoints.sellerOperations,
      data: request.toJson(),
    );

    final data = response.data;
    if (data is! Map<String, dynamic> || data['data'] is! Map) {
      throw Exception('Invalid operations response');
    }

    return OnboardingStatus.fromApiResponse(data);
  }

  Future<OnboardingStatus> saveCatalogSetup(
    SaveCatalogSetupRequest request,
  ) async {
    final response = await apiClient.dio.patch(
      Endpoints.sellerCatalogSetup,
      data: request.toJson(),
    );

    final data = response.data;
    if (data is! Map<String, dynamic> || data['data'] is! Map) {
      throw Exception('Invalid catalog setup response');
    }

    return OnboardingStatus.fromApiResponse(data);
  }

  Future<OnboardingStatus> uploadDocument(
    UploadSellerDocumentRequest request,
  ) async {
    final formData = await request.toFormData();

    final response = await apiClient.dio.post(
      Endpoints.sellerDocuments,
      data: formData,
    );

    final data = response.data;
    if (data is! Map<String, dynamic> || data['data'] is! Map) {
      throw Exception('Invalid document upload response');
    }

    return OnboardingStatus.fromApiResponse(data);
  }

  Future<OnboardingStatus> submitForReview({required bool confirmTerms}) async {
    final response = await apiClient.dio.post(
      Endpoints.sellerSubmitForReview,
      data: {'confirm_terms': confirmTerms},
    );

    final data = response.data;
    if (data is! Map<String, dynamic> || data['data'] is! Map) {
      throw Exception('Invalid submit for review response');
    }

    return OnboardingStatus.fromApiResponse(data);
  }
}
