import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tenant_save_catalog_setup.dart';
import '../state/seller_onboarding_provider.dart';

class SellerCatalogSetupScreen extends StatefulWidget {
  const SellerCatalogSetupScreen({super.key});

  @override
  State<SellerCatalogSetupScreen> createState() =>
      _SellerCatalogSetupScreenState();
}

class _SellerCatalogSetupScreenState extends State<SellerCatalogSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productCountCtrl = TextEditingController();

  bool _submitted = false;
  bool _readyForReview = false;

  @override
  void dispose() {
    _productCountCtrl.dispose();
    super.dispose();
  }

  String? _validateProductCount(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter your current product count';

    final count = int.tryParse(text);
    if (count == null) return 'Enter a valid number';
    if (count < 0) return 'Product count cannot be negative';

    return null;
  }

  Future<void> _submit() async {
    setState(() {
      _submitted = true;
    });

    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final provider = context.read<SellerOnboardingProvider>();

    final request = SaveCatalogSetupRequest(
      productCount: int.parse(_productCountCtrl.text.trim()),
      readyForReview: _readyForReview,
    );

    final ok = await provider.saveCatalogSetup(request);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Catalog setup saved')));
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
            title: const Text('Catalog setup'),
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 56,
                        color: Color(0xFF1D4ED8),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Prepare your catalog',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tell us whether your initial product setup is ready for review.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF6B7280),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
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
                        child: Form(
                          key: _formKey,
                          autovalidateMode: _submitted
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _productCountCtrl,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                validator: _validateProductCount,
                                onFieldSubmitted: (_) => _submit(),
                                decoration: InputDecoration(
                                  labelText: 'Product count',
                                  hintText: '25',
                                  prefixIcon: const Icon(
                                    Icons.numbers_outlined,
                                  ),
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
                                value: _readyForReview,
                                onChanged: provider.isLoading
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _readyForReview = value;
                                        });
                                      },
                                title: const Text('Mark catalog as ready'),
                                subtitle: const Text(
                                  'Turn this on when your initial products are ready for review.',
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: provider.isLoading
                                      ? null
                                      : _submit,
                                  child: provider.isLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Save catalog setup'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
