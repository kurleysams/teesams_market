import 'package:dio/dio.dart';

import '../../../core/api/endpoints.dart';

class AdminTenantApi {
  final Dio dio;

  AdminTenantApi(this.dio);

  Future<AdminTenantReviewDetail> fetchTenantReviewDetail(int tenantId) async {
    final response = await dio.get(Endpoints.adminTenantReview(tenantId));
    final data = Map<String, dynamic>.from(response.data['data'] as Map);
    return AdminTenantReviewDetail.fromJson(data);
  }

  Future<void> approveTenant(int tenantId) async {
    await dio.post(Endpoints.adminTenantApprove(tenantId));
  }

  Future<void> rejectTenant({
    required int tenantId,
    required String reason,
    required List<String> issues,
    String? reviewNotes,
  }) async {
    await dio.post(
      Endpoints.adminTenantReject(tenantId),
      data: {
        'reason': reason,
        'issues': issues,
        if (reviewNotes != null && reviewNotes.trim().isNotEmpty)
          'review_notes': reviewNotes.trim(),
      },
    );
  }
}

class AdminTenantReviewDetail {
  final String name;
  final String status;
  final String? submittedForReviewAt;
  final String? approvedAt;
  final String? rejectedAt;
  final Map<String, dynamic>? business;
  final Map<String, dynamic>? store;
  final Map<String, dynamic>? operations;
  final Map<String, dynamic>? documents;
  final Map<String, dynamic>? catalog;
  final Map<String, dynamic>? payouts;
  final String? rejectionReason;
  final String? reviewNotes;
  final List<String> reviewIssues;

  const AdminTenantReviewDetail({
    required this.name,
    required this.status,
    this.submittedForReviewAt,
    this.approvedAt,
    this.rejectedAt,
    this.business,
    this.store,
    this.operations,
    this.documents,
    this.catalog,
    this.payouts,
    this.rejectionReason,
    this.reviewNotes,
    this.reviewIssues = const [],
  });

  factory AdminTenantReviewDetail.fromJson(Map<String, dynamic> json) {
    return AdminTenantReviewDetail(
      name: (json['name'] ?? '') as String,
      status: (json['status'] ?? 'pending_review') as String,
      submittedForReviewAt: json['submitted_for_review_at'] as String?,
      approvedAt: json['approved_at'] as String?,
      rejectedAt: json['rejected_at'] as String?,
      business: json['business'] == null
          ? null
          : Map<String, dynamic>.from(json['business'] as Map),
      store: json['store'] == null
          ? null
          : Map<String, dynamic>.from(json['store'] as Map),
      operations: json['operations'] == null
          ? null
          : Map<String, dynamic>.from(json['operations'] as Map),
      documents: json['documents'] == null
          ? null
          : Map<String, dynamic>.from(json['documents'] as Map),
      catalog: json['catalog'] == null
          ? null
          : Map<String, dynamic>.from(json['catalog'] as Map),
      payouts: json['payouts'] == null
          ? null
          : Map<String, dynamic>.from(json['payouts'] as Map),
      rejectionReason: json['rejection_reason'] as String?,
      reviewNotes: json['review_notes'] as String?,
      reviewIssues: (json['review_issues'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
