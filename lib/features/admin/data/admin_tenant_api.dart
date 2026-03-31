import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';

class AdminTenantReviewDetail {
  final int tenantId;
  final String name;
  final String status;
  final String? verificationStatus;
  final bool? isActive;

  final Map<String, dynamic>? business;
  final Map<String, dynamic>? store;
  final Map<String, dynamic>? operations;
  final Map<String, dynamic>? catalog;
  final Map<String, dynamic>? payouts;
  final Map<String, dynamic>? documents;

  final String? submittedForReviewAt;
  final String? approvedAt;
  final String? rejectedAt;
  final String? rejectionReason;
  final String? reviewNotes;
  final List<String> reviewIssues;

  const AdminTenantReviewDetail({
    required this.tenantId,
    required this.name,
    required this.status,
    required this.verificationStatus,
    required this.isActive,
    required this.business,
    required this.store,
    required this.operations,
    required this.catalog,
    required this.payouts,
    required this.documents,
    required this.submittedForReviewAt,
    required this.approvedAt,
    required this.rejectedAt,
    required this.rejectionReason,
    required this.reviewNotes,
    required this.reviewIssues,
  });

  factory AdminTenantReviewDetail.fromJson(Map<String, dynamic> json) {
    return AdminTenantReviewDetail(
      tenantId: _asInt(json['tenant_id']) ?? _asInt(json['id']) ?? 0,
      name: (json['store']?['name'] ?? json['name'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      verificationStatus: json['verification_status']?.toString(),
      isActive: json['is_active'] is bool ? json['is_active'] as bool : null,
      business: json['business'] is Map<String, dynamic>
          ? json['business'] as Map<String, dynamic>
          : null,
      store: json['store'] is Map<String, dynamic>
          ? json['store'] as Map<String, dynamic>
          : null,
      operations: json['operations'] is Map<String, dynamic>
          ? json['operations'] as Map<String, dynamic>
          : null,
      catalog: json['catalog'] is Map<String, dynamic>
          ? json['catalog'] as Map<String, dynamic>
          : null,
      payouts: json['payouts'] is Map<String, dynamic>
          ? json['payouts'] as Map<String, dynamic>
          : null,
      documents: json['documents'] is Map<String, dynamic>
          ? json['documents'] as Map<String, dynamic>
          : null,
      submittedForReviewAt: json['submitted_for_review_at']?.toString(),
      approvedAt: json['approved_at']?.toString(),
      rejectedAt: json['rejected_at']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      reviewNotes: json['review_notes']?.toString(),
      reviewIssues: ((json['review_issues'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}

class AdminTenantApi {
  Future<Dio> _dio() async {
    final client = await ApiClient.create();
    return client.dio;
  }

  Exception _mapError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map && data['message'] != null) {
        return Exception(data['message'].toString());
      }

      return Exception(error.message ?? 'Admin request failed');
    }

    return Exception(error.toString().replaceFirst('Exception: ', ''));
  }

  Future<AdminTenantReviewDetail> fetchTenantReviewDetail(int tenantId) async {
    try {
      final dio = await _dio();
      final response = await dio.get('/v1/admin/tenants/$tenantId');
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final payload = data['data'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(data['data'] as Map)
            : data;

        return AdminTenantReviewDetail.fromJson(payload);
      }

      throw Exception('Invalid tenant review response');
    } catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> approveTenant(int tenantId) async {
    try {
      final dio = await _dio();
      await dio.post('/v1/admin/tenants/$tenantId/approve');
    } catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> rejectTenant({
    required int tenantId,
    required String reason,
    List<String> issues = const [],
    String? reviewNotes,
  }) async {
    try {
      final dio = await _dio();
      await dio.post(
        '/v1/admin/tenants/$tenantId/reject',
        data: {'reason': reason, 'issues': issues, 'review_notes': reviewNotes},
      );
    } catch (e) {
      throw _mapError(e);
    }
  }
}
