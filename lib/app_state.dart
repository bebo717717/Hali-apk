import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'order.dart';
import 'api.dart';
import 'notify.dart';
import 'strings.dart';

enum FilterMode { today, yesterday, all }

class AppState extends ChangeNotifier {
  bool dark = false;
  bool vibrate = true;
  bool banner = true;
  bool loggedIn = false;
  bool loading = false;
  String lang = 'tr';
  String sound = 'default'; // default | alarm | silent | custom:<path>
  String sheetUrl = '';
  String username = '';
  String password = '';
  String? error;

  List<Order> orders = [];
  FilterMode filter = FilterMode.today;
  Order? bannerOrder;

  int _lastRow = 0;
  Timer? _timer;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    dark = p.getBool('dark') ?? false;
    vibrate = p.getBool('vibrate') ?? true;
    banner = p.getBool('banner') ?? true;
    lang = p.getString('lang') ?? 'tr';
    sound = p.getString('sound') ?? 'default';
    sheetUrl = p.getString('sheetUrl') ?? '';
    username = p.getString('username') ?? '';
    password = p.getString('password') ?? '';
    loggedIn = p.getBool('loggedIn') ?? false;
    _lastRow = p.getInt('lastRow') ?? 0;
    S.lang = lang;
    Api.base = sheetUrl;
    notifyListeners();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('dark', dark);
    await p.setBool('vibrate', vibrate);
    await p.setBool('banner', banner);
    await p.setString('lang', lang);
    await p.setString('sound', sound);
    await p.setString('sheetUrl', sheetUrl);
    await p.setString('username', username);
    await p.setString('password', password);
    await p.setBool('loggedIn', loggedIn);
    await p.setInt('lastRow', _lastRow);
  }

  Future<void> updateSettings({
    bool? dark, bool? vibrate, bool? banner, String? lang,
    String? sound, String? sheetUrl, String? username, String? password,
  }) async {
    if (dark != null) this.dark = dark;
    if (vibrate != null) this.vibrate = vibrate;
    if (banner != null) this.banner = banner;
    if (lang != null) { this.lang = lang; S.lang = lang; }
    if (sound != null) this.sound = sound;
    if (sheetUrl != null) { this.sheetUrl = sheetUrl; Api.base = sheetUrl; }
    if (username != null) this.username = username;
    if (password != null) this.password = password;
    await _save();
    await Notify.channels(this);
    notifyListeners();
  }

  Future<bool> login(String u, String p) async {
    loading = true;
    notifyListeners();
    final ok = await Api.login(u, p);
    loading = false;
    if (ok) {
      username = u; password = p; loggedIn = true;
      await _save();
      startPolling();
    }
    notifyListeners();
    return ok;
  }

  Future<void> logout() async {
    loggedIn = false;
    _timer?.cancel();
    await _save();
    notifyListeners();
  }

  void startPolling() {
    _timer?.cancel();
    _lastRow = 0;
    refresh(notifyNew: false);
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => refresh());
  }

  Future<void> refresh({bool notifyNew = true}) async {
    if (sheetUrl.isEmpty || !loggedIn) return;
    loading = true;
    notifyListeners();
    try {
      final list = await Api.fetchOrders();
      if (notifyNew) {
        final fresh = list.where((o) => o.row > _lastRow && _lastRow > 0).toList();
        for (final o in fresh) {
          await Notify.orderAlert(o, this);
        }
        if (fresh.isNotEmpty && banner) {
          bannerOrder = fresh.last;
          notifyListeners();
          Timer(const Duration(seconds: 6), () {
            bannerOrder = null;
            notifyListeners();
          });
        }
      }
      final maxRow = list.fold<int>(0, (m, o) => o.row > m ? o.row : m);
      if (maxRow > _lastRow) {
        _lastRow = maxRow;
        final p = await SharedPreferences.getInstance();
        await p.setInt('lastRow', _lastRow);
      }
      orders = list;
      error = null;
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  DateTime? _parseDate(String d) {
    for (final f in ['yyyy-MM-dd', 'dd.MM.yyyy', 'dd/MM/yyyy']) {
      try { return DateFormat(f).parse(d.trim()); } catch (_) {}
    }
    return null;
  }

  List<Order> get filtered {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yest = today.subtract(const Duration(days: 1));
    return orders.where((o) {
      final d = _parseDate(o.date);
      if (d == null) return filter == FilterMode.all;
      final dd = DateTime(d.year, d.month, d.day);
      switch (filter) {
        case FilterMode.today: return dd == today;
        case FilterMode.yesterday: return dd == yest;
        case FilterMode.all: return true;
      }
    }).toList()
      ..sort((a, b) => b.row.compareTo(a.row));
  }

  Future<void> saveOrder(Order o) async {
    await Api.updateOrder(o);
    await refresh(notifyNew: false);
  }

  Future<void> deleteOrder(Order o) async {
    await Api.deleteOrder(o.row);
    orders.removeWhere((x) => x.row == o.row);
    notifyListeners();
  }
}
