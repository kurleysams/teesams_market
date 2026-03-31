import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tenant_onboarding_status.dart';
import '../state/seller_onboarding_provider.dart';

class SellerReviewScreen extends StatelessWidget {
  const SellerReviewScreen({super.key});

  void _openStep(BuildContext context, String key) {
    switch (key) {
      case 'business_details':
        Navigator.pushNamed(context, '/seller/onboarding/business');
        break;
      case 'store_profile':
        Navigator.pushNamed(context, '/seller/onboarding/store-profile');
        break;
      case 'operations':
        Navigator.pushNamed(context, '/seller/onboarding/operations');
        break;
      case 'documents':
        Navigator.pushNamed(context, '/seller/onboarding/documents');
        break;
      case 'payout_setup':
        Navigator.pushNamed(context, '/seller/onboarding/payouts');
        break;
      case 'catalog_setup':
        Navigator.pushNamed(context, '/seller/onboarding/catalog');
        break;
      default:
        break;
    }
  }

  String _prettyLabel(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((e) => e.trim().isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  Color _documentStatusColor(String status) {
    switch (status) {
      case 'uploaded':
      case 'approved':
        return Colors.green;
      case 'under_review':
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return const Color(0xFF6B7280);
    }
  }

  List<OnboardingStep> _uniqueSteps(List<OnboardingStep> steps) {
    final seen = <String>{};
    final result = <OnboardingStep>[];

    for (final step in steps) {
      if (seen.add(step.key)) {
        result.add(step);
      }
    }

    return result;
  }

  List<String> _uniqueMissing(List<String> missingRequirements) {
    final seen = <String>{};
    final result = <String>[];

    for (final item in missingRequirements) {
      if (seen.add(item)) {
        result.add(item);
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerOnboardingProvider>(
      builder: (context, provider, _) {
        final status = provider.status;
        final uniqueSteps = status == null
            ? const <OnboardingStep>[]
            : _uniqueSteps(status.steps);
        final uniqueMissing = status == null
            ? const <String>[]
            : _uniqueMissing(status.missingRequirements);

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF8FAFC),
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text('Review setup'),
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
                      if (status == null)
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: const Text(
                            'Unable to load review data.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        )
                      else ...[
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Before you submit',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Status: ${_prettyLabel(status.status)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              if (status.store.name?.trim().isNotEmpty ==
                                  true) ...[
                                const SizedBox(height: 12),
                                Text(
                                  status.store.name!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                              ],
                              if (status.store.slug?.trim().isNotEmpty ==
                                  true) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Slug: ${status.store.slug}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                              if (status.catalog != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  'Catalog: ${status.catalog?.productCount ?? 0} products • ${status.catalog!.readyForReview ? 'Ready' : 'Not ready'}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ],
                              if (status.payouts != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Payouts: ${status.payouts?.provider ?? 'Not selected'} • ${status.payouts!.setupComplete ? 'Complete' : 'Incomplete'}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 14),
                              if (uniqueMissing.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.green.withOpacity(0.20),
                                    ),
                                  ),
                                  child: const Text(
                                    'All required setup steps are complete. You can submit for review.',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.orange.withOpacity(0.20),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'You still have missing requirements:',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...uniqueMissing.map(
                                        (item) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 6,
                                          ),
                                          child: Text(
                                            '• ${_prettyLabel(item)}',
                                            style: const TextStyle(
                                              color: Color(0xFF92400E),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...uniqueSteps.map(
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
                                    : Icons.cancel_outlined,
                                color: step.completed
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              title: Text(
                                step.label,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              subtitle: Text(
                                step.completed
                                    ? 'Completed'
                                    : 'Needs attention',
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _openStep(context, step.key),
                            ),
                          ),
                        ),
                        if (status.documents != null &&
                            status.documents!.requiredDocuments.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Document status (${status.documents!.uploadedCount}/${status.documents!.totalCount} uploaded)',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...status.documents!.requiredDocuments.map(
                                  (doc) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          doc.uploaded
                                              ? Icons.insert_drive_file_outlined
                                              : Icons.upload_file_outlined,
                                          color: _documentStatusColor(
                                            doc.status,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                doc.label,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF111827),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _prettyLabel(doc.status),
                                                style: TextStyle(
                                                  color: _documentStatusColor(
                                                    doc.status,
                                                  ),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              if (doc.fileName != null &&
                                                  doc.fileName!
                                                      .trim()
                                                      .isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  doc.fileName!,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/seller/onboarding/documents',
                                            );
                                          },
                                          child: const Text('Manage'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: provider.isLoading
                                ? null
                                : status.canSubmitForReview
                                ? () async {
                                    final ok = await provider.submitForReview();
                                    if (!context.mounted) return;

                                    if (ok) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Submitted for review'),
                                        ),
                                      );
                                      await provider.loadStatus();
                                      if (!context.mounted) return;
                                      Navigator.popUntil(
                                        context,
                                        ModalRoute.withName(
                                          '/seller/onboarding',
                                        ),
                                      );
                                    }
                                  }
                                : null,
                            child: provider.isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Submit for review'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        );
      },
    );
  }
}
