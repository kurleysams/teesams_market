import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../models/tenant_onboarding_status.dart';
import '../models/tenant_save_business_details.dart';
import '../models/tenant_save_catalog_setup.dart';
import '../models/tenant_save_operations.dart';
import '../models/tenant_save_store_profile.dart';
import '../models/tenant_upload_document.dart';
import '../services/seller_onboarding_repository.dart';
import 'seller_auth_provider.dart';

class SellerOnboardingProvider extends ChangeNotifier {
  final SellerAuthProvider sellerAuthProvider;

  SellerOnboardingProvider(this.sellerAuthProvider);

  OnboardingStatus? status;
  bool isLoading = false;
  String? error;
  String? stripeOnboardingUrl;

  Future<SellerOnboardingRepository> _repository() async {
    final apiClient = ApiClient.create(authToken: sellerAuthProvider.token);
    return SellerOnboardingRepository(apiClient);
  }

  String _friendlyError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;

      if (data is Map) {
        final message = data['message']?.toString().trim();
        final errors = data['errors'];

        if (errors is Map) {
          final missing = errors['missing_requirements'];

          if (message != null && message.isNotEmpty) {
            if (missing is List && missing.isNotEmpty) {
              final labels = missing
                  .map((x) => _prettyRequirement(x.toString()))
                  .join(', ');
              return '$message Missing: $labels.';
            }

            return message;
          }

          for (final value in errors.values) {
            if (value is List && value.isNotEmpty) {
              return value.first.toString();
            }
          }
        }

        if (message != null && message.isNotEmpty) {
          return message;
        }
      }

      return 'Request failed. Please try again.';
    }

    return e.toString().replaceFirst('Exception: ', '');
  }

  String _prettyRequirement(String value) {
    switch (value) {
      case 'business_details':
        return 'Business details';
      case 'store_profile':
        return 'Store profile';
      case 'operations':
        return 'Store operations';
      case 'catalog_setup':
        return 'Catalog setup';
      case 'payout_setup':
        return 'Stripe approval';
      default:
        return value.replaceAll('_', ' ');
    }
  }

  Future<void> loadStatus() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final repository = await _repository();
      status = await repository.getStatus();
    } catch (e) {
      error = _friendlyError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loadStripeStatus() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final repository = await _repository();
      status = await repository.getStripeStatus();
      return true;
    } catch (e) {
      error = _friendlyError(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> connectStripe() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final repository = await _repository();
      final result = await repository.connectStripe();
      status = result.status;
      stripeOnboardingUrl = result.url;
      return result.url;
    } catch (e) {
      error = _friendlyError(e);
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> refreshStripe() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final repository = await _repository();
      status = await repository.refreshStripe();
      return true;
    } catch (e) {
      error = _friendlyError(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveBusinessDetails(SaveBusinessDetailsRequest request) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final repository = await _repository();
      status = await repository.saveBusinessDetails(request);
      return true;
    } catch (e) {
      error = _friendlyError(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveStoreProfile(SaveStoreProfileRequest request) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final repository = await _repository();
      status = await repository.saveStoreProfile(request);
      return true;
    } catch (e) {
      error = _friendlyError(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveOperations(SaveOperationsRequest request) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final repository = await _repository();
      status = await repository.saveOperations(request);
      return true;
    } catch (e) {
      error = _friendlyError(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveCatalogSetup(SaveCatalogSetupRequest request) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final repository = await _repository();
      status = await repository.saveCatalogSetup(request);
      return true;
    } catch (e) {
      error = _friendlyError(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadDocument(UploadSellerDocumentRequest request) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final repository = await _repository();
      status = await repository.uploadDocument(request);
      return true;
    } catch (e) {
      error = _friendlyError(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitForReview({required bool confirmTerms}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final repository = await _repository();

      status = await repository.refreshStripe();
      status = await repository.submitForReview(confirmTerms: confirmTerms);

      return true;
    } catch (e) {
      error = _friendlyError(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}
