import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../models/tenant_onboarding_status.dart';
import '../models/tenant_save_business_details.dart';
import '../models/tenant_save_catalog_setup.dart';
import '../models/tenant_save_operations.dart';
import '../models/tenant_save_payouts.dart';
import '../models/tenant_save_store_profile.dart';
import '../models/tenant_upload_document.dart';

class SellerOnboardingRepository {
  final ApiClient apiClient;

  SellerOnboardingRepository(this.apiClient);

  Future<OnboardingStatus> getStatus() async {
    final response = await apiClient.dio.get(Endpoints.sellerOnboardingStatus);
    return OnboardingStatus.fromApiResponse(response.data);
  }

  Future<OnboardingStatus> saveBusinessDetails(
    SaveBusinessDetailsRequest request,
  ) async {
    final response = await apiClient.dio.patch(
      Endpoints.sellerBusinessDetails,
      data: request.toJson(),
    );

    return OnboardingStatus.fromApiResponse(response.data);
  }

  Future<OnboardingStatus> saveStoreProfile(
    SaveStoreProfileRequest request,
  ) async {
    final response = await apiClient.dio.patch(
      Endpoints.sellerStoreProfile,
      data: request.toJson(),
    );

    return OnboardingStatus.fromApiResponse(response.data);
  }

  Future<OnboardingStatus> saveOperations(SaveOperationsRequest request) async {
    final response = await apiClient.dio.patch(
      Endpoints.sellerOperations,
      data: request.toJson(),
    );

    return OnboardingStatus.fromApiResponse(response.data);
  }

  Future<OnboardingStatus> savePayouts(SavePayoutsRequest request) async {
    final response = await apiClient.dio.patch(
      Endpoints.sellerPayoutSetup,
      data: request.toJson(),
    );

    return OnboardingStatus.fromApiResponse(response.data);
  }

  Future<OnboardingStatus> saveCatalogSetup(
    SaveCatalogSetupRequest request,
  ) async {
    final response = await apiClient.dio.patch(
      Endpoints.sellerCatalogSetup,
      data: request.toJson(),
    );

    return OnboardingStatus.fromApiResponse(response.data);
  }

  Future<OnboardingStatus> uploadDocument(
    UploadSellerDocumentRequest request,
  ) async {
    final formData = FormData.fromMap({
      'document_type': request.documentType,
      'file': await MultipartFile.fromFile(
        request.filePath,
        filename: request.fileName,
      ),
    });

    final response = await apiClient.dio.post(
      Endpoints.sellerDocuments,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return OnboardingStatus.fromApiResponse(response.data);
  }

  Future<OnboardingStatus> submitForReview() async {
    final response = await apiClient.dio.post(
      Endpoints.sellerSubmitForReview,
      data: {'confirm_terms': true},
    );

    return OnboardingStatus.fromApiResponse(response.data);
  }
}
