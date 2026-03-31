import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/seller_onboarding_provider.dart';

class SellerOnboardingHomeScreen extends StatefulWidget {
  const SellerOnboardingHomeScreen({super.key});

  @override
  State<SellerOnboardingHomeScreen> createState() =>
      _SellerOnboardingHomeScreenState();
}

class _SellerOnboardingHomeScreenState
    extends State<SellerOnboardingHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SellerOnboardingProvider>().loadStatus();
    });
  }

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
        Navigator.pushNamed(context, '/seller/onboarding/review');
    }
  }

  String _stepSummary(SellerOnboardingProvider provider, String key) {
    final status = provider.status;
    if (status == null) return '';

    switch (key) {
      case 'business_details':
        final business = status.business;
        if ((business.legalName?.trim().isNotEmpty ?? false)) {
          return business.legalName!;
        }
        return 'Add your legal business details';

      case 'store_profile':
        final store = status.store;
        final name = store.name?.trim();
        final location = [
          store.city?.trim(),
          store.country?.trim(),
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        if (name != null && name.isNotEmpty && location.isNotEmpty) {
          return '$name • $location';
        }
        if (name != null && name.isNotEmpty) return name;
        return 'Set your store name, slug, and location';

      case 'operations':
        final address = status.store.addressLine1?.trim();
        if (address != null && address.isNotEmpty) {
          return address;
        }
        return 'Choose delivery and pickup options';

      case 'documents':
        final docs = status.documents;
        if (docs == null || docs.totalCount == 0) {
          return 'Upload required verification files';
        }
        return '${docs.uploadedCount}/${docs.totalCount} uploaded';

      case 'catalog_setup':
        final catalog = status.catalog;
        if (catalog == null) {
          return 'Add your initial product setup';
        }
        final count = catalog.productCount;
        final ready = catalog.readyForReview ? 'Ready' : 'Not ready';
        if (count != null) {
          return '$count products • $ready';
        }
        return ready;

      case 'payout_setup':
        final payouts = status.payouts;
        if (payouts == null) {
          return 'Choose payout provider';
        }
        final providerName = payouts.provider?.trim();
        final ready = payouts.setupComplete ? 'Complete' : 'Incomplete';
        if (providerName != null && providerName.isNotEmpty) {
          return '$providerName • $ready';
        }
        return ready;

      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerOnboardingProvider>(
      builder: (context, provider, _) {
        final status = provider.status;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(title: const Text('Store onboarding')),
          body: provider.isLoading && status == null
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: provider.loadStatus,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
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
                              'Complete your setup',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              status == null
                                  ? 'Load your onboarding checklist.'
                                  : 'Status: ${status.status}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            if (status != null &&
                                status.store.name?.trim().isNotEmpty ==
                                    true) ...[
                              const SizedBox(height: 10),
                              Text(
                                status.store.name!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
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
                      if (status != null) ...[
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
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              subtitle: Text(_stepSummary(provider, step.key)),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _openStep(context, step.key),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            onPressed: status.canSubmitForReview
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
                                    }
                                  }
                                : () {
                                    Navigator.pushNamed(
                                      context,
                                      '/seller/onboarding/review',
                                    );
                                  },
                            child: Text(
                              status.canSubmitForReview
                                  ? 'Submit for review'
                                  : 'Review requirements',
                            ),
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
