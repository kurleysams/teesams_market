import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tenant_save_store_profile.dart';
import '../state/seller_onboarding_provider.dart';

class SellerStoreProfileScreen extends StatefulWidget {
  const SellerStoreProfileScreen({super.key});

  @override
  State<SellerStoreProfileScreen> createState() =>
      _SellerStoreProfileScreenState();
}

class _SellerStoreProfileScreenState extends State<SellerStoreProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _storeNameCtrl = TextEditingController();
  final _slugCtrl = TextEditingController();
  final _taglineCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _addressLine1Ctrl = TextEditingController();

  bool _submitted = false;
  bool _prefilled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_prefilled) return;

    final provider = context.read<SellerOnboardingProvider>();
    final store = provider.status?.store;

    if (store != null) {
      _storeNameCtrl.text = store.name ?? '';
      _slugCtrl.text = store.slug ?? '';
      _taglineCtrl.text = store.tagline ?? '';
      _cityCtrl.text = store.city ?? '';
      _countryCtrl.text = store.country ?? '';
      _addressLine1Ctrl.text = store.addressLine1 ?? '';
    }

    _prefilled = true;
  }

  @override
  void dispose() {
    _storeNameCtrl.dispose();
    _slugCtrl.dispose();
    _taglineCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    _addressLine1Ctrl.dispose();
    super.dispose();
  }

  String? _validateStoreName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter your store name';
    if (text.length < 2) return 'Store name is too short';
    return null;
  }

  String? _validateSlug(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter a store slug';

    final slugRegex = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');
    if (!slugRegex.hasMatch(text)) {
      return 'Use lowercase letters, numbers, and hyphens only';
    }

    return null;
  }

  String? _validateCity(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter your city';
    return null;
  }

  String? _validateCountry(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter your country';
    return null;
  }

  String _slugify(String input) {
    final lower = input.trim().toLowerCase();
    final replaced = lower
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return replaced;
  }

  void _generateSlugFromName() {
    final slug = _slugify(_storeNameCtrl.text);
    if (slug.isNotEmpty) {
      setState(() {
        _slugCtrl.text = slug;
      });
    }
  }

  Future<void> _submit() async {
    setState(() {
      _submitted = true;
    });

    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final provider = context.read<SellerOnboardingProvider>();

    final request = SaveStoreProfileRequest(
      storeName: _storeNameCtrl.text.trim(),
      storeSlug: _slugCtrl.text.trim(),
      tagline: _taglineCtrl.text.trim().isEmpty
          ? null
          : _taglineCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      country: _countryCtrl.text.trim(),
      addressLine1: _addressLine1Ctrl.text.trim().isEmpty
          ? null
          : _addressLine1Ctrl.text.trim(),
    );

    final ok = await provider.saveStoreProfile(request);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Store profile saved')));
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
            title: const Text('Store profile'),
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
                        Icons.storefront_outlined,
                        size: 56,
                        color: Color(0xFF1D4ED8),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Set up your store profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add the public details customers will use to identify your store.',
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
                                controller: _storeNameCtrl,
                                textInputAction: TextInputAction.next,
                                validator: _validateStoreName,
                                decoration: InputDecoration(
                                  labelText: 'Store name',
                                  hintText: 'Amina Fresh Foods',
                                  prefixIcon: const Icon(
                                    Icons.storefront_outlined,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onChanged: (_) {
                                  if (_slugCtrl.text.trim().isEmpty) {
                                    _generateSlugFromName();
                                  }
                                },
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _slugCtrl,
                                textInputAction: TextInputAction.next,
                                validator: _validateSlug,
                                decoration: InputDecoration(
                                  labelText: 'Store slug',
                                  hintText: 'amina-fresh-foods',
                                  prefixIcon: const Icon(Icons.link_outlined),
                                  suffixIcon: IconButton(
                                    onPressed: _generateSlugFromName,
                                    icon: const Icon(Icons.auto_fix_high),
                                    tooltip: 'Generate from store name',
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _taglineCtrl,
                                textInputAction: TextInputAction.next,
                                maxLines: 2,
                                decoration: InputDecoration(
                                  labelText: 'Tagline (optional)',
                                  hintText:
                                      'Fresh fish, meat and groceries delivered daily',
                                  prefixIcon: const Icon(
                                    Icons.short_text_outlined,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _addressLine1Ctrl,
                                textInputAction: TextInputAction.next,
                                maxLines: 2,
                                decoration: InputDecoration(
                                  labelText: 'Address line 1 (optional)',
                                  hintText: '12 High Street',
                                  prefixIcon: const Icon(Icons.home_outlined),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _cityCtrl,
                                textInputAction: TextInputAction.next,
                                validator: _validateCity,
                                decoration: InputDecoration(
                                  labelText: 'City',
                                  hintText: 'London',
                                  prefixIcon: const Icon(
                                    Icons.location_city_outlined,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _countryCtrl,
                                textInputAction: TextInputAction.done,
                                validator: _validateCountry,
                                onFieldSubmitted: (_) => _submit(),
                                decoration: InputDecoration(
                                  labelText: 'Country',
                                  hintText: 'United Kingdom',
                                  prefixIcon: const Icon(Icons.public_outlined),
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
                                      : const Text('Save store profile'),
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
