import 'package:flutter/material.dart';

import '../models/tenant_onboarding_status.dart';

class SellerStatusNavigation {
  static Future<void> goFromStatus(
    BuildContext context, {
    required OnboardingStatus status,
  }) async {
    if (status.isApproved) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/seller/approved',
        (route) => false,
      );
      return;
    }

    if (status.isPendingReview) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/seller/pending-review',
        (route) => false,
      );
      return;
    }

    if (status.isRejected) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/seller/rejected',
        (route) => false,
      );
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/seller/onboarding',
      (route) => false,
    );
  }
}
