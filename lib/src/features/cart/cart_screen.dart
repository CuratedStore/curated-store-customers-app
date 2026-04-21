import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../shared/brand_widgets.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            const BrandHeader(
              title: 'Your Cart',
              subtitle: 'Cart is synced with API when endpoints are available.',
            ),
            const SizedBox(height: 16),
            if (state.cart.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Your cart is empty.'),
                ),
              ),
            ...state.cart.map(
              (item) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              item.product.name,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text('Stock: ${item.product.stock}'),
                            const SizedBox(height: 8),
                            Row(
                              children: <Widget>[
                                IconButton(
                                  onPressed: () => state.updateCartQuantity(
                                    item,
                                    item.quantity - 1,
                                  ),
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                                Text('${item.quantity}'),
                                IconButton(
                                  onPressed: () => state.updateCartQuantity(
                                    item,
                                    item.quantity + 1,
                                  ),
                                  icon: const Icon(Icons.add_circle_outline),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          PriceTag(amount: item.lineTotal),
                          IconButton(
                            onPressed: () => state.removeFromCart(item),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Total: INR ${state.cartTotal.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: state.selectedPaymentMethod,
                      decoration:
                          const InputDecoration(labelText: 'Payment Method'),
                      items: const <DropdownMenuItem<String>>[
                        DropdownMenuItem(value: 'COD', child: Text('Cash on Delivery')),
                        DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                        DropdownMenuItem(value: 'Card', child: Text('Card')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          state.updatePaymentMethod(value);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: state.createOrderFromCart,
                      child: const Text('Create Order'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
