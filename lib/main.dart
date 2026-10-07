import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'app_state.dart';
import 'api.dart';
import 'strings.dart';
import 'login_screen.dart';
import 'orders_screen.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final p = await SharedPreferences.getInstance();
      final url = p.getString('sheetUrl') ?? '';
      final logged = p.getBool('loggedIn') ?? false;
      final vibrate = p.getBool('vibrate') ?? true;
      final sound = p.getString('sound') ?? 'default';
      if (url.isEmpty || !logged) return true;
      Api.base = url;
      S.lang = p.getString('lang') ?? 'tr';
      final list = await Api.fetchOrders();
      final last = p.getInt('lastRow') ?? 0;
      final fresh = list.where((o) => o.row > last && last > 0).toList();
      if (fresh.isNotEmpty) {
        final maxRow = list.fold<int>(0, (m, o) => o.row > m ? o.row : m);
        await p.setInt('lastRow', maxRow);
        final fln = FlutterLocalNotificationsPlugin();
        const android = AndroidInitializationSettings('@mipmap/ic_launcher');
        await fln.initialize(const InitializationSettings(android: android));
        final c = fln.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!;
        await c.createNotificationChannel(AndroidNotificationChannel(
            'ch_default', 'Default',
            playSound: true, enableVibration: vibrate));
        await c.createNotificationChannel(AndroidNotificationChannel(
            'ch_alarm', 'Alarm',
            playSound: true,
            sound: const RawResourceAndroidNotificationSound('alarm'),
            enableVibration: vibrate));
        await c.createNotificationChannel(AndroidNotificationChannel(
            'ch_silent', 'Silent',
            playSound: false, enableVibration: vibrate));
        String ch = 'ch_default';
        if (sound == 'alarm') ch = 'ch_alarm';
        if (sound == 'silent') ch = 'ch_silent';
        for (final o in fresh) {
          final title = S.get('new_order');
          final body = '${o.name} — ${o.itemsSummary}';
          await fln.show(
            o.row, title, body,
            NotificationDetails(
              android: AndroidNotificationDetails(ch, ch,
                  importance: Importance.max, priority: Priority.high,
                  ticker: title,
                  styleInformation: BigTextStyleInformation(body)),
            ),
          );
        }
      }
    } catch (_) {}
    return true;
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final app = AppState();
  await app.load();
  Workmanager().initialize(callbackDispatcher);
  if (app.loggedIn) {
    Workmanager().registerPeriodicTask(
      'newOrdersCheck',
      'checkOrders',
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }
  runApp(AdminApp(app));
}

class AdminApp extends StatelessWidget {
  final AppState app;
  const AdminApp(this.app, {super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: app,
      builder: (_, __) => MaterialApp(
        title: 'Yönetim',
        debugShowCheckedModeBanner: false,
        themeMode: app.dark ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorSchemeSeed: Colors.teal),
        darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.teal),
        home: app.loggedIn ? OrdersScreen(app) : LoginScreen(app),
      ),
    );
  }
}
