class CatalogImportValidationResult {
  final int importId;
  final String type;
  final String mode;
  final String status;
  final String? originalFilename;
  final Map<String, dynamic> summary;
  final List<Map<String, dynamic>> errors;
  final List<Map<String, dynamic>> warnings;

  const CatalogImportValidationResult({
    required this.importId,
    required this.type,
    required this.mode,
    required this.status,
    required this.originalFilename,
    required this.summary,
    required this.errors,
    required this.warnings,
  });

  bool get canConfirm => status == 'validated';

  factory CatalogImportValidationResult.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['data'] as Map);

    return CatalogImportValidationResult(
      importId: data['import_id'] as int,
      type: data['type'] as String,
      mode: data['mode'] as String,
      status: data['status'] as String,
      originalFilename: data['original_filename'] as String?,
      summary: Map<String, dynamic>.from(data['summary'] ?? const {}),
      errors: ((data['errors'] ?? const []) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      warnings: ((data['warnings'] ?? const []) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
  }
}

class CatalogImportConfirmResult {
  final int importId;
  final String type;
  final String mode;
  final String status;
  final Map<String, dynamic> summary;
  final int rowsProcessed;
  final int rowsSuccess;
  final int rowsFailed;

  const CatalogImportConfirmResult({
    required this.importId,
    required this.type,
    required this.mode,
    required this.status,
    required this.summary,
    required this.rowsProcessed,
    required this.rowsSuccess,
    required this.rowsFailed,
  });

  factory CatalogImportConfirmResult.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['data'] as Map);

    return CatalogImportConfirmResult(
      importId: data['import_id'] as int,
      type: data['type'] as String,
      mode: data['mode'] as String,
      status: data['status'] as String,
      summary: Map<String, dynamic>.from(data['summary'] ?? const {}),
      rowsProcessed: (data['rows_processed'] ?? 0) as int,
      rowsSuccess: (data['rows_success'] ?? 0) as int,
      rowsFailed: (data['rows_failed'] ?? 0) as int,
    );
  }
}

class CatalogImportHistoryItem {
  final int id;
  final String type;
  final String mode;
  final String status;
  final String? originalFilename;
  final Map<String, dynamic> summary;
  final String? createdAt;
  final String? completedAt;

  const CatalogImportHistoryItem({
    required this.id,
    required this.type,
    required this.mode,
    required this.status,
    required this.originalFilename,
    required this.summary,
    required this.createdAt,
    required this.completedAt,
  });

  factory CatalogImportHistoryItem.fromJson(Map<String, dynamic> json) {
    return CatalogImportHistoryItem(
      id: json['id'] as int,
      type: json['type'] as String,
      mode: json['mode'] as String,
      status: json['status'] as String,
      originalFilename: json['original_filename'] as String?,
      summary: Map<String, dynamic>.from(json['summary'] ?? const {}),
      createdAt: json['created_at'] as String?,
      completedAt: json['completed_at'] as String?,
    );
  }
}

class CatalogImportHistoryDetail {
  final int id;
  final String type;
  final String mode;
  final String status;
  final String? originalFilename;
  final Map<String, dynamic> summary;
  final List<Map<String, dynamic>> errors;
  final List<Map<String, dynamic>> warnings;
  final Map<String, dynamic> options;
  final String? createdAt;
  final String? validatedAt;
  final String? completedAt;
  final String? cancelledAt;

  const CatalogImportHistoryDetail({
    required this.id,
    required this.type,
    required this.mode,
    required this.status,
    required this.originalFilename,
    required this.summary,
    required this.errors,
    required this.warnings,
    required this.options,
    required this.createdAt,
    required this.validatedAt,
    required this.completedAt,
    required this.cancelledAt,
  });

  bool get canCancel =>
      status == 'validated' ||
      status == 'pending_validation' ||
      status == 'failed';

  factory CatalogImportHistoryDetail.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['data'] as Map);

    return CatalogImportHistoryDetail(
      id: data['id'] as int,
      type: data['type'] as String,
      mode: data['mode'] as String,
      status: data['status'] as String,
      originalFilename: data['original_filename'] as String?,
      summary: Map<String, dynamic>.from(data['summary'] ?? const {}),
      errors: ((data['errors'] ?? const []) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      warnings: ((data['warnings'] ?? const []) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      options: Map<String, dynamic>.from(data['options'] ?? const {}),
      createdAt: data['created_at'] as String?,
      validatedAt: data['validated_at'] as String?,
      completedAt: data['completed_at'] as String?,
      cancelledAt: data['cancelled_at'] as String?,
    );
  }
}
