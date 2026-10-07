import 'package:flutter/material.dart';
import '../app_state.dart';
import '../strings.dart';
import 'order_card.dart';
import 'edit_order_screen.dart';
import 'settings_screen.dart';

class OrdersScreen extends StatelessWidget {
  final AppState app;
  const OrdersScreen(this.app, {super.key});

  void _edit(BuildContext context, dynamic order) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => EditOrderScreen(app, order)));
  }

  Future<void> _delete(BuildContext context, dynamic order) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(S.get('delete')),
        content: Text(S.get('delete_confirm')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(S.get('cancel'))),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: Text(S.get('yes_delete'))),
        ],
      ),
    );
    if (ok == true) await app.deleteOrder(order);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.get('app_title')),
        actions: [
          IconButton(
              tooltip: S.get('refresh'),
              onPressed: () => app.refresh(),
              icon: const Icon(Icons.refresh)),
          IconButton(
              tooltip: S.get('settings'),
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => SettingsScreen(app))),
              icon: const Icon(Icons.settings)),
        ],
      ),
      body: AnimatedBuilder(
        animation: app,
        builder: (context, _) {
          final list = app.filtered;
          return Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: SegmentedButton<FilterMode>(
                      segments: [
                        ButtonSegment(
                            value: FilterMode.today,
                            label: Text(S.get('today')),
                            icon: const Icon(Icons.today)),
                        ButtonSegment(
                            value: FilterMode.yesterday,
                            label: Text(S.get('yesterday')),
                            icon: const Icon(Icons.history)),
                        ButtonSegment(
                            value: FilterMode.all,
                            label: Text(S.get('all')),
                            icon: const Icon(Icons.list)),
                      ],
                      selected: {app.filter},
                      onSelectionChanged: (s) {
                        app.filter = s.first;
                        app.notifyListeners();
                      },
                    ),
                  ),
                  if (app.loading && app.orders.isEmpty)
                    const Expanded(
                        child: Center(child: CircularProgressIndicator()))
                  else if (list.isEmpty)
                    Expanded(
                        child: Center(child: Text(S.get('empty'))))
                  else
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: app.refresh,
                        child: ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (_, i) => OrderCard(
                            order: list[i],
                            onEdit: () => _edit(context, list[i]),
                            onDelete: () => _delete(context, list[i]),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (app.bannerOrder != null)
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: Material(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    elevation: 6,
                    child: SafeArea(
                      bottom: false,
                      child: ListTile(
                        dense: true,
                        leading: const Icon(Icons.notifications_active),
                        title: Text(
                            '${S.get('new_order')} — ${app.bannerOrder!.name}'),
                        subtitle: Text(app.bannerOrder!.itemsSummary),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            app.bannerOrder = null;
                            app.notifyListeners();
                          },
                        ),
                        onTap: () {
                          app.filter = FilterMode.all;
                          app.bannerOrder = null;
                          app.notifyListeners();
                        },
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
