class SellerOnboardingStatus {
  final int tenantId;
  final String status;
  final String verificationStatus;
  final bool isActive;
  final List<OnboardingStep> steps;
  final bool canSubmitForReview;
  final List<String> missingRequirements;
  final SellerPayouts payouts;

  const SellerOnboardingStatus({
    required this.tenantId,
    required this.status,
    required this.verificationStatus,
    required this.isActive,
    required this.steps,
    required this.canSubmitForReview,
    required this.missingRequirements,
    required this.payouts,
  });

  factory SellerOnboardingStatus.fromJson(Map<String, dynamic> json) {
    return SellerOnboardingStatus(
      tenantId: (json['tenant_id'] as num?)?.toInt() ?? 0,
      status: (json['status'] ?? '').toString(),
      verificationStatus: (json['verification_status'] ?? '').toString(),
      isActive: json['is_active'] == true,
      steps: ((json['steps'] as List?) ?? const [])
          .map(
            (e) => OnboardingStep.fromJson((e as Map).cast<String, dynamic>()),
          )
          .toList(),
      canSubmitForReview: json['can_submit_for_review'] == true,
      missingRequirements: ((json['missing_requirements'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      payouts: SellerPayouts.fromJson(
        ((json['payouts'] as Map?) ?? const {}).cast<String, dynamic>(),
      ),
    );
  }
}

class OnboardingStep {
  final String key;
  final String label;
  final bool completed;
  final bool requiredStep;

  const OnboardingStep({
    required this.key,
    required this.label,
    required this.completed,
    required this.requiredStep,
  });

  factory OnboardingStep.fromJson(Map<String, dynamic> json) {
    return OnboardingStep(
      key: (json['key'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      completed: json['completed'] == true,
      requiredStep: json['required'] == true,
    );
  }
}

class SellerPayouts {
  final String? provider;
  final bool setupComplete;
  final String? accountReference;
  final SellerStripeDetails stripe;

  const SellerPayouts({
    required this.provider,
    required this.setupComplete,
    required this.accountReference,
    required this.stripe,
  });

  factory SellerPayouts.fromJson(Map<String, dynamic> json) {
    return SellerPayouts(
      provider: json['provider']?.toString(),
      setupComplete: json['setup_complete'] == true,
      accountReference: json['account_reference']?.toString(),
      stripe: SellerStripeDetails.fromJson(
        ((json['stripe'] as Map?) ?? const {}).cast<String, dynamic>(),
      ),
    );
  }
}

class SellerStripeDetails {
  final bool hasAccount;
  final String? accountId;
  final String? accountType;
  final bool detailsSubmitted;
  final bool chargesEnabled;
  final bool payoutsEnabled;
  final String? onboardingStatus;
  final List<String> requirementsCurrentlyDue;
  final List<String> requirementsEventuallyDue;
  final String? requirementsDisabledReason;
  final String? onboardedAt;

  const SellerStripeDetails({
    required this.hasAccount,
    required this.accountId,
    required this.accountType,
    required this.detailsSubmitted,
    required this.chargesEnabled,
    required this.payoutsEnabled,
    required this.onboardingStatus,
    required this.requirementsCurrentlyDue,
    required this.requirementsEventuallyDue,
    required this.requirementsDisabledReason,
    required this.onboardedAt,
  });

  factory SellerStripeDetails.fromJson(Map<String, dynamic> json) {
    return SellerStripeDetails(
      hasAccount: json['has_account'] == true,
      accountId: json['account_id']?.toString(),
      accountType: json['account_type']?.toString(),
      detailsSubmitted: json['details_submitted'] == true,
      chargesEnabled: json['charges_enabled'] == true,
      payoutsEnabled: json['payouts_enabled'] == true,
      onboardingStatus: json['onboarding_status']?.toString(),
      requirementsCurrentlyDue:
          ((json['requirements_currently_due'] as List?) ?? const [])
              .map((e) => e.toString())
              .toList(),
      requirementsEventuallyDue:
          ((json['requirements_eventually_due'] as List?) ?? const [])
              .map((e) => e.toString())
              .toList(),
      requirementsDisabledReason: json['requirements_disabled_reason']
          ?.toString(),
      onboardedAt: json['onboarded_at']?.toString(),
    );
  }

  bool get isReady => hasAccount && chargesEnabled && payoutsEnabled;
  bool get isPending => hasAccount && !isReady;
}
