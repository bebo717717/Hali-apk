import 'dart:convert';

class Order {
  final String id;
  final int row;
  String date, name, phone, address, price, status, notes;
  Map<String, int> items;

  Order({
    required this.id,
    required this.row,
    this.date = '',
    this.name = '',
    this.phone = '',
    this.address = '',
    this.price = '',
    this.status = '',
    this.notes = '',
    this.items = const {},
  });

  factory Order.fromJson(Map<String, dynamic> j) {
    Map<String, int> it = {};
    dynamic raw = j['items'];
    if (raw is Map) {
      raw.forEach((k, v) => it[k.toString()] = int.tryParse(v.toString()) ?? 0);
    } else if (raw is String && raw.trim().startsWith('{')) {
      try {
        Map<String, dynamic>.from(jsonDecode(raw))
            .forEach((k, v) => it[k] = int.tryParse(v.toString()) ?? 0);
      } catch (_) {}
    }
    return Order(
      id: (j['id'] ?? j['row'] ?? '').toString(),
      row: int.tryParse(j['row'].toString()) ?? 0,
      date: (j['date'] ?? '').toString(),
      name: (j['name'] ?? '').toString(),
      phone: (j['phone'] ?? '').toString(),
      address: (j['address'] ?? '').toString(),
      price: (j['price'] ?? '').toString(),
      status: (j['status'] ?? '').toString(),
      notes: (j['notes'] ?? '').toString(),
      items: it,
    );
  }

  Map<String, dynamic> toJson() => {
        'row': row,
        'date': date,
        'name': name,
        'phone': phone,
        'address': address,
        'items': jsonEncode(items),
        'price': price,
        'status': status,
        'notes': notes,
      };

  String get itemsSummary =>
      items.entries.map((e) => '${e.key} ×${e.value}').join(', ');
}
