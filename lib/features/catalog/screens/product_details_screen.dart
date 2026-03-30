import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_config.dart';
import '../../../shared/widgets/cart_icon_button.dart';
import '../../cart/state/cart_provider.dart';
import '../models/product.dart';
import '../models/variant.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  Variant? _selectedVariant;

  @override
  void initState() {
    super.initState();

    if (widget.product.variants.isNotEmpty) {
      final firstPurchasable = widget.product.variants
          .cast<Variant?>()
          .firstWhere(
            (variant) => variant?.canPurchase == true,
            orElse: () => widget.product.variants.first,
          );
      _selectedVariant = firstPurchasable;
    }
  }

  String? _normalizeUrl(String? value) {
    if (value == null) return null;

    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    final origin = AppConfig.baseUrl.replaceFirst('/api', '');
    if (trimmed.startsWith('/')) {
      return '$origin$trimmed';
    }

    return '$origin/$trimmed';
  }

  double get _displayPrice {
    if (_selectedVariant != null) return _selectedVariant!.priceUsed;
    return widget.product.minPrice;
  }

  Variant _fallbackVariant(Product product) {
    return Variant(
      id: -product.id,
      sku: 'product-${product.id}',
      name: 'Default',
      unitType: null,
      unitQty: null,
      price: product.minPrice,
      salePrice: null,
      priceUsed: product.minPrice,
      hasDiscount: false,
      isAvailable: true,
      trackInventory: false,
      stockQty: null,
      allowBackorder: true,
      inStock: true,
      canBeOrdered: true,
    );
  }

  bool get _canAddSelectedVariant {
    final variant = _selectedVariant;
    if (variant == null) {
      return widget.product.variants.isEmpty;
    }
    return variant.canPurchase;
  }

  String get _ctaLabel {
    final variant = _selectedVariant;

    if (variant == null) {
      return 'Add to cart';
    }

    if (!variant.isAvailable) {
      return 'Unavailable';
    }

    if (!variant.canBeOrdered) {
      return 'Out of stock';
    }

    return 'Add to cart';
  }

  void _addToCart() {
    final cart = context.read<CartProvider>();
    final product = widget.product;

    final variant =
        _selectedVariant ??
        (product.variants.isEmpty ? _fallbackVariant(product) : null);

    if (variant == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select an option first')));
      return;
    }

    if (!variant.isAvailable) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('This item is unavailable')));
      return;
    }

    if (!variant.canBeOrdered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This item is out of stock')),
      );
      return;
    }

    try {
      cart.add(product, variant);

      _showAddedSheet(
        productName: product.name,
        variantLabel: variant.name.trim().isNotEmpty ? variant.name : 'Default',
      );
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message.isEmpty ? 'Unable to add item to cart' : message,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final imageUrl = _normalizeUrl(product.imageUrl);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF111827),
            pinned: true,
            expandedHeight: 300,
            elevation: 0,
            actions: [
              CartIconButton(
                onTap: () => Navigator.pushNamed(context, '/cart'),
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _ProductHeroImage(
                imageUrl: imageUrl,
                name: product.name,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '£${_displayPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  if (_selectedVariant != null &&
                      !_selectedVariant!.isAvailable) ...[
                    const SizedBox(height: 10),
                    const _StatusNotice(
                      icon: Icons.block_outlined,
                      text: 'This option is currently unavailable.',
                      color: Color(0xFFB91C1C),
                      background: Color(0xFFFEECEC),
                    ),
                  ] else if (_selectedVariant != null &&
                      !_selectedVariant!.canBeOrdered) ...[
                    const SizedBox(height: 10),
                    const _StatusNotice(
                      icon: Icons.inventory_2_outlined,
                      text: 'This option is currently out of stock.',
                      color: Color(0xFF92400E),
                      background: Color(0xFFFFF7E6),
                    ),
                  ],
                  const SizedBox(height: 14),
                  if (product.description?.trim().isNotEmpty == true)
                    _SectionCard(
                      child: Text(
                        product.description!.trim(),
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.45,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  if (product.description?.trim().isNotEmpty == true)
                    const SizedBox(height: 14),
                  if (product.variants.isNotEmpty) ...[
                    const Text(
                      'Options',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...product.variants.map((variant) {
                      final selected = _selectedVariant?.id == variant.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _VariantTile(
                          variant: variant,
                          selected: selected,
                          onTap: () {
                            setState(() {
                              _selectedVariant = variant;
                            });
                          },
                        ),
                      );
                    }),
                  ] else ...[
                    _SectionCard(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Color(0xFF325A88),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ready to order',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
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
        ],
      ),
      bottomNavigationBar: SafeArea(
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
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Text(
                    '£${_displayPrice.toStringAsFixed(2)}',
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
                    onPressed: _canAddSelectedVariant ? _addToCart : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D4ED8),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      disabledBackgroundColor: const Color(0xFFE5E7EB),
                      disabledForegroundColor: const Color(0xFF6B7280),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _ctaLabel,
                      style: const TextStyle(
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
    );
  }

  void _showAddedSheet({
    required String productName,
    required String variantLabel,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) {
        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F1FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Color(0xFF1D4ED8)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Added to cart',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$productName • $variantLabel',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/cart');
                  },
                  child: const Text('View cart'),
                ),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }
}

class _ProductHeroImage extends StatelessWidget {
  final String? imageUrl;
  final String name;

  const _ProductHeroImage({required this.imageUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _fallback();
        },
      );
    }

    return _fallback();
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFFEFF6FF),
      child: const Center(
        child: Icon(
          Icons.fastfood_outlined,
          size: 64,
          color: Color(0xFF325A88),
        ),
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
      ),
      child: child,
    );
  }
}

class _StatusNotice extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color background;

  const _StatusNotice({
    required this.icon,
    required this.text,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VariantTile extends StatelessWidget {
  final Variant variant;
  final bool selected;
  final VoidCallback onTap;

  const _VariantTile({
    required this.variant,
    required this.selected,
    required this.onTap,
  });

  String _variantTitle() {
    if (variant.name.trim().isNotEmpty) return variant.name.trim();

    final unit = variant.unitType?.trim() ?? '';
    final qty = variant.unitQty != null ? variant.unitQty!.toString() : '';

    if (unit.isNotEmpty && qty.isNotEmpty) {
      return '$qty $unit';
    }

    if (unit.isNotEmpty) return unit;

    return 'Option';
  }

  String? _availabilityLabel() {
    if (!variant.isAvailable) return 'Unavailable';
    if (!variant.canBeOrdered) return 'Out of stock';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final canPurchase = variant.canPurchase;
    final availabilityLabel = _availabilityLabel();

    return Opacity(
      opacity: canPurchase ? 1 : 0.62,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEFF6FF) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFFE5E7EB),
              width: selected ? 1.4 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected
                    ? const Color(0xFF1D4ED8)
                    : const Color(0xFF9CA3AF),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _variantTitle(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    if (availabilityLabel != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        availabilityLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: !variant.isAvailable
                              ? const Color(0xFFB91C1C)
                              : const Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '£${variant.priceUsed.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
