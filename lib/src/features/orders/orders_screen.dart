import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../shared/brand_widgets.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            const BrandHeader(
              title: 'Orders',
              subtitle: 'Track created and pending-sync orders.',
            ),
            const SizedBox(height: 16),
            if (state.orders.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No orders yet.'),
                ),
              ),
            ...state.orders.map(
              (order) => Card(
                child: ListTile(
                  title: Text('Order #${order.id}'),
                  subtitle: Text(
                    '${DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt)}\nStatus: ${order.status}',
                  ),
                  isThreeLine: true,
                  trailing: PriceTag(amount: order.total),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
