class Endpoints {
  static const tenant = 'v1/tenant';
  static const tenants = 'v1/tenants';
  static const catalog = 'v1/catalog';
  static const categories = 'v1/categories';
  static const products = 'v1/products';

  static const authRegister = 'v1/auth/register';
  static const authLogin = 'v1/auth/login';
  static const authMe = 'v1/auth/me';
  static const authLogout = 'v1/auth/logout';

  static const myProfile = 'v1/me/profile';

  static const appBootstrap = 'v1/app/bootstrap';

  static const createOrder = 'v1/orders';
  static String order(int orderId) => 'v1/orders/$orderId';

  static const myOrders = 'v1/me/orders';
  static String myOrderDetails(int orderId) => 'v1/me/orders/$orderId';

  static const createPayment = 'v1/payments/create';

  static String trackOrder(String orderNumber) =>
      'v1/track/orders/$orderNumber';

  static const tenantProducts = 'v1/tenant/products';
  static String tenantVariantAvailability(int variantId) =>
      'v1/tenant/variants/$variantId/availability';

  static const tenantDashboard = 'v1/tenant/dashboard';
  static const tenantOrders = 'v1/tenant/orders';
  static String tenantOrderDetails(int orderId) => 'v1/tenant/orders/$orderId';
  static String tenantOrderTransition(int orderId) =>
      'v1/tenant/orders/$orderId/transition';
  static const tenantStore = 'v1/tenant/store';
  static const tenantStoreStatus = 'v1/tenant/store/status';

  static String tenantProductAvailability(int productId) =>
      'v1/tenant/products/$productId/availability';
}
