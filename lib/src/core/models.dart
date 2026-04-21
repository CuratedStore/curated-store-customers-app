class Product {
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageAsset,
    required this.category,
    required this.stock,
    this.tags = const <String>[],
    this.variants = const <String>[],
    this.shortDescription = '',
    this.description = '',
    this.isFeatured = false,
    this.isNewArrival = false,
    this.isSale = false,
    this.isBestSeller = false,
  });

  final int id;
  final String name;
  final double price;
  final String imageAsset;
  final String category;
  final int stock;
  final List<String> tags;
  final List<String> variants;
  final String shortDescription;
  final String description;
  final bool isFeatured;
  final bool isNewArrival;
  final bool isSale;
  final bool isBestSeller;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      name: '${json['name'] ?? 'Product'}',
      price: double.tryParse('${json['price'] ?? 0}') ?? 0,
      imageAsset: 'assets/images/products/artisan-1.svg',
      category: '${json['category'] ?? 'General'}',
      stock: int.tryParse('${json['stock'] ?? 10}') ?? 10,
      tags: (json['tags'] as List<dynamic>? ?? const <dynamic>[])
          .map((e) => '$e')
          .toList(),
      variants: (json['variants'] as List<dynamic>? ?? const <dynamic>[])
          .map((e) => '$e')
          .toList(),
      shortDescription: '${json['short_description'] ?? json['description'] ?? ''}',
      description: '${json['description'] ?? json['short_description'] ?? ''}',
      isFeatured: json['featured'] == true,
      isNewArrival: json['new_arrival'] == true,
      isSale: json['sale'] == true,
      isBestSeller: json['best_seller'] == true,
    );
  }
}

class CartItem {
  CartItem({required this.product, this.quantity = 1});

  final Product product;
  int quantity;

  double get lineTotal => quantity * product.price;
}

class Address {
  Address({
    required this.id,
    required this.label,
    required this.line1,
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
  });

  final int id;
  final String label;
  final String line1;
  final String city;
  final String state;
  final String pincode;
  bool isDefault;
}

class CustomerProfile {
  CustomerProfile({
    required this.name,
    required this.email,
    required this.phone,
  });

  String name;
  String email;
  String phone;
}

class Preferences {
  Preferences({
    this.currency = 'INR',
    this.language = 'en',
    this.emailNotifications = true,
    this.smsNotifications = true,
  });

  String currency;
  String language;
  bool emailNotifications;
  bool smsNotifications;
}

class OrderEvent {
  OrderEvent({required this.title, required this.time});

  final String title;
  final DateTime time;
}

class OrderSummary {
  OrderSummary({
    required this.id,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.items,
    required this.shippingAddress,
    required this.events,
    this.requestStatus,
  });

  final int id;
  final double total;
  final String status;
  final DateTime createdAt;
  final List<CartItem> items;
  final Address shippingAddress;
  final List<OrderEvent> events;
  String? requestStatus;
}
