class TenantConfig {
  final String slug;
  final String displayName;

  const TenantConfig({required this.slug, required this.displayName});
}

const supportedTenants = <TenantConfig>[
  TenantConfig(slug: 'fishseafoods', displayName: 'Fish & Sea Foods'),
  TenantConfig(slug: 'default', displayName: 'Default Store'),
];
