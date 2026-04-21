import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'models.dart';

enum ProductSort { newest, priceLowToHigh, priceHighToLow }

class AppState extends ChangeNotifier {
  AppState({ApiClient? apiClient}) : _api = apiClient ?? ApiClient() {
    _seedLocalProducts();
    _seedLocalProfileData();
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
  final Set<int> wishlistIds = <int>{};
  final List<Address> addresses = <Address>[];
  CustomerProfile profile = CustomerProfile(
    name: 'Customer',
    email: 'customer@curatedstore.in',
    phone: '',
  );
  Preferences preferences = Preferences();

  String searchQuery = '';
  String selectedCategory = 'All';
  ProductSort sortBy = ProductSort.newest;
  String selectedPaymentMethod = 'COD';

  double get cartTotal =>
      cart.fold<double>(0, (sum, item) => sum + item.lineTotal);

  List<String> get categories {
    final set = <String>{'All'};
    for (final product in products) {
      set.add(product.category);
    }
    return set.toList();
  }

  List<Product> get featuredProducts =>
      products.where((p) => p.isFeatured).toList(growable: false);
  List<Product> get newArrivals =>
      products.where((p) => p.isNewArrival).toList(growable: false);
  List<Product> get saleProducts =>
      products.where((p) => p.isSale).toList(growable: false);
  List<Product> get bestSellers =>
      products.where((p) => p.isBestSeller).toList(growable: false);

  List<Product> get wishlistProducts =>
      products.where((p) => wishlistIds.contains(p.id)).toList(growable: false);

  List<Product> get filteredProducts {
    final query = searchQuery.trim().toLowerCase();
    final filtered = products.where((product) {
      final categoryMatch =
          selectedCategory == 'All' || product.category == selectedCategory;
      if (!categoryMatch) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      return product.name.toLowerCase().contains(query) ||
          product.shortDescription.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query);
    }).toList();

    filtered.sort((a, b) {
      switch (sortBy) {
        case ProductSort.priceLowToHigh:
          return a.price.compareTo(b.price);
        case ProductSort.priceHighToLow:
          return b.price.compareTo(a.price);
        case ProductSort.newest:
          return b.id.compareTo(a.id);
      }
    });

    return filtered;
  }

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

  void updateSearch(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void updateCategory(String value) {
    selectedCategory = value;
    notifyListeners();
  }

  void updateSort(ProductSort value) {
    sortBy = value;
    notifyListeners();
  }

  void updatePaymentMethod(String value) {
    selectedPaymentMethod = value;
    notifyListeners();
  }

  bool isWishlisted(Product product) => wishlistIds.contains(product.id);

  void toggleWishlist(Product product) {
    if (wishlistIds.contains(product.id)) {
      wishlistIds.remove(product.id);
    } else {
      wishlistIds.add(product.id);
    }
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
      final next = existing.first.quantity + 1;
      if (next > product.stock) {
        statusMessage = 'Cannot exceed available stock for ${product.name}.';
        notifyListeners();
        return;
      }
      existing.first.quantity = next;
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

  void updateCartQuantity(CartItem item, int nextQty) {
    if (nextQty <= 0) {
      cart.remove(item);
      notifyListeners();
      return;
    }
    if (nextQty > item.product.stock) {
      statusMessage = 'Cannot exceed available stock for ${item.product.name}.';
      notifyListeners();
      return;
    }
    item.quantity = nextQty;
    notifyListeners();
  }

  Future<void> createOrderFromCart() async {
    if (cart.isEmpty) {
      statusMessage = 'Cart is empty.';
      notifyListeners();
      return;
    }

    final total = cartTotal;
    final defaultAddress =
        addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
    final result = await _api.createOrder(token: authToken);

    orders.insert(
      0,
      OrderSummary(
        id: DateTime.now().millisecondsSinceEpoch,
        total: total,
        status: result.ok ? 'created' : 'pending-sync',
        createdAt: DateTime.now(),
        items: cart
            .map((item) => CartItem(product: item.product, quantity: item.quantity))
            .toList(),
        shippingAddress: defaultAddress,
        events: <OrderEvent>[
          OrderEvent(title: 'Order Created', time: DateTime.now()),
          OrderEvent(
            title: 'Payment Method: $selectedPaymentMethod',
            time: DateTime.now(),
          ),
        ],
      ),
    );
    cart.clear();

    statusMessage = result.ok
        ? 'Order created successfully.'
        : 'Order stored locally. API: ${result.message}';
    notifyListeners();
  }

  void requestCancelOrder(OrderSummary order, String reason) {
    if (order.requestStatus != null) {
      statusMessage = 'A request is already pending for this order.';
      notifyListeners();
      return;
    }
    order.requestStatus = 'Cancel requested: $reason';
    order.events.add(OrderEvent(title: 'Cancel Requested', time: DateTime.now()));
    statusMessage = 'Cancel request submitted.';
    notifyListeners();
  }

  void requestReturnOrder(OrderSummary order, String reason) {
    if (order.requestStatus != null) {
      statusMessage = 'A request is already pending for this order.';
      notifyListeners();
      return;
    }
    order.requestStatus = 'Return requested: $reason';
    order.events.add(OrderEvent(title: 'Return Requested', time: DateTime.now()));
    statusMessage = 'Return request submitted.';
    notifyListeners();
  }

  void downloadInvoice(OrderSummary order) {
    statusMessage = 'Invoice download queued for order #${order.id}';
    notifyListeners();
  }

  void updateProfile({
    required String name,
    required String email,
    required String phone,
  }) {
    profile
      ..name = name
      ..email = email
      ..phone = phone;
    statusMessage = 'Profile updated.';
    notifyListeners();
  }

  void addAddress({
    required String label,
    required String line1,
    required String city,
    required String state,
    required String pincode,
  }) {
    final nextId = DateTime.now().millisecondsSinceEpoch;
    final isFirst = addresses.isEmpty;
    addresses.add(
      Address(
        id: nextId,
        label: label,
        line1: line1,
        city: city,
        state: state,
        pincode: pincode,
        isDefault: isFirst,
      ),
    );
    statusMessage = 'Address added.';
    notifyListeners();
  }

  void deleteAddress(Address address) {
    final removedDefault = address.isDefault;
    addresses.removeWhere((a) => a.id == address.id);
    if (removedDefault && addresses.isNotEmpty) {
      addresses.first.isDefault = true;
    }
    statusMessage = 'Address deleted.';
    notifyListeners();
  }

  void setDefaultAddress(Address address) {
    for (final item in addresses) {
      item.isDefault = item.id == address.id;
    }
    statusMessage = 'Default address updated.';
    notifyListeners();
  }

  void updatePreferences({
    required String currency,
    required String language,
    required bool emailNotifications,
    required bool smsNotifications,
  }) {
    preferences
      ..currency = currency
      ..language = language
      ..emailNotifications = emailNotifications
      ..smsNotifications = smsNotifications;
    statusMessage = 'Preferences saved.';
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
        category: 'Home Decor',
        stock: 10,
        tags: const <String>['ceramic', 'handmade'],
        variants: const <String>['Small', 'Large'],
        shortDescription: 'Handcrafted ceramic with a matte finish.',
        description:
            'A handcrafted ceramic bowl with subtle texture, perfect for table styling.',
        isFeatured: true,
        isNewArrival: true,
      ),
      Product(
        id: 2,
        name: 'Woven Basket',
        price: 1299,
        imageAsset: 'assets/images/products/artisan-2.svg',
        category: 'Storage',
        stock: 6,
        tags: const <String>['woven', 'natural'],
        variants: const <String>['Natural', 'Walnut'],
        shortDescription: 'Natural fiber basket for decor and storage.',
        description:
            'Lightweight woven basket crafted for everyday storage and warm interiors.',
        isBestSeller: true,
      ),
      Product(
        id: 3,
        name: 'Clay Vase',
        price: 1599,
        imageAsset: 'assets/images/products/artisan-3.svg',
        category: 'Home Decor',
        stock: 8,
        tags: const <String>['vase', 'minimal'],
        variants: const <String>['Sand', 'Stone'],
        shortDescription: 'Minimal silhouette with textured detailing.',
        description: 'A statement clay vase with a clean shape and rich artisan finish.',
        isSale: true,
      ),
      Product(
        id: 4,
        name: 'Wooden Platter',
        price: 749,
        imageAsset: 'assets/images/products/artisan-4.svg',
        category: 'Kitchen',
        stock: 12,
        tags: const <String>['wood', 'serveware'],
        variants: const <String>['Round', 'Oval'],
        shortDescription: 'Solid wood serving platter for daily use.',
        description: 'Durable wooden platter designed for serving and display.',
        isFeatured: true,
        isBestSeller: true,
      ),
      Product(
        id: 5,
        name: 'Textured Lamp Shade',
        price: 1799,
        imageAsset: 'assets/images/products/artisan-1.svg',
        category: 'Lighting',
        stock: 4,
        tags: const <String>['lighting', 'fabric'],
        variants: const <String>['Beige', 'Ivory'],
        shortDescription: 'Soft textured shade for ambient lighting.',
        description: 'Premium fabric lamp shade that adds warmth to modern interiors.',
        isNewArrival: true,
      ),
      Product(
        id: 6,
        name: 'Handloom Cushion Cover',
        price: 599,
        imageAsset: 'assets/images/products/artisan-2.svg',
        category: 'Textiles',
        stock: 15,
        tags: const <String>['handloom', 'cushion'],
        variants: const <String>['18x18', '20x20'],
        shortDescription: 'Handwoven cotton cushion with subtle patterns.',
        description: 'Handloom woven cushion cover for sofas, chairs and beds.',
        isSale: true,
      ),
    ]);
  }

  void _seedLocalProfileData() {
    addresses.addAll(<Address>[
      Address(
        id: 1,
        label: 'Home',
        line1: '42 Lakeview Residency',
        city: 'Bengaluru',
        state: 'Karnataka',
        pincode: '560001',
        isDefault: true,
      ),
      Address(
        id: 2,
        label: 'Office',
        line1: '91 MG Road',
        city: 'Bengaluru',
        state: 'Karnataka',
        pincode: '560025',
      ),
    ]);
  }
}
