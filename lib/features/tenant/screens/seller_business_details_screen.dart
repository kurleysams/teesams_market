import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tenant_save_business_details.dart';
import '../state/seller_onboarding_provider.dart';

class SellerBusinessDetailsScreen extends StatefulWidget {
  const SellerBusinessDetailsScreen({super.key});

  @override
  State<SellerBusinessDetailsScreen> createState() =>
      _SellerBusinessDetailsScreenState();
}

class _SellerBusinessDetailsScreenState
    extends State<SellerBusinessDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _legalNameCtrl = TextEditingController();
  final _businessEmailCtrl = TextEditingController();
  final _businessPhoneCtrl = TextEditingController();
  final _registrationNumberCtrl = TextEditingController();
  final _taxNumberCtrl = TextEditingController();

  bool _submitted = false;
  String _businessType = 'registered_business';
  bool _prefilled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_prefilled) return;

    final provider = context.read<SellerOnboardingProvider>();
    final business = provider.status?.business;

    if (business != null) {
      _legalNameCtrl.text = business.legalName ?? '';
      _businessEmailCtrl.text = business.businessEmail ?? '';
      _businessPhoneCtrl.text = business.businessPhone ?? '';
      _registrationNumberCtrl.text = business.registrationNumber ?? '';
      _taxNumberCtrl.text = business.taxNumber ?? '';

      final existingType = business.businessType?.trim();
      if (existingType != null && existingType.isNotEmpty) {
        _businessType = existingType;
      }
    }

    _prefilled = true;
  }

  @override
  void dispose() {
    _legalNameCtrl.dispose();
    _businessEmailCtrl.dispose();
    _businessPhoneCtrl.dispose();
    _registrationNumberCtrl.dispose();
    _taxNumberCtrl.dispose();
    super.dispose();
  }

  String? _validateLegalName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter your legal business name';
    if (text.length < 2) return 'Business name is too short';
    return null;
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter your business email';

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(text)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  String? _validatePhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter your business phone';
    if (text.length < 7) return 'Enter a valid phone number';
    return null;
  }

  Future<void> _submit() async {
    setState(() {
      _submitted = true;
    });

    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final provider = context.read<SellerOnboardingProvider>();

    final request = SaveBusinessDetailsRequest(
      legalName: _legalNameCtrl.text.trim(),
      businessEmail: _businessEmailCtrl.text.trim(),
      businessPhone: _businessPhoneCtrl.text.trim(),
      businessType: _businessType,
      registrationNumber: _registrationNumberCtrl.text.trim().isEmpty
          ? null
          : _registrationNumberCtrl.text.trim(),
      taxNumber: _taxNumberCtrl.text.trim().isEmpty
          ? null
          : _taxNumberCtrl.text.trim(),
    );

    final ok = await provider.saveBusinessDetails(request);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Business details saved')));
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
            title: const Text('Business details'),
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
                        Icons.business_outlined,
                        size: 56,
                        color: Color(0xFF1D4ED8),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Tell us about your business',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'These details help us review and activate your store.',
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
                                controller: _legalNameCtrl,
                                textInputAction: TextInputAction.next,
                                validator: _validateLegalName,
                                decoration: InputDecoration(
                                  labelText: 'Legal business name',
                                  hintText: 'Amina Fresh Foods Ltd',
                                  prefixIcon: const Icon(Icons.business),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              DropdownButtonFormField<String>(
                                value: _businessType,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'individual',
                                    child: Text('Individual'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'registered_business',
                                    child: Text('Registered business'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'sole_trader',
                                    child: Text('Sole trader'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'partnership',
                                    child: Text('Partnership'),
                                  ),
                                ],
                                onChanged: provider.isLoading
                                    ? null
                                    : (value) {
                                        if (value == null) return;
                                        setState(() {
                                          _businessType = value;
                                        });
                                      },
                                decoration: InputDecoration(
                                  labelText: 'Business type',
                                  prefixIcon: const Icon(Icons.badge_outlined),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _businessEmailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: _validateEmail,
                                decoration: InputDecoration(
                                  labelText: 'Business email',
                                  hintText: 'you@business.com',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _businessPhoneCtrl,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                validator: _validatePhone,
                                decoration: InputDecoration(
                                  labelText: 'Business phone',
                                  hintText: '+447700000000',
                                  prefixIcon: const Icon(Icons.phone_outlined),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _registrationNumberCtrl,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  labelText: 'Registration number (optional)',
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
                              TextFormField(
                                controller: _taxNumberCtrl,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  labelText: 'Tax number (optional)',
                                  prefixIcon: const Icon(
                                    Icons.receipt_long_outlined,
                                  ),
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
                                      : const Text('Save business details'),
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
