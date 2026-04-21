class Product {
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageAsset,
    this.shortDescription = '',
  });

  final int id;
  final String name;
  final double price;
  final String imageAsset;
  final String shortDescription;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      name: '${json['name'] ?? 'Product'}',
      price: double.tryParse('${json['price'] ?? 0}') ?? 0,
      imageAsset: 'assets/images/products/artisan-1.svg',
      shortDescription: '${json['short_description'] ?? json['description'] ?? ''}',
    );
  }
}

class CartItem {
  CartItem({required this.product, this.quantity = 1});

  final Product product;
  int quantity;

  double get lineTotal => quantity * product.price;
}

class OrderSummary {
  OrderSummary({
    required this.id,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final double total;
  final String status;
  final DateTime createdAt;
}
