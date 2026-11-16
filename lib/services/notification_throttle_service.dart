import 'package:shared_preferences/shared_preferences.dart';

/// Aynı bildirimin kısa sürede tekrar tekrar gönderilmesini önler.
class NotificationThrottleService {
  static const _morningKey = 'notif_morning_date';
  static const _umbrellaPrefix = 'notif_umbrella_';

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  static Future<bool> shouldSendMorningNotification() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_morningKey) != _todayKey();
  }

  static Future<void> markMorningNotificationSent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_morningKey, _todayKey());
  }

  static Future<bool> shouldSendUmbrellaAlert(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_umbrellaPrefix${city.toLowerCase()}';
    return prefs.getString(key) != _todayKey();
  }

  static Future<void> markUmbrellaAlertSent(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_umbrellaPrefix${city.toLowerCase()}';
    await prefs.setString(key, _todayKey());
  }
}
