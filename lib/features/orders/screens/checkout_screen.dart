// lib/features/orders/screens/checkout_screen.dart
// lib/features/orders/screens/checkout_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';
import '../../cart/data/checkout_api.dart';
import '../../cart/data/stripe_checkout_service.dart';
import '../../cart/models/cart_item.dart';
import '../../cart/models/checkout_payment_models.dart';
import '../../cart/screens/order_pending_page.dart';
import '../../cart/state/cart_provider.dart';
import '../../tenant/state/tenant_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  late CheckoutApi _api;
  late StripeCheckoutService _checkoutService;

  bool _submitting = false;

  @override
  void initState() {
    super.initState();

    final apiClient = ApiClient(tenantSlug: 'fishseafoods');
    _api = CheckoutApi(apiClient.dio);
    _checkoutService = StripeCheckoutService(_api);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String? _normalizeUrl(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    final origin = AppConfig.baseUrl.replaceFirst('/api/', '/');
    if (trimmed.startsWith('/')) {
      return '$origin$trimmed';
    }
    return '$origin/$trimmed';
  }

  Future<void> _submit() async {
    final cart = context.read<CartProvider>();
    final tenantProvider = context.read<TenantProvider>();

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Your cart is empty')));
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final tenantSlug = tenantProvider.tenant.slug;
    if (tenantSlug.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Store information is missing')),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final apiClient = ApiClient(tenantSlug: tenantSlug);
      _api = CheckoutApi(apiClient.dio);
      _checkoutService = StripeCheckoutService(_api);

      final request = CreatePaymentRequest(
        customerName: _nameCtrl.text.trim(),
        customerPhone: _phoneCtrl.text.trim(),
        fulfilmentType: 'delivery',
        deliveryAddress: _addressCtrl.text.trim(),
        customerNote: _notesCtrl.text.trim(),
        items: cart.items.map((item) {
          return CheckoutPaymentItem(variantId: item.variant.id, qty: item.qty);
        }).toList(),
      );

      final result = await _checkoutService.pay(request: request);

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OrderPendingPage(
            orderId: result.orderId,
            orderNumber: result.orderNumber,
            api: _api,
          ),
        ),
      );
    } on StripeException catch (e) {
      if (!mounted) return;

      final message = e.error.code == FailureCode.Canceled
          ? 'Payment cancelled. Your details are still here.'
          : (e.error.localizedMessage ?? 'Unable to complete payment.');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;

      final raw = e.toString().replaceFirst('Exception: ', '');
      final message = raw.isEmpty ? 'Unable to start payment.' : raw;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
      ),
      body: cart.items.isEmpty
          ? const _EmptyCheckoutState()
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    children: [
                      _SectionCard(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Delivery details',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _InputField(
                                controller: _nameCtrl,
                                label: 'Full name',
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter your name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              _InputField(
                                controller: _phoneCtrl,
                                label: 'Phone number',
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter your phone number';
                                  }
                                  if (value.trim().length < 7) {
                                    return 'Enter a valid phone number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              _InputField(
                                controller: _addressCtrl,
                                label: 'Delivery address',
                                maxLines: 3,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter your delivery address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              _InputField(
                                controller: _notesCtrl,
                                label: 'Notes (optional)',
                                maxLines: 3,
                                textInputAction: TextInputAction.done,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order summary',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...cart.items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _CheckoutItemTile(
                                  item: item,
                                  imageUrl: _normalizeUrl(item.imageUrl),
                                ),
                              ),
                            ),
                            const Divider(height: 24),
                            _SummaryRow(
                              label: 'Subtotal',
                              value: '£${cart.subtotal.toStringAsFixed(2)}',
                            ),
                            const SizedBox(height: 8),
                            const _SummaryRow(
                              label: 'Delivery',
                              value: 'Calculated later',
                              muted: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Text(
                              '£${cart.subtotal.toStringAsFixed(2)}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _submitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1D4ED8),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _submitting
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Pay now',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.2),
        ),
      ),
    );
  }
}

class _CheckoutItemTile extends StatelessWidget {
  final CartItem item;
  final String? imageUrl;

  const _CheckoutItemTile({required this.item, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CheckoutItemThumb(imageUrl: imageUrl),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${item.variantLabel} • Qty ${item.qty}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '£${item.lineTotal.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}

class _CheckoutItemThumb extends StatelessWidget {
  final String? imageUrl;

  const _CheckoutItemThumb({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imageUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _placeholder();
          },
        ),
      );
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Icon(
        Icons.fastfood_outlined,
        size: 20,
        color: Color(0xFF6B7280),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool muted;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = muted ? const Color(0xFF6B7280) : const Color(0xFF111827);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: muted ? FontWeight.w500 : FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: muted ? FontWeight.w500 : FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _EmptyCheckoutState extends StatelessWidget {
  const _EmptyCheckoutState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 42,
              color: Color(0xFF6B7280),
            ),
            SizedBox(height: 12),
            Text(
              'No items to checkout',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Add products to your cart first.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }
}
