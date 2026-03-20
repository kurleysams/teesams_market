class Endpoints {
  static const tenant = 'v1/tenant';
  static const tenants = 'v1/tenants';
  static const catalog = 'v1/catalog';
  static const categories = 'v1/categories';
  static const products = 'v1/products';

  static const createOrder = 'v1/orders';
  static String order(int orderId) => 'v1/orders/$orderId';

  static const myOrders = 'v1/me/orders';
  static String myOrderDetails(int orderId) => 'v1/me/orders/$orderId';

  static const createPayment = 'v1/payments/create';

  static String trackOrder(String orderNumber) =>
      'v1/track/orders/$orderNumber';
}
