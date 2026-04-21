import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../shared/brand_widgets.dart';
import 'catalog_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final items = state.wishlistProducts;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            const BrandHeader(
              title: 'Wishlist',
              subtitle: 'Save favorites and move them to cart anytime.',
            ),
            const SizedBox(height: 14),
            if (items.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: Text('No wishlist items yet.'),
                ),
              ),
            ...items.map(
              (product) => Card(
                child: ListTile(
                  title: Text(product.name),
                  subtitle: Text(product.shortDescription),
                  trailing: Wrap(
                    spacing: 6,
                    children: <Widget>[
                      IconButton(
                        onPressed: () => state.toggleWishlist(product),
                        icon: const Icon(Icons.favorite),
                      ),
                      IconButton(
                        onPressed: () => state.addProductToCart(product),
                        icon: const Icon(Icons.add_shopping_cart),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
