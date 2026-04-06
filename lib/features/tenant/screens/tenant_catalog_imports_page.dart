import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_client.dart';
import '../data/tenant_catalog_imports_api.dart';
import '../state/tenant_catalog_imports_provider.dart';
import 'tenant_catalog_imports_screen.dart';

class TenantCatalogImportsPage extends StatefulWidget {
  const TenantCatalogImportsPage({super.key});

  @override
  State<TenantCatalogImportsPage> createState() =>
      _TenantCatalogImportsPageState();
}

class _TenantCatalogImportsPageState extends State<TenantCatalogImportsPage> {
  late final TenantCatalogImportsProvider _provider;

  @override
  void initState() {
    super.initState();
    final apiClient = context.read<ApiClient>();
    _provider = TenantCatalogImportsProvider(
      TenantCatalogImportsApi(apiClient.dio),
    );
    _provider.loadHistory();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TenantCatalogImportsProvider>.value(
      value: _provider,
      child: const TenantCatalogImportsScreen(),
    );
  }
}
