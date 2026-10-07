import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/order.dart';

class Api {
  static String base = '';

  static Future<dynamic> _post(Map<String, dynamic> body) async {
    final r = await http.post(
      Uri.parse(base),
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 25));
    return jsonDecode(r.body);
  }

  static Future<bool> login(String user, String pass) async {
    try {
      final j = await _post({'action': 'login', 'user': user, 'pass': pass});
      return j['ok'] == true;
    } catch (_) {
      return false;
    }
  }

  static Future<List<Order>> fetchOrders() async {
    final j = await _post({'action': 'orders'});
    final rows = (j['orders'] as List? ?? []);
    return rows.map((e) => Order.fromJson(e)).toList();
  }

  static Future<bool> updateOrder(Order o) async {
    try {
      final j = await _post({'action': 'update', ...o.toJson()});
      return j['ok'] == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteOrder(int row) async {
    try {
      final j = await _post({'action': 'delete', 'row': row});
      return j['ok'] == true;
    } catch (_) {
      return false;
    }
  }
}
