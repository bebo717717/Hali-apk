import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app_state.dart';
import 'order.dart';
import '../strings.dart';

class EditOrderScreen extends StatefulWidget {
  final AppState app;
  final Order order;
  const EditOrderScreen(this.app, this.order, {super.key});
  @override
  State<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  late final TextEditingController _name, _phone, _address, _price, _status,
      _notes, _date;
  late List<MapEntry<String, int>> _items;

  @override
  void initState() {
    super.initState();
    final o = widget.order;
    _name = TextEditingController(text: o.name);
    _phone = TextEditingController(text: o.phone);
    _address = TextEditingController(text: o.address);
    _price = TextEditingController(text: o.price);
    _status = TextEditingController(text: o.status);
    _notes = TextEditingController(text: o.notes);
    _date = TextEditingController(
        text: o.date.isNotEmpty
            ? o.date
            : DateFormat('yyyy-MM-dd').format(DateTime.now()));
    _items = o.items.entries.map((e) => MapEntry(e.key, e.value)).toList();
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _address, _price, _status, _notes, _date]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final o = widget.order
      ..name = _name.text.trim()
      ..phone = _phone.text.trim()
      ..address = _address.text.trim()
      ..price = _price.text.trim()
      ..status = _status.text.trim()
      ..notes = _notes.text.trim()
      ..date = _date.text.trim()
      ..items = {for (final e in _items) e.key: e.value};
    await widget.app.saveOrder(o);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${S.get('edit')} — ${widget.order.name}'),
        actions: [
          IconButton(
            tooltip: S.get('save'),
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field(_name, S.get('name'), Icons.person),
          _field(_phone, S.get('phone'), Icons.phone,
              keyboard: TextInputType.phone),
          _field(_address, S.get('address'), Icons.location_on),
          _field(_date, S.get('date'), Icons.calendar_today),
          _field(_price, S.get('price'), Icons.payments,
              keyboard: TextInputType.number),
          _field(_status, S.get('status'), Icons.flag),
          _field(_notes, S.get('notes'), Icons.notes),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(S.get('items'),
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              TextButton.icon(
                onPressed: () => setState(() =>
                    _items.add(MapEntry(S.get('item_name'), 1))),
                icon: const Icon(Icons.add, size: 18),
                label: Text(S.get('add_item')),
              ),
            ],
          ),
          ..._items.asMap().entries.map((e) {
            final i = e.key;
            final nameCtrl = TextEditingController(text: e.value.key);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: S.get('item_name'),
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (v) => _items[i] = MapEntry(v, _items[i].value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => setState(() {
                      if (_items[i].value > 1) {
                        _items[i] = MapEntry(_items[i].key, _items[i].value - 1);
                      }
                    }),
                  ),
                  Text('${_items[i].value}'),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => setState(() {
                      _items[i] = MapEntry(_items[i].key, _items[i].value + 1);
                    }),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => setState(() => _items.removeAt(i)),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(S.get('save')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
