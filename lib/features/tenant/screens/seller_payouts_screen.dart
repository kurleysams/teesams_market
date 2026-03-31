import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tenant_save_payouts.dart';
import '../state/seller_onboarding_provider.dart';

class SellerPayoutsScreen extends StatefulWidget {
  const SellerPayoutsScreen({super.key});

  @override
  State<SellerPayoutsScreen> createState() => _SellerPayoutsScreenState();
}

class _SellerPayoutsScreenState extends State<SellerPayoutsScreen> {
  final _accountReferenceCtrl = TextEditingController();

  bool _setupComplete = false;
  bool _prefilled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_prefilled) return;

    final onboarding = context.read<SellerOnboardingProvider>().status;
    final payouts = onboarding?.payouts;

    if (payouts != null) {
      _accountReferenceCtrl.text = payouts.accountReference ?? '';
      _setupComplete = payouts.setupComplete;
    }

    _prefilled = true;
  }

  @override
  void dispose() {
    _accountReferenceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final provider = context.read<SellerOnboardingProvider>();

    final request = SavePayoutsRequest(
      provider: 'stripe',
      setupComplete: _setupComplete,
      accountReference: _accountReferenceCtrl.text.trim().isEmpty
          ? null
          : _accountReferenceCtrl.text.trim(),
    );

    final ok = await provider.savePayouts(request);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Payout setup saved')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerOnboardingProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF8FAFC),
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text('Payout setup'),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                if (provider.error != null && provider.error!.trim().isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      border: Border.all(color: Colors.red.withOpacity(0.20)),
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
                      const Text(
                        'Stripe payouts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Teesams uses Stripe to handle seller payouts securely. '
                        'Complete this step once your Stripe payout account is connected or ready to be connected.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              color: Color(0xFF1D4ED8),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Payout provider: Stripe',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _accountReferenceCtrl,
                        enabled: !provider.isLoading,
                        decoration: InputDecoration(
                          labelText: 'Stripe account reference (optional)',
                          hintText: 'acct_123456789 or internal note',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _setupComplete,
                        onChanged: provider.isLoading
                            ? null
                            : (v) => setState(() => _setupComplete = v),
                        title: const Text('Mark payout setup as complete'),
                        subtitle: const Text(
                          'Turn this on once your Stripe payout setup has been completed.',
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: provider.isLoading ? null : _submit,
                          child: provider.isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Save payout setup'),
                        ),
                      ),
                    ],
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
