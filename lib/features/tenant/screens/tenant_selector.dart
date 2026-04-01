import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_config.dart';
import '../../auth/state/auth_provider.dart';
import '../../catalog/state/catalog_provider.dart';
import '../state/tenant_mode_provider.dart';
import '../state/tenant_provider.dart';

class TenantSelector extends StatefulWidget {
  const TenantSelector({super.key});

  @override
  State<TenantSelector> createState() => _TenantSelectorState();
}

class _TenantSelectorState extends State<TenantSelector> {
  bool _switching = false;
  String? _switchingSlug;

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

  Future<void> _handleTenantTap(BuildContext context, dynamic tenant) async {
    final tenantProvider = context.read<TenantProvider>();
    final authProvider = context.read<AuthProvider>();
    final catalogProvider = context.read<CatalogProvider>();
    final tenantModeProvider = context.read<TenantModeProvider>();

    final isSelected = tenantProvider.slug == tenant.slug;
    if (isSelected) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _switching = true;
      _switchingSlug = tenant.slug;
    });

    try {
      await tenantProvider.switchTenant(tenant);

      await catalogProvider.loadCatalogForTenant(tenant.slug);

      await authProvider.loadSession(tenantSlug: tenant.slug);

      if (authProvider.isAuthenticated && authProvider.token != null) {
        await tenantModeProvider.loadBootstrap(
          tenantSlug: tenant.slug,
          authToken: authProvider.token,
        );
      } else {
        tenantModeProvider.clear();
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Switched to ${tenant.name}')));

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/catalog-home',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to switch store: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _switching = false;
          _switchingSlug = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tenantProvider = context.watch<TenantProvider>();
    final currentSlug = tenantProvider.slug;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Select Store',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
      ),
      body: tenantProvider.loading && tenantProvider.tenants.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : tenantProvider.tenants.isEmpty
          ? const Center(
              child: Text(
                'No stores available',
                style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              itemCount: tenantProvider.tenants.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final tenant = tenantProvider.tenants[index];
                final logoUrl = _normalizeUrl(tenant.logoUrl);
                final bannerUrl = _normalizeUrl(tenant.bannerUrl);
                final isSelected = currentSlug == tenant.slug;
                final isSwitchingThis =
                    _switching && _switchingSlug == tenant.slug;

                return Opacity(
                  opacity: _switching && !isSwitchingThis ? 0.65 : 1,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: _switching
                        ? null
                        : () => _handleTenantTap(context, tenant),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFFE5E7EB),
                          width: isSelected ? 1.6 : 1.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _TenantBanner(
                            bannerUrl: bannerUrl,
                            name: tenant.name,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                _TenantLogo(
                                  logoUrl: logoUrl,
                                  name: tenant.name,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              tenant.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF111827),
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE8F1FF),
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                              child: const Text(
                                                'Current',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1D4ED8),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        tenant.tagline?.trim().isNotEmpty ==
                                                true
                                            ? tenant.tagline!.trim()
                                            : tenant.slug,
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
                                const SizedBox(width: 8),
                                if (isSwitchingThis)
                                  const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFF6B7280),
                                    size: 22,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _TenantBanner extends StatelessWidget {
  final String? bannerUrl;
  final String name;

  const _TenantBanner({required this.bannerUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    final hasBanner = bannerUrl != null && bannerUrl!.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      child: SizedBox(
        height: 88,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasBanner)
              Image.network(
                bannerUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallback(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return _fallback();
                },
              )
            else
              _fallback(),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0x55000000), Color(0x11000000)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFFEFF6FF),
      child: const Center(
        child: Icon(
          Icons.storefront_outlined,
          size: 30,
          color: Color(0xFF325A88),
        ),
      ),
    );
  }
}

class _TenantLogo extends StatelessWidget {
  final String? logoUrl;
  final String name;

  const _TenantLogo({required this.logoUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    if (logoUrl != null && logoUrl!.trim().isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Image.network(
          logoUrl!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _fallback();
          },
        ),
      );
    }

    return _fallback();
  }

  Widget _fallback() {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: Color(0xFFE5E7EB),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.storefront_outlined,
        size: 22,
        color: Color(0xFF325A88),
      ),
    );
  }
}
