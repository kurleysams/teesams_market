import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../models/tenant_onboarding_status.dart';
import '../models/tenant_save_business_details.dart';
import '../models/tenant_save_catalog_setup.dart';
import '../models/tenant_save_operations.dart';
import '../models/tenant_save_payouts.dart';
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

  Future<SellerOnboardingRepository> _repository() async {
    final apiClient = await ApiClient.create(
      authToken: sellerAuthProvider.token,
    );
    return SellerOnboardingRepository(apiClient);
  }

  Future<void> loadStatus() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final repository = await _repository();
      status = await repository.getStatus();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
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
      error = e.toString().replaceFirst('Exception: ', '');
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
      error = e.toString().replaceFirst('Exception: ', '');
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
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> savePayouts(SavePayoutsRequest request) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final repository = await _repository();
      status = await repository.savePayouts(request);
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
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
      error = e.toString().replaceFirst('Exception: ', '');
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
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitForReview() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final repository = await _repository();
      status = await repository.submitForReview();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
