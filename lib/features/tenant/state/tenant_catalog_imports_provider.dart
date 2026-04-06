import 'dart:io';

import 'package:flutter/foundation.dart';

import '../data/tenant_catalog_imports_api.dart';
import '../models/catalog_import_models.dart';

class TenantCatalogImportsProvider extends ChangeNotifier {
  final TenantCatalogImportsApi api;

  TenantCatalogImportsProvider(this.api);

  bool _isDisposed = false;

  bool isLoading = false;
  String? errorMessage;

  CatalogImportValidationResult? lastValidation;
  CatalogImportConfirmResult? lastConfirm;
  CatalogImportHistoryDetail? selectedHistoryDetail;

  List<CatalogImportHistoryItem> history = const [];

  String? selectedType;
  String? selectedStatus;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<void> _fetchHistoryOnly() async {
    final response = await api.fetchImportHistory(
      type: selectedType,
      status: selectedStatus,
    );

    final data = (response['data'] as List)
        .map(
          (e) => CatalogImportHistoryItem.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();

    history = data;
  }

  Future<void> loadHistory() async {
    await _run(() async {
      await _fetchHistoryOnly();
    });
  }

  Future<void> setTypeFilter(String? value) async {
    selectedType = value;
    await loadHistory();
  }

  Future<void> setStatusFilter(String? value) async {
    selectedStatus = value;
    await loadHistory();
  }

  Future<void> clearFilters() async {
    selectedType = null;
    selectedStatus = null;
    await loadHistory();
  }

  Future<void> validateFullImport(File file) async {
    await _run(() async {
      final response = await api.validateFullImport(file: file);
      lastValidation = CatalogImportValidationResult.fromJson(response);
      lastConfirm = null;
    });
  }

  Future<void> confirmFullImport() async {
    final validation = lastValidation;
    if (validation == null) return;

    await _run(() async {
      final response = await api.confirmFullImport(
        importId: validation.importId,
      );
      lastConfirm = CatalogImportConfirmResult.fromJson(response);
      await _fetchHistoryOnly();
    });
  }

  Future<void> validateBulkUpdate(File file) async {
    await _run(() async {
      final response = await api.validateBulkUpdate(file: file);
      lastValidation = CatalogImportValidationResult.fromJson(response);
      lastConfirm = null;
    });
  }

  Future<void> confirmBulkUpdate() async {
    final validation = lastValidation;
    if (validation == null) return;

    await _run(() async {
      final response = await api.confirmBulkUpdate(
        importId: validation.importId,
      );
      lastConfirm = CatalogImportConfirmResult.fromJson(response);
      await _fetchHistoryOnly();
    });
  }

  Future<void> revalidateImport({
    required File file,
    required int replacesImportId,
    required String type,
    required String mode,
  }) async {
    await _run(() async {
      final response = await api.revalidateImport(
        file: file,
        replacesImportId: replacesImportId,
        type: type,
        mode: mode,
      );

      lastValidation = CatalogImportValidationResult.fromJson(response);
      lastConfirm = null;
      await _fetchHistoryOnly();
    });
  }

  Future<void> loadHistoryDetail(int importId) async {
    await _run(() async {
      final response = await api.fetchImportHistoryItem(importId);
      selectedHistoryDetail = CatalogImportHistoryDetail.fromJson(response);
    });
  }

  Future<void> cancelImport(int importId) async {
    await _run(() async {
      await api.cancelImport(importId);
      await _fetchHistoryOnly();
    });
  }

  Future<void> downloadTemplate({
    required String mode,
    required String savePath,
  }) async {
    await _run(() async {
      await api.downloadImportTemplate(mode: mode, savePath: savePath);
    });
  }

  Future<void> downloadExport({
    required String mode,
    required String savePath,
  }) async {
    await _run(() async {
      await api.exportCatalog(mode: mode, savePath: savePath);
    });
  }

  Future<void> downloadIssuesCsv({
    required int importId,
    required String savePath,
  }) async {
    await _run(() async {
      await api.downloadImportIssues(importId: importId, savePath: savePath);
    });
  }

  void clearSelectedHistoryDetail() {
    selectedHistoryDetail = null;
    _safeNotify();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_isDisposed) return;

    isLoading = true;
    errorMessage = null;
    _safeNotify();

    try {
      await action();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      if (_isDisposed) return;
      isLoading = false;
      _safeNotify();
    }
  }
}
