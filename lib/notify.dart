import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'order.dart';
import 'app_state.dart';
import 'strings.dart';

class Notify {
  static final _fln = FlutterLocalNotificationsPlugin();

  static Future<void> init(AppState app) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _fln.initialize(const InitializationSettings(android: android));
    await _fln.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await channels(app);
  }

  static Future<void> channels(AppState app) async {
    final c = _fln.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()!;
    await c.deleteNotificationChannel('ch_default');
    await c.deleteNotificationChannel('ch_alarm');
    await c.deleteNotificationChannel('ch_silent');
    await c.createNotificationChannel(AndroidNotificationChannel(
        'ch_default', S.get('sound_default'),
        playSound: true, enableVibration: app.vibrate));
    await c.createNotificationChannel(AndroidNotificationChannel(
        'ch_alarm', S.get('sound_alarm'),
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('alarm'),
        enableVibration: app.vibrate));
    await c.createNotificationChannel(AndroidNotificationChannel(
        'ch_silent', S.get('sound_silent'),
        playSound: false, enableVibration: app.vibrate));
  }

  static Future<void> orderAlert(Order o, AppState app) async {
    String ch = 'ch_default';
    if (app.sound == 'alarm') ch = 'ch_alarm';
    if (app.sound == 'silent' || app.sound.startsWith('custom:')) {
      ch = 'ch_silent';
    }
    if (app.sound.startsWith('custom:')) {
      try {
        final pl = AudioPlayer();
        await pl.play(DeviceFileSource(app.sound.substring(7)));
      } catch (_) {}
    }
    final title = S.get('new_order');
    final body = '${o.name} — ${o.itemsSummary}';
    await _fln.show(
      o.row,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          ch, ch,
          channelDescription: 'Siparis bildirimleri',
          importance: Importance.max,
          priority: Priority.high,
          ticker: title,
          styleInformation: BigTextStyleInformation(body),
        ),
      ),
    );
  }
}
