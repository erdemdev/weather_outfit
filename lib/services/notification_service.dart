import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../l10n/app_localizations.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _channelsReady = false;

  static Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
    await _ensureAndroidChannels();
  }

  static Future<void> _ensureAndroidChannels() async {
    if (_channelsReady) return;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    await android.createNotificationChannel(const AndroidNotificationChannel(
      'daily_outfit',
      'Günlük Kombin',
      description: 'Günlük kombin önerisi bildirimi',
      importance: Importance.high,
    ));
    await android.createNotificationChannel(const AndroidNotificationChannel(
      'morning_outfit',
      'Sabah Kombin Bildirimi',
      description: 'Sabah hava durumu ve kombin önerisi',
      importance: Importance.high,
    ));
    await android.createNotificationChannel(const AndroidNotificationChannel(
      'umbrella_alert',
      'Şemsiye Uyarısı',
      description: 'Yağmur ve şemsiye hatırlatması',
      importance: Importance.high,
    ));
    await android.createNotificationChannel(const AndroidNotificationChannel(
      'weather_change',
      'Hava Değişikliği',
      description: 'Hava durumu değişiklik bildirimi',
      importance: Importance.defaultImportance,
    ));
    _channelsReady = true;
  }

  /// Android 13+ bildirim izni iste
  static Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  static Future<void> scheduleDailyNotification() async {
    await _ensureAndroidChannels();
    const androidDetails = AndroidNotificationDetails(
      'daily_outfit',
      'Günlük Kombin',
      channelDescription: 'Günlük kombin önerisi bildirimi',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.periodicallyShow(
      0,
      AppStrings.get('daily_notif_title'),
      AppStrings.get('daily_notif_body'),
      RepeatInterval.daily,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Sabah kombin bildirimi — hava ile birlikte
  static Future<void> showMorningOutfitNotification({
    required String city,
    required double temperature,
    required double feelsLike,
    required String condition,
    required int precipitationChance,
    required String outfitTitle,
    required List<String> outfitItems,
  }) async {
    await _ensureAndroidChannels();
    final isEN = AppStrings.lang == 'en';

    final needsUmbrella = precipitationChance > 40 ||
        condition == 'rain' || condition == 'drizzle' || condition == 'thunderstorm';

    final bodyParts = <String>[];
    bodyParts.add(isEN
        ? "Feels like ${feelsLike.round()}°C"
        : "Hissedilen ${feelsLike.round()}°C");
    if (needsUmbrella) {
      bodyParts.add(isEN ? '☔ Don\'t forget your umbrella!' : '☔ Şemsiyeni unutma!');
    }
    bodyParts.add(isEN
        ? "Today's outfit: $outfitTitle"
        : 'Bugünün kombini: $outfitTitle');
    if (outfitItems.isNotEmpty) {
      bodyParts.add(outfitItems.take(4).join(' • '));
    }

    final body = bodyParts.join('\n');
    final androidDetails = AndroidNotificationDetails(
      'morning_outfit',
      'Sabah Kombin Bildirimi',
      channelDescription: 'Sabah hava durumu ve kombin önerisi',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(body),
    );
    final details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      1,
      isEN
          ? '☀️ Good Morning! $city ${temperature.round()}°C'
          : '☀️ Günaydın! $city ${temperature.round()}°C',
      body,
      details,
    );
  }

  /// Şemsiye uyarısı bildirimi
  static Future<void> showUmbrellaAlert({
    required String city,
    required int precipitationChance,
  }) async {
    await _ensureAndroidChannels();
    final isEN = AppStrings.lang == 'en';
    final body = isEN
        ? '$city: $precipitationChance% chance of rain. Take an umbrella!'
        : '$city: $precipitationChance% yağış ihtimali. Şemsiyeni al!';
    final androidDetails = AndroidNotificationDetails(
      'umbrella_alert',
      'Şemsiye Uyarısı',
      channelDescription: 'Yağmur ve şemsiye hatırlatması',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(body),
    );
    final details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      3,
      isEN ? '☔ Umbrella Alert!' : '☔ Şemsiye Uyarısı!',
      body,
      details,
    );
  }

  /// Hava değişikliği bildirimi
  static Future<void> showWeatherChangeNotification({
    required String message,
  }) async {
    await _ensureAndroidChannels();
    const androidDetails = AndroidNotificationDetails(
      'weather_change',
      'Hava Değişikliği',
      channelDescription: 'Hava durumu değişiklik bildirimi',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      2,
      AppStrings.lang == 'en' ? '🌦️ Weather Change' : '🌦️ Hava Değişikliği',
      message,
      details,
    );
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
