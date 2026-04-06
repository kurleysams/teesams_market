import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/tenant_onboarding_status.dart';
import '../state/seller_onboarding_provider.dart';

class SellerPayoutsScreen extends StatefulWidget {
  const SellerPayoutsScreen({super.key});

  @override
  State<SellerPayoutsScreen> createState() => _SellerPayoutsScreenState();
}

class _SellerPayoutsScreenState extends State<SellerPayoutsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<SellerOnboardingProvider>().loadStripeStatus();
    });
  }

  Future<void> _launchConnectUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _showSnack('Invalid Stripe onboarding link.');
      return;
    }

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      _showSnack('Unable to open Stripe onboarding link.');
    }
  }

  Future<void> _connectOrContinue() async {
    final provider = context.read<SellerOnboardingProvider>();
    final url = await provider.connectStripe();

    if (!mounted) return;

    if (url == null || url.trim().isEmpty) {
      _showSnack(provider.error ?? 'Unable to start Stripe onboarding.');
      return;
    }

    await _launchConnectUrl(url);

    if (!mounted) return;

    _showSnack('Returned from Stripe? Tap refresh to update status.');
  }

  Future<void> _refreshStatus() async {
    final provider = context.read<SellerOnboardingProvider>();
    final ok = await provider.refreshStripe();

    if (!mounted) return;

    if (ok) {
      _showSnack('Stripe status refreshed.');
    } else {
      _showSnack(provider.error ?? 'Unable to refresh Stripe status.');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _statusLabel(StripePayoutDetails? stripe) {
    if (stripe == null || !stripe.hasAccount) return 'Not connected';
    if (stripe.isReady) return 'Approved';
    if ((stripe.onboardingStatus ?? '').toLowerCase() == 'restricted') {
      return 'Action required';
    }
    return 'Pending';
  }

  String _friendlyRequirement(String value) {
    final key = value.trim().toLowerCase();

    const labels = <String, String>{
      'requirements.past_due': 'Stripe still needs more information',
      'individual.first_name': 'First name',
      'individual.last_name': 'Last name',
      'individual.email': 'Email address',
      'individual.phone': 'Phone number',
      'individual.dob.day': 'Birth day',
      'individual.dob.month': 'Birth month',
      'individual.dob.year': 'Birth year',
      'individual.id_number': 'Government ID number',
      'individual.ssn_last_4': 'Last 4 digits of ID number',
      'individual.address.line1': 'Address line 1',
      'individual.address.line2': 'Address line 2',
      'individual.address.city': 'City',
      'individual.address.state': 'County / State',
      'individual.address.postal_code': 'Postcode',
      'individual.address.country': 'Country',
      'business_profile.name': 'Business name',
      'business_profile.url': 'Business website',
      'business_profile.product_description': 'Business description',
      'external_account': 'Bank account details',
      'company.name': 'Company name',
      'company.phone': 'Company phone',
      'company.tax_id': 'Company tax ID',
      'company.address.line1': 'Company address line 1',
      'company.address.line2': 'Company address line 2',
      'company.address.city': 'Company city',
      'company.address.state': 'Company county / state',
      'company.address.postal_code': 'Company postcode',
      'company.address.country': 'Company country',
      'company.directors_provided': 'Director details',
      'company.executives_provided': 'Executive details',
      'company.owners_provided': 'Owner details',
      'tos_acceptance.date': 'Terms acceptance',
      'tos_acceptance.ip': 'Terms acceptance',
    };

    if (labels.containsKey(key)) {
      return labels[key]!;
    }

    final withoutPrefix = key
        .replaceAll('requirements.', '')
        .replaceAll('individual.', '')
        .replaceAll('company.', '')
        .replaceAll('business_profile.', '')
        .replaceAll('external_account.', '')
        .replaceAll('.', ' ')
        .replaceAll('_', ' ')
        .trim();

    if (withoutPrefix.isEmpty) return value;

    return withoutPrefix
        .split(' ')
        .where((e) => e.trim().isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  List<String> _friendlyRequirements(List<String> raw) {
    final seen = <String>{};
    final output = <String>[];

    for (final item in raw) {
      final label = _friendlyRequirement(item);
      if (seen.add(label.toLowerCase())) {
        output.add(label);
      }
    }

    return output;
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
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
      child: child,
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1D4ED8)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$title: $value',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkRow(String label, bool done) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: done ? Colors.green : const Color(0xFF9CA3AF),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerOnboardingProvider>(
      builder: (context, provider, _) {
        final status = provider.status;
        final payouts = status?.payouts;
        final stripe = payouts?.stripe;
        final requirements = _friendlyRequirements(
          stripe?.requirementsCurrentlyDue ?? const <String>[],
        );

        final hasAccount = stripe?.hasAccount ?? false;
        final isReady = stripe?.isReady ?? false;
        final isPending = stripe?.isPending ?? false;
        final isRestricted =
            (stripe?.onboardingStatus ?? '').toLowerCase() == 'restricted';

        final actionLabel = !hasAccount
            ? 'Connect Stripe account'
            : isReady
            ? 'Open Stripe again'
            : 'Complete Stripe verification';

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF8FAFC),
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text('Connect Stripe'),
          ),
          body: SafeArea(
            child: provider.isLoading && status == null
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _refreshStatus,
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

                        _sectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Stripe verification',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                isReady
                                    ? 'Your Stripe account is approved and ready for marketplace payments.'
                                    : 'Connect and complete your Stripe account so Teesams can accept payments for your store and route your earnings correctly.',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _infoRow(
                                icon: Icons.account_balance_wallet_outlined,
                                title: 'Status',
                                value: _statusLabel(stripe),
                              ),
                              if ((stripe?.accountId ?? '').isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  'Connected account: ${stripe!.accountId}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: provider.isLoading
                                      ? null
                                      : _connectOrContinue,
                                  child: provider.isLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(actionLabel),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: OutlinedButton.icon(
                                  onPressed: provider.isLoading
                                      ? null
                                      : _refreshStatus,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Refresh Stripe status'),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        _sectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Approval checks',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 14),
                              _checkRow('Stripe account connected', hasAccount),
                              _checkRow(
                                'Details submitted',
                                stripe?.detailsSubmitted ?? false,
                              ),
                              _checkRow(
                                'Payments enabled',
                                stripe?.chargesEnabled ?? false,
                              ),
                              _checkRow(
                                'Payouts enabled',
                                stripe?.payoutsEnabled ?? false,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                isReady
                                    ? 'Stripe has approved this account for marketplace use.'
                                    : 'This step completes automatically when Stripe approves the connected account.',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (isPending || isRestricted) ...[
                          const SizedBox(height: 16),
                          _sectionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isRestricted
                                      ? 'Action required in Stripe'
                                      : 'Stripe still needs information',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Complete these fields in Stripe, then return here and refresh your status.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B7280),
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if ((stripe?.requirementsDisabledReason ?? '')
                                    .isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFFECACA),
                                      ),
                                    ),
                                    child: Text(
                                      _friendlyRequirement(
                                        stripe!.requirementsDisabledReason!,
                                      ),
                                      style: const TextStyle(
                                        color: Color(0xFF991B1B),
                                      ),
                                    ),
                                  ),
                                ...requirements.map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(top: 2),
                                          child: Icon(
                                            Icons.circle,
                                            size: 8,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            item,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF374151),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
