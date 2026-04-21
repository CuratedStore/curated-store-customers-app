class AppConfig {
  static const String appName = 'Curated Store - Customers';
  static const String baseUrl = 'https://customers-api.curatedstore.in';

  // Routes come from Laravel routes/api.php where an additional prefix('api') is used.
  static const String healthPath = '/api/health';
  static const String authRegisterPath = '/api/api/auth/register';
  static const String authLoginPath = '/api/api/auth/login';
  static const String authLogoutPath = '/api/api/auth/logout';
  static const String productsPath = '/api/api/products';
  static const String categoriesPath = '/api/api/categories';
  static const String cartPath = '/api/api/cart';
  static const String cartAddPath = '/api/api/cart/add';
  static const String ordersPath = '/api/api/orders';
  static const String profilePath = '/api/api/account/profile';
}