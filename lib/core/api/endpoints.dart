class Endpoints {
  // Public / storefront
  static const tenant = 'v1/tenant';
  static const tenants = 'v1/tenants';
  static const catalog = 'v1/catalog';
  static const categories = 'v1/categories';
  static const products = 'v1/products';

  // Customer auth
  static const authRegister = 'v1/auth/register';
  static const authLogin = 'v1/auth/login';
  static const authMe = 'v1/auth/me';
  static const authLogout = 'v1/auth/logout';

  static const myProfile = 'v1/me/profile';
  static const appBootstrap = 'v1/app/bootstrap';

  // Customer orders / payments
  static const createOrder = 'v1/orders';
  static String order(int orderId) => 'v1/orders/$orderId';

  static const myOrders = 'v1/me/orders';
  static String myOrderDetails(int orderId) => 'v1/me/orders/$orderId';

  static const createPayment = 'v1/payments/create';

  static String trackOrder(String orderNumber) =>
      'v1/track/orders/$orderNumber';

  // Tenant / seller portal catalog
  static const tenantProducts = 'v1/tenant/products';

  static String tenantProductAvailability(int productId) =>
      'v1/tenant/products/$productId/availability';

  static String tenantVariantAvailability(int variantId) =>
      'v1/tenant/variants/$variantId/availability';

  static const tenantVariantAvailabilityBulk =
      'v1/tenant/variants/availability/bulk';

  // Tenant / seller portal dashboard + store
  static const tenantDashboard = 'v1/tenant/dashboard';
  static const tenantStore = 'v1/tenant/store';
  static const tenantStoreStatus = 'v1/tenant/store/status';

  // Tenant / seller portal orders
  static const tenantOrders = 'v1/tenant/orders';

  static String tenantOrderDetails(int orderId) => 'v1/tenant/orders/$orderId';

  static String tenantOrderTransition(int orderId) =>
      'v1/tenant/orders/$orderId/transition';

  static String tenantOrderCancel(int orderId) =>
      'v1/tenant/orders/$orderId/cancel';

  // NEW: refund endpoint
  static String tenantOrderRefund(int orderId) =>
      'v1/tenant/orders/$orderId/refund';

  // NEW: order comment / internal note / timeline comment
  static String tenantOrderComment(int orderId) =>
      'v1/tenant/orders/$orderId/comment';

  // Seller / onboarding auth
  static const sellerRegister = 'v1/seller/auth/register';
  static const sellerLogin = 'v1/seller/auth/login';
  static const sellerMe = 'v1/seller/auth/me';
  static const sellerLogout = 'v1/seller/auth/logout';

  // Seller onboarding
  static const sellerOnboardingStatus = 'v1/seller/onboarding/status';
  static const sellerBusinessDetails = 'v1/seller/onboarding/business';
  static const sellerStoreProfile = 'v1/seller/onboarding/store-profile';
  static const sellerOperations = 'v1/seller/onboarding/operations';
  static const sellerDocuments = 'v1/seller/onboarding/documents';
  static const sellerCatalogSetup = 'v1/seller/onboarding/catalog';
  static const sellerSubmitForReview = 'v1/seller/onboarding/submit';

  // Seller Stripe
  static const sellerStripeStatus = 'v1/seller/stripe/status';
  static const sellerStripeConnect = 'v1/seller/stripe/connect';
  static const sellerStripeRefresh = 'v1/seller/stripe/refresh';

  // Seller portal operational endpoints
  static const sellerTenantDashboard = 'v1/seller/tenant/dashboard';
  static const sellerTenantOrders = 'v1/seller/tenant/orders';

  // Seller catalog imports
  static const sellerCatalogImportTemplate =
      'v1/seller/catalog/import-template';
  static const sellerCatalogExport = 'v1/seller/catalog/export';

  static const sellerCatalogImportValidate =
      'v1/seller/catalog/import/validate';
  static const sellerCatalogImportConfirm = 'v1/seller/catalog/import/confirm';
  static const sellerCatalogImportRevalidate =
      'v1/seller/catalog/import/revalidate';

  static const sellerCatalogBulkUpdateValidate =
      'v1/seller/catalog/bulk-update/validate';
  static const sellerCatalogBulkUpdateConfirm =
      'v1/seller/catalog/bulk-update/confirm';

  static const sellerCatalogImportHistory = 'v1/seller/catalog/import-history';

  static String sellerCatalogImportHistoryItem(int importId) =>
      'v1/seller/catalog/import-history/$importId';

  static String sellerCatalogImportCancel(int importId) =>
      'v1/seller/catalog/import-history/$importId/cancel';

  static String sellerCatalogImportErrorsCsv(int importId) =>
      'v1/seller/catalog/import-history/$importId/errors.csv';

  // Admin tenant review
  static String adminTenantReview(int tenantId) => 'v1/admin/tenants/$tenantId';

  static String adminTenantApprove(int tenantId) =>
      'v1/admin/tenants/$tenantId/approve';

  static String adminTenantReject(int tenantId) =>
      'v1/admin/tenants/$tenantId/reject';

  static String sellerTenantOrderDetails(int orderId) =>
      'v1/seller/tenant/orders/$orderId';
  static String sellerTenantOrderTransition(int orderId) =>
      'v1/seller/tenant/orders/$orderId/transition';
  static String sellerTenantOrderCancel(int orderId) =>
      'v1/seller/tenant/orders/$orderId/cancel';
  static String sellerTenantOrderRefund(int orderId) =>
      'v1/seller/tenant/orders/$orderId/refund';

  static const sellerTenantStore = 'v1/seller/tenant/store';
  static const sellerTenantStoreStatus = 'v1/seller/tenant/store/status';

  static const sellerTenantProducts = 'v1/seller/tenant/products';
  static String sellerTenantVariantAvailability(int variantId) =>
      'v1/tenant/variants/$variantId/availability';
  static const sellerTenantVariantAvailabilityBulk =
      'v1/tenant/variants/availability/bulk';
}
