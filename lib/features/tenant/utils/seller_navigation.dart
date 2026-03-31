import 'package:flutter/material.dart';

class SellerNavigation {
  static Future<void> goFromStatus(
    BuildContext context, {
    required String? status,
    required bool isActive,
  }) async {
    if (isActive || status == 'active' || status == 'approved') {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/seller/approved',
        (route) => false,
      );
      return;
    }

    if (status == 'pending_review') {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/seller/pending-review',
        (route) => false,
      );
      return;
    }

    if (status == 'rejected') {
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
