import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/models.dart';
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
                    '${DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt)}\nStatus: ${order.status}${order.requestStatus != null ? '\n${order.requestStatus}' : ''}',
                  ),
                  isThreeLine: true,
                  trailing: PriceTag(amount: order.total),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => OrderDetailScreen(order: order),
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

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.order});

  final OrderSummary order;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          appBar: AppBar(title: Text('Order #${order.id}')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Status: ${order.status}'),
                      const SizedBox(height: 8),
                      Text(
                        'Shipping: ${order.shippingAddress.label}, ${order.shippingAddress.line1}, ${order.shippingAddress.city}',
                      ),
                      const SizedBox(height: 8),
                      Text('Total: INR ${order.total.toStringAsFixed(0)}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Items',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...order.items.map(
                (item) => Card(
                  child: ListTile(
                    title: Text(item.product.name),
                    subtitle: Text('Qty: ${item.quantity}'),
                    trailing: PriceTag(amount: item.lineTotal),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Timeline',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...order.events.map(
                (event) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.timeline, size: 18),
                  title: Text(event.title),
                  subtitle: Text(DateFormat('dd MMM yyyy, hh:mm a').format(event.time)),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () => state.downloadInvoice(order),
                    child: const Text('Download Invoice'),
                  ),
                  OutlinedButton(
                    onPressed: () => _askReasonAndSubmit(
                      context,
                      title: 'Cancel Order',
                      onSubmit: (reason) => state.requestCancelOrder(order, reason),
                    ),
                    child: const Text('Cancel Request'),
                  ),
                  OutlinedButton(
                    onPressed: () => _askReasonAndSubmit(
                      context,
                      title: 'Return Order',
                      onSubmit: (reason) => state.requestReturnOrder(order, reason),
                    ),
                    child: const Text('Return Request'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _askReasonAndSubmit(
    BuildContext context, {
    required String title,
    required void Function(String reason) onSubmit,
  }) async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter reason'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (result == true && controller.text.trim().isNotEmpty) {
      onSubmit(controller.text.trim());
    }
  }
}
