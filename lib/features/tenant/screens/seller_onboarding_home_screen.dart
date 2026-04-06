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
  bool _confirmTerms = false;
  bool _redirecting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<SellerOnboardingProvider>().loadStatus();
      _maybeRedirectApprovedSeller();
    });
  }

  void _maybeRedirectApprovedSeller() {
    if (_redirecting || !mounted) return;

    final status = context.read<SellerOnboardingProvider>().status;
    if (status == null) return;

    final canEnterSellerPortal =
        status.status == 'approved' || status.status == 'active';

    if (!canEnterSellerPortal) return;

    _redirecting = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/seller/portal',
        (route) => false,
      );
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

  String _prettyStatus(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((e) => e.trim().isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
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
        final pickupAddress =
            status.operations?.pickupAddress?.trim() ??
            status.store.addressLine1?.trim();
        if (pickupAddress != null && pickupAddress.isNotEmpty) {
          return pickupAddress;
        }
        return 'Choose delivery and pickup options';

      case 'documents':
        final docs = status.documents;
        if (docs == null || docs.totalCount == 0) {
          return 'No documents required';
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
        final stripe = payouts?.stripe;

        if (stripe == null) {
          return 'Connect your Stripe account';
        }

        if (stripe.isReady) {
          return 'Stripe • Complete';
        }

        if (stripe.hasAccount) {
          return 'Stripe • Action needed';
        }

        return 'Stripe • Not connected';

      default:
        return '';
    }
  }

  Future<void> _submitForReview() async {
    final provider = context.read<SellerOnboardingProvider>();

    if (!_confirmTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm your details before submitting.'),
        ),
      );
      return;
    }

    final ok = await provider.submitForReview(confirmTerms: _confirmTerms);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Submitted for review')));
      await provider.loadStatus();
      _maybeRedirectApprovedSeller();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerOnboardingProvider>(
      builder: (context, provider, _) {
        final status = provider.status;

        if (status != null) {
          _maybeRedirectApprovedSeller();
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(title: const Text('Store onboarding')),
          body: provider.isLoading && status == null
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async {
                    await provider.loadStatus();
                    _maybeRedirectApprovedSeller();
                  },
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
                                  : 'Status: ${_prettyStatus(status.status)}',
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
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: CheckboxListTile(
                            value: _confirmTerms,
                            onChanged:
                                provider.isLoading || !status.canSubmitForReview
                                ? null
                                : (value) {
                                    setState(() {
                                      _confirmTerms = value ?? false;
                                    });
                                  },
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: const Text(
                              'I confirm these details are correct and ready for review',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                            subtitle: const Text(
                              'By submitting, you confirm your store information is accurate and Stripe setup is complete.',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            onPressed: status.canSubmitForReview
                                ? (_confirmTerms ? _submitForReview : null)
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
