import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  AppState({ApiClient? apiClient}) : _api = apiClient ?? ApiClient() {
    _seedLocalProducts();
  }

  final ApiClient _api;

  bool loading = false;
  String statusMessage = 'Ready';
  String? authToken;
  bool isAuthenticated = false;
  bool otpRequested = false;
  String pendingEmail = '';
  String pendingPassword = '';

  final List<Product> products = <Product>[];
  final List<CartItem> cart = <CartItem>[];
  final List<OrderSummary> orders = <OrderSummary>[];

  double get cartTotal =>
      cart.fold<double>(0, (sum, item) => sum + item.lineTotal);

  Future<void> bootstrap() async {
    loading = true;
    notifyListeners();

    final health = await _api.getHealth();
    statusMessage = 'API health: ${health.message}';

    final productResponse = await _api.getProducts(token: authToken);
    if (productResponse.ok && productResponse.data is List) {
      final remote = (productResponse.data as List)
          .whereType<Map<String, dynamic>>()
          .map(Product.fromJson)
          .toList();
      if (remote.isNotEmpty) {
        products
          ..clear()
          ..addAll(remote);
      }
    }

    if (productResponse.scaffolded || !productResponse.ok) {
      statusMessage =
          'Connected. Some endpoints are scaffolded on backend, using local preview data.';
    }

    loading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    loading = true;
    notifyListeners();

    final result = await _api.login(email, password);
    if (result.ok && result.data is Map<String, dynamic>) {
      authToken = '${(result.data as Map<String, dynamic>)['token'] ?? ''}';
      statusMessage = 'Login successful';
    } else {
      statusMessage = 'Login response: ${result.message}';
    }

    loading = false;
    notifyListeners();
  }

  Future<void> requestLoginOtp(String email, String password) async {
    loading = true;
    notifyListeners();

    pendingEmail = email;
    pendingPassword = password;

    final result = await _api.login(email, password);
    otpRequested = true;
    statusMessage = result.scaffolded
        ? 'OTP requested. Backend is scaffolded, use any 6 digit OTP for preview.'
        : 'OTP requested: ${result.message}';

    loading = false;
    notifyListeners();
  }

  Future<void> verifyOtpAndLogin(String otp) async {
    if (pendingEmail.isEmpty || pendingPassword.isEmpty) {
      statusMessage = 'Enter email and password first.';
      notifyListeners();
      return;
    }

    loading = true;
    notifyListeners();

    final result = await _api.loginWithOtp(
      email: pendingEmail,
      password: pendingPassword,
      otp: otp,
    );

    if (result.ok && result.data is Map<String, dynamic>) {
      authToken = '${(result.data as Map<String, dynamic>)['token'] ?? ''}';
      isAuthenticated = true;
      otpRequested = false;
      statusMessage = 'Login successful';
    } else {
      // Keep preview flow usable when backend endpoint is scaffolded.
      if (result.scaffolded && otp.length >= 4) {
        isAuthenticated = true;
        otpRequested = false;
        statusMessage = 'Login preview successful (scaffold backend).';
      } else {
        statusMessage = 'OTP verification failed: ${result.message}';
      }
    }

    loading = false;
    notifyListeners();
  }

  Future<void> loginUsingGoogle() async {
    loading = true;
    notifyListeners();

    final result = await _api.loginWithGoogle(idToken: 'mobile-google-token');
    if (result.ok) {
      isAuthenticated = true;
      statusMessage = 'Google login successful';
    } else if (result.scaffolded) {
      isAuthenticated = true;
      statusMessage = 'Google login preview enabled (backend scaffolded).';
    } else {
      statusMessage = 'Google login failed: ${result.message}';
    }

    loading = false;
    notifyListeners();
  }

  void signOut() {
    authToken = null;
    isAuthenticated = false;
    otpRequested = false;
    pendingEmail = '';
    pendingPassword = '';
    statusMessage = 'Signed out';
    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    loading = true;
    notifyListeners();

    final result = await _api.register(name, email, password);
    statusMessage = 'Register response: ${result.message}';

    loading = false;
    notifyListeners();
  }

  Future<void> addProductToCart(Product product) async {
    final existing = cart.where((item) => item.product.id == product.id).toList();
    if (existing.isEmpty) {
      cart.add(CartItem(product: product));
    } else {
      existing.first.quantity += 1;
    }
    notifyListeners();

    final result = await _api.addToCart(productId: product.id, token: authToken);
    if (!result.ok) {
      statusMessage = 'Cart API: ${result.message}';
      notifyListeners();
    }
  }

  void removeFromCart(CartItem item) {
    cart.remove(item);
    notifyListeners();
  }

  Future<void> createOrderFromCart() async {
    if (cart.isEmpty) {
      statusMessage = 'Cart is empty.';
      notifyListeners();
      return;
    }

    final total = cartTotal;
    final result = await _api.createOrder(token: authToken);

    orders.insert(
      0,
      OrderSummary(
        id: DateTime.now().millisecondsSinceEpoch,
        total: total,
        status: result.ok ? 'created' : 'pending-sync',
        createdAt: DateTime.now(),
      ),
    );
    cart.clear();

    statusMessage = result.ok
        ? 'Order created successfully.'
        : 'Order stored locally. API: ${result.message}';
    notifyListeners();
  }

  void _seedLocalProducts() {
    if (products.isNotEmpty) {
      return;
    }
    products.addAll(<Product>[
      Product(
        id: 1,
        name: 'Artisan Bowl',
        price: 899,
        imageAsset: 'assets/images/products/artisan-1.svg',
        shortDescription: 'Handcrafted ceramic with a matte finish.',
      ),
      Product(
        id: 2,
        name: 'Woven Basket',
        price: 1299,
        imageAsset: 'assets/images/products/artisan-2.svg',
        shortDescription: 'Natural fiber basket for decor and storage.',
      ),
      Product(
        id: 3,
        name: 'Clay Vase',
        price: 1599,
        imageAsset: 'assets/images/products/artisan-3.svg',
        shortDescription: 'Minimal silhouette with textured detailing.',
      ),
      Product(
        id: 4,
        name: 'Wooden Platter',
        price: 749,
        imageAsset: 'assets/images/products/artisan-4.svg',
        shortDescription: 'Solid wood serving platter for daily use.',
      ),
    ]);
  }
}
