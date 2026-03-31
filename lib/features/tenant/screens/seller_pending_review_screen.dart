import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/seller_onboarding_provider.dart';

class SellerPendingReviewScreen extends StatelessWidget {
  const SellerPendingReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerOnboardingProvider>(
      builder: (context, provider, _) {
        final status = provider.status;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(title: const Text('Review in progress')),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: provider.loadStatus,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.hourglass_top_rounded,
                          size: 60,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Your store is under review',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'We are reviewing your business information and setup. You will be able to continue once the review is complete.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF6B7280),
                            height: 1.4,
                          ),
                        ),
                        if (status?.store.name?.trim().isNotEmpty == true) ...[
                          const SizedBox(height: 14),
                          Text(
                            status!.store.name!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: provider.isLoading
                          ? null
                          : () async {
                              await provider.loadStatus();
                              if (!context.mounted) return;
                              _routeFromStatus(
                                context,
                                provider.status?.status,
                              );
                            },
                      child: provider.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Refresh status'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _routeFromStatus(BuildContext context, String? status) {
    switch (status) {
      case 'approved':
      case 'active':
        Navigator.pushReplacementNamed(context, '/seller/approved');
        break;
      case 'rejected':
        Navigator.pushReplacementNamed(context, '/seller/rejected');
        break;
      case 'pending_review':
        break;
      default:
        Navigator.pushReplacementNamed(context, '/seller/onboarding');
    }
  }
}
