import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/order.dart';
import '../strings.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const OrderCard({
    super.key,
    required this.order,
    required this.onEdit,
    required this.onDelete,
  });

  Future<void> _call(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: order.phone));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(S.get('copied'))));
    final uri = Uri.parse('tel:${order.phone.replaceAll(' ', '')}');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.name,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('${S.get('phone')}: ${order.phone}',
                      style: Theme.of(context).textTheme.bodySmall),
                  Text(order.address,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(order.itemsSummary,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600)),
                  if (order.price.isNotEmpty || order.status.isNotEmpty)
                    Text('${order.price}  •  ${order.status}',
                        style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              onSelected: (v) {
                if (v == 'edit') onEdit();
                if (v == 'delete') onDelete();
                if (v == 'call') _call(context);
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit',
                    child: ListTile(dense: true,
                        leading: const Icon(Icons.edit, size: 18),
                        title: Text(S.get('edit')))),
                PopupMenuItem(value: 'call',
                    child: ListTile(dense: true,
                        leading: const Icon(Icons.call, size: 18),
                        title: Text(S.get('call')))),
                PopupMenuItem(value: 'delete',
                    child: ListTile(dense: true,
                        leading: const Icon(Icons.delete, size: 18,
                            color: Colors.red),
                        title: Text(S.get('delete'),
                            style: const TextStyle(color: Colors.red)))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
