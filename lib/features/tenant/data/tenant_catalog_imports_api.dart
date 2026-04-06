import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/api/endpoints.dart';

class TenantCatalogImportsApi {
  final Dio dio;

  TenantCatalogImportsApi(this.dio);

  Future<void> downloadImportTemplate({
    required String mode,
    required String savePath,
  }) async {
    await dio.download(
      Endpoints.sellerCatalogImportTemplate,
      savePath,
      queryParameters: {'mode': mode},
    );
  }

  Future<void> exportCatalog({
    required String mode,
    required String savePath,
  }) async {
    await dio.download(
      Endpoints.sellerCatalogExport,
      savePath,
      queryParameters: {'mode': mode},
    );
  }

  Future<Map<String, dynamic>> validateFullImport({
    required File file,
    bool upsertExistingVariants = true,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
      'mode': 'full',
      'upsert_existing_variants': upsertExistingVariants,
    });

    final response = await dio.post(
      Endpoints.sellerCatalogImportValidate,
      data: formData,
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> confirmFullImport({
    required int importId,
  }) async {
    final response = await dio.post(
      Endpoints.sellerCatalogImportConfirm,
      data: {'import_id': importId},
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> validateBulkUpdate({required File file}) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
    });

    final response = await dio.post(
      Endpoints.sellerCatalogBulkUpdateValidate,
      data: formData,
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> confirmBulkUpdate({
    required int importId,
  }) async {
    final response = await dio.post(
      Endpoints.sellerCatalogBulkUpdateConfirm,
      data: {'import_id': importId},
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> revalidateImport({
    required File file,
    required int replacesImportId,
    required String type,
    required String mode,
    bool upsertExistingVariants = true,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
      'replaces_import_id': replacesImportId,
      'type': type,
      'mode': mode,
      'upsert_existing_variants': upsertExistingVariants,
    });

    final response = await dio.post(
      Endpoints.sellerCatalogImportRevalidate,
      data: formData,
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> fetchImportHistory({
    String? type,
    String? mode,
    String? status,
    int perPage = 20,
  }) async {
    final response = await dio.get(
      Endpoints.sellerCatalogImportHistory,
      queryParameters: {
        if (type != null) 'type': type,
        if (mode != null) 'mode': mode,
        if (status != null) 'status': status,
        'per_page': perPage,
      },
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> fetchImportHistoryItem(int importId) async {
    final response = await dio.get(
      Endpoints.sellerCatalogImportHistoryItem(importId),
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> cancelImport(int importId) async {
    final response = await dio.post(
      Endpoints.sellerCatalogImportCancel(importId),
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> downloadImportIssues({
    required int importId,
    required String savePath,
  }) async {
    await dio.download(
      Endpoints.sellerCatalogImportErrorsCsv(importId),
      savePath,
    );
  }
}
