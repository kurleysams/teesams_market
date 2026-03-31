import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/seller_onboarding_provider.dart';

class SellerPendingReviewScreen extends StatelessWidget {
  const SellerPendingReviewScreen({super.key});

  String _prettyLabel(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((e) => e.trim().isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerOnboardingProvider>(
      builder: (context, provider, _) {
        final status = provider.status;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF8FAFC),
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text('Store review'),
          ),
          body: status == null && provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: provider.loadStatus,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      if (provider.error != null &&
                          provider.error!.trim().isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.20),
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            provider.error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x08000000),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.hourglass_top_rounded,
                                  size: 28,
                                  color: Color(0xFF1D4ED8),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Your store is under review',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'We have received your submission and we are reviewing your business details, documents, catalog readiness, and payout setup.',
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.45,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFBFDBFE),
                                ),
                              ),
                              child: Text(
                                'Status: ${status == null ? 'Pending Review' : _prettyLabel(status.status)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E40AF),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Typical review time: 1–3 business days.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (status != null)
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Submission summary',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 14),
                              _SummaryRow(
                                label: 'Store',
                                value: status.store.name ?? '—',
                              ),
                              _SummaryRow(
                                label: 'Slug',
                                value: status.store.slug ?? '—',
                              ),
                              _SummaryRow(
                                label: 'Business email',
                                value: status.business.businessEmail ?? '—',
                              ),
                              _SummaryRow(
                                label: 'Documents',
                                value: status.documents == null
                                    ? '—'
                                    : '${status.documents!.uploadedCount}/${status.documents!.totalCount} uploaded',
                              ),
                              _SummaryRow(
                                label: 'Catalog',
                                value: status.catalog == null
                                    ? '—'
                                    : '${status.catalog?.productCount ?? 0} products • ${status.catalog!.readyForReview ? 'Ready' : 'Not ready'}',
                              ),
                              _SummaryRow(
                                label: 'Payouts',
                                value: status.payouts == null
                                    ? '—'
                                    : '${status.payouts?.provider ?? '—'} • ${status.payouts!.setupComplete ? 'Complete' : 'Incomplete'}',
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (status != null)
                        ...status.steps.map(
                          (step) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: ListTile(
                              leading: Icon(
                                step.completed
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: step.completed
                                    ? Colors.green
                                    : const Color(0xFF6B7280),
                              ),
                              title: Text(
                                step.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              subtitle: const Text('Submitted'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/seller/onboarding/review',
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF374151)),
            ),
          ),
        ],
      ),
    );
  }
}
