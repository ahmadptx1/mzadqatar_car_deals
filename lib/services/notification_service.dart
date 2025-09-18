import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../db/database_helper.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final db = DatabaseHelper.instance;

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  Future<int> _notificationsSentLastHour() async {
    final rows = await db.getListingsRaw();
    final now = DateTime.now();
    var count = 0;
    for (final r in rows) {
      final n = r['notifiedAt'];
      if (n != null) {
        final dt = DateTime.tryParse(n.toString());
        if (dt != null && now.difference(dt).inHours < 1) count += 1;
      }
    }
    return count;
  }

  Future<void> showNotification(String productId, String title, String body) async {
    final sent = await _notificationsSentLastHour();
    if (sent >= 3) return; // throttle

    const androidDetails = AndroidNotificationDetails('mzads', 'Mzad alerts', channelDescription: 'New recommended deals', importance: Importance.max, priority: Priority.high);
    const iosDetails = DarwinNotificationDetails();
    await _plugin.show(
      productId.hashCode,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );

    // mark recommended and save notified timestamp via helper
    await db.markRecommended(productId, 1);
    await db.updateNotifiedAt(productId, DateTime.now().toIso8601String());
  }
}
