import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/models.dart';
import '../../shared/brand_widgets.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return RefreshIndicator(
          onRefresh: state.bootstrap,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              const BrandHeader(
                title: 'Curated Finds',
                subtitle: 'Handpicked pieces with the same Curated Store style.',
              ),
              const SizedBox(height: 14),
              TextField(
                onChanged: state.updateSearch,
                decoration: const InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: state.categories
                    .map(
                      (category) => ChoiceChip(
                        label: Text(category),
                        selected: state.selectedCategory == category,
                        onSelected: (_) => state.updateCategory(category),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ProductSort>(
                initialValue: state.sortBy,
                decoration: const InputDecoration(labelText: 'Sort'),
                items: const <DropdownMenuItem<ProductSort>>[
                  DropdownMenuItem(
                    value: ProductSort.newest,
                    child: Text('Newest'),
                  ),
                  DropdownMenuItem(
                    value: ProductSort.priceLowToHigh,
                    child: Text('Price: Low to High'),
                  ),
                  DropdownMenuItem(
                    value: ProductSort.priceHighToLow,
                    child: Text('Price: High to Low'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    state.updateSort(value);
                  }
                },
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _ModulePill(label: 'Featured', count: state.featuredProducts.length),
                  _ModulePill(label: 'New', count: state.newArrivals.length),
                  _ModulePill(label: 'Sale', count: state.saleProducts.length),
                  _ModulePill(label: 'Best Sellers', count: state.bestSellers.length),
                ],
              ),
              const SizedBox(height: 12),
              Text(state.statusMessage),
              const SizedBox(height: 12),
              ...state.filteredProducts.map(
                (product) => _ProductCard(
                  product: product,
                  onAdd: () => state.addProductToCart(product),
                  onToggleWishlist: () => state.toggleWishlist(product),
                  isWishlisted: state.isWishlisted(product),
                  onOpen: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ModulePill extends StatelessWidget {
  const _ModulePill({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white,
      ),
      child: Text('$label ($count)'),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onAdd,
    required this.onToggleWishlist,
    required this.isWishlisted,
    required this.onOpen,
  });

  final Product product;
  final VoidCallback onAdd;
  final VoidCallback onToggleWishlist;
  final bool isWishlisted;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Colors.white,
                  width: 84,
                  height: 84,
                  padding: const EdgeInsets.all(10),
                  child: SvgPicture.asset(product.imageAsset),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(product.category),
                    const SizedBox(height: 6),
                    Text(
                      product.shortDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    PriceTag(amount: product.price),
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  IconButton(
                    onPressed: onToggleWishlist,
                    icon: Icon(
                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                    ),
                  ),
                  IconButton(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add_shopping_cart),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          appBar: AppBar(title: Text(product.name)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SvgPicture.asset(product.imageAsset, height: 220),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                product.name,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              PriceTag(amount: product.price),
              const SizedBox(height: 12),
              Text(product.description),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: product.variants
                    .map((variant) => Chip(label: Text(variant)))
                    .toList(),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    product.tags.map((tag) => Chip(label: Text('#$tag'))).toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  state.addProductToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product.name} added to cart')),
                  );
                },
                child: const Text('Add to Cart'),
              ),
            ],
          ),
        );
      },
    );
  }
}
