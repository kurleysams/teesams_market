import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tenant_save_operations.dart';
import '../state/seller_onboarding_provider.dart';

class SellerOperationsScreen extends StatefulWidget {
  const SellerOperationsScreen({super.key});

  @override
  State<SellerOperationsScreen> createState() => _SellerOperationsScreenState();
}

class _SellerOperationsScreenState extends State<SellerOperationsScreen> {
  bool _deliveryEnabled = true;
  bool _pickupEnabled = true;
  final _addressCtrl = TextEditingController();
  bool _prefilled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_prefilled) return;

    final provider = context.read<SellerOnboardingProvider>();
    final store = provider.status?.store;

    if ((store?.addressLine1?.trim().isNotEmpty ?? false)) {
      _addressCtrl.text = store!.addressLine1!.trim();
    }

    _prefilled = true;
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final provider = context.read<SellerOnboardingProvider>();

    final request = SaveOperationsRequest(
      supportsDelivery: _deliveryEnabled,
      supportsPickup: _pickupEnabled,
      pickupAddress: _addressCtrl.text.trim().isEmpty
          ? null
          : _addressCtrl.text.trim(),
      openingHours: const [],
      deliveryNotes: null,
    );

    final ok = await provider.saveOperations(request);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Operations saved')));
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
            title: const Text('Store operations'),
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
                        'Fulfilment options',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _deliveryEnabled,
                        onChanged: provider.isLoading
                            ? null
                            : (v) => setState(() => _deliveryEnabled = v),
                        title: const Text('Enable delivery'),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _pickupEnabled,
                        onChanged: provider.isLoading
                            ? null
                            : (v) => setState(() => _pickupEnabled = v),
                        title: const Text('Enable pickup'),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _addressCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Pickup / business address',
                          hintText: '12 Market Street, London',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
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
                              : const Text('Save operations'),
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
