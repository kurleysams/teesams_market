class OnboardingStatus {
  final int tenantId;
  final String status;
  final String verificationStatus;
  final bool isActive;

  final String? submittedForReviewAt;
  final String? approvedAt;
  final String? rejectedAt;
  final String? rejectionReason;
  final String? reviewNotes;
  final List<String> reviewIssues;

  final List<OnboardingStep> steps;
  final bool canSubmitForReview;
  final List<String> missingRequirements;
  final BusinessDetails business;
  final StoreDetails store;
  final SellerDocumentsSummary? documents;
  final CatalogDetails? catalog;
  final PayoutDetails? payouts;

  OnboardingStatus({
    required this.tenantId,
    required this.status,
    required this.verificationStatus,
    required this.isActive,
    required this.submittedForReviewAt,
    required this.approvedAt,
    required this.rejectedAt,
    required this.rejectionReason,
    required this.reviewNotes,
    required this.reviewIssues,
    required this.steps,
    required this.canSubmitForReview,
    required this.missingRequirements,
    required this.business,
    required this.store,
    required this.documents,
    required this.catalog,
    required this.payouts,
  });

  bool get isPendingReview => status == 'pending_review';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isInProgress =>
      status == 'draft' || status == 'onboarding_in_progress';

  factory OnboardingStatus.fromApiResponse(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    return OnboardingStatus(
      tenantId: data['tenant_id'] as int,
      status: data['status'] as String,
      verificationStatus: data['verification_status'] as String,
      isActive: data['is_active'] as bool,
      submittedForReviewAt: data['submitted_for_review_at'] as String?,
      approvedAt: data['approved_at'] as String?,
      rejectedAt: data['rejected_at'] as String?,
      rejectionReason: data['rejection_reason'] as String?,
      reviewNotes: data['review_notes'] as String?,
      reviewIssues: ((data['review_issues'] as List<dynamic>?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      steps: (data['steps'] as List<dynamic>)
          .map((e) => OnboardingStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      canSubmitForReview: data['can_submit_for_review'] as bool,
      missingRequirements: (data['missing_requirements'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      business: BusinessDetails.fromJson(
        data['business'] as Map<String, dynamic>,
      ),
      store: StoreDetails.fromJson(data['store'] as Map<String, dynamic>),
      documents: data['documents'] != null
          ? SellerDocumentsSummary.fromJson(
              data['documents'] as Map<String, dynamic>,
            )
          : null,
      catalog: data['catalog'] != null
          ? CatalogDetails.fromJson(data['catalog'] as Map<String, dynamic>)
          : null,
      payouts: data['payouts'] != null
          ? PayoutDetails.fromJson(data['payouts'] as Map<String, dynamic>)
          : null,
    );
  }
}

class OnboardingStep {
  final String key;
  final String label;
  final bool completed;
  final bool requiredStep;

  OnboardingStep({
    required this.key,
    required this.label,
    required this.completed,
    required this.requiredStep,
  });

  factory OnboardingStep.fromJson(Map<String, dynamic> json) {
    return OnboardingStep(
      key: json['key'] as String,
      label: json['label'] as String,
      completed: json['completed'] as bool,
      requiredStep: json['required'] as bool,
    );
  }
}

class BusinessDetails {
  final String? legalName;
  final String? businessEmail;
  final String? businessPhone;
  final String? businessType;
  final String? registrationNumber;
  final String? taxNumber;

  BusinessDetails({
    this.legalName,
    this.businessEmail,
    this.businessPhone,
    this.businessType,
    this.registrationNumber,
    this.taxNumber,
  });

  factory BusinessDetails.fromJson(Map<String, dynamic> json) {
    return BusinessDetails(
      legalName: json['legal_name'] as String?,
      businessEmail: json['business_email'] as String?,
      businessPhone: json['business_phone'] as String?,
      businessType: json['business_type'] as String?,
      registrationNumber: json['registration_number'] as String?,
      taxNumber: json['tax_number'] as String?,
    );
  }
}

class StoreDetails {
  final String? name;
  final String? slug;
  final String? tagline;
  final String? logoUrl;
  final String? bannerUrl;
  final String? primaryColor;
  final String? city;
  final String? country;
  final String? addressLine1;

  StoreDetails({
    this.name,
    this.slug,
    this.tagline,
    this.logoUrl,
    this.bannerUrl,
    this.primaryColor,
    this.city,
    this.country,
    this.addressLine1,
  });

  factory StoreDetails.fromJson(Map<String, dynamic> json) {
    return StoreDetails(
      name: json['name'] as String?,
      slug: json['slug'] as String?,
      tagline: json['tagline'] as String?,
      logoUrl: json['logo_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      primaryColor: json['primary_color'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      addressLine1: json['address_line_1'] as String?,
    );
  }
}

class SellerDocumentsSummary {
  final List<SellerDocumentItem> requiredDocuments;

  SellerDocumentsSummary({required this.requiredDocuments});

  factory SellerDocumentsSummary.fromJson(Map<String, dynamic> json) {
    return SellerDocumentsSummary(
      requiredDocuments: ((json['required'] as List<dynamic>? ?? const []))
          .map((e) => SellerDocumentItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  int get uploadedCount => requiredDocuments.where((e) => e.uploaded).length;

  int get totalCount => requiredDocuments.length;
}

class SellerDocumentItem {
  final String type;
  final String label;
  final bool uploaded;
  final String status;
  final String? fileName;
  final String? uploadedAt;

  SellerDocumentItem({
    required this.type,
    required this.label,
    required this.uploaded,
    required this.status,
    this.fileName,
    this.uploadedAt,
  });

  factory SellerDocumentItem.fromJson(Map<String, dynamic> json) {
    return SellerDocumentItem(
      type: json['type'] as String,
      label: json['label'] as String,
      uploaded: json['uploaded'] as bool,
      status: json['status'] as String,
      fileName: json['file_name'] as String?,
      uploadedAt: json['uploaded_at'] as String?,
    );
  }
}

class CatalogDetails {
  final int? productCount;
  final bool readyForReview;

  CatalogDetails({this.productCount, required this.readyForReview});

  factory CatalogDetails.fromJson(Map<String, dynamic> json) {
    return CatalogDetails(
      productCount: json['product_count'] as int?,
      readyForReview: json['ready_for_review'] as bool? ?? false,
    );
  }
}

class PayoutDetails {
  final String? provider;
  final bool setupComplete;
  final String? accountReference;

  PayoutDetails({
    this.provider,
    required this.setupComplete,
    this.accountReference,
  });

  factory PayoutDetails.fromJson(Map<String, dynamic> json) {
    return PayoutDetails(
      provider: json['provider'] as String?,
      setupComplete: json['setup_complete'] as bool? ?? false,
      accountReference: json['account_reference'] as String?,
    );
  }
}
