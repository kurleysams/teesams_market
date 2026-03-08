class Endpoints {
  static const tenant = '/v1/tenant';
  static const catalog = '/v1/catalog';
  static const products = '/v1/products';
  static const createOrder = '/v1/orders';
  static String trackOrder(String orderNumber) =>
      '/v1/track/orders/$orderNumber';
  static const createPayment = '/v1/payments/create';
}
