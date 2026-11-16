import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';

class WeatherAlert {
  final String type;
  final String emoji;
  final String titleTR;
  final String titleEN;
  final String descTR;
  final String descEN;
  final int hour;

  const WeatherAlert({
    required this.type,
    required this.emoji,
    required this.titleTR,
    required this.titleEN,
    required this.descTR,
    required this.descEN,
    required this.hour,
  });
}

class WeatherAlertService {
  static const _key = 'weather_alerts_enabled';

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? true;
  }

  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }

  static List<WeatherAlert> checkAlerts(WeatherData weather) {
    final alerts = <WeatherAlert>[];

    // Hourly forecast analysis
    for (int i = 0; i < weather.hourlyForecast.length && i < 12; i++) {
      final h = weather.hourlyForecast[i];

      if (i > 0 && (h.condition == 'rain' || h.condition == 'drizzle')) {
        final prev = weather.hourlyForecast[i - 1];
        if (prev.condition != 'rain' && prev.condition != 'drizzle') {
          alerts.add(WeatherAlert(
            type: 'rain_start',
            emoji: '🌧️',
            titleTR: 'Yağmur Başlayacak',
            titleEN: 'Rain Starting',
            descTR: '${h.time.hour}:00 civarında yağmur bekleniyor. Şemsiye almayı unutma!',
            descEN: 'Rain expected around ${h.time.hour}:00. Don\'t forget your umbrella!',
            hour: h.time.hour,
          ));
          break;
        }
      }

      if (i > 0 && h.condition == 'snow') {
        final prev = weather.hourlyForecast[i - 1];
        if (prev.condition != 'snow') {
          alerts.add(WeatherAlert(
            type: 'snow_start',
            emoji: '❄️',
            titleTR: 'Kar Başlayacak',
            titleEN: 'Snow Starting',
            descTR: '${h.time.hour}:00 civarında kar bekleniyor. Kalın giyin!',
            descEN: 'Snow expected around ${h.time.hour}:00. Dress warm!',
            hour: h.time.hour,
          ));
          break;
        }
      }
    }

    // Temperature drop alert
    if (weather.hourlyForecast.length >= 6) {
      final now = weather.hourlyForecast[0].temperature;
      final later = weather.hourlyForecast[5].temperature;
      if (now - later > 5) {
        alerts.add(WeatherAlert(
          type: 'temp_drop',
          emoji: '🌡️',
          titleTR: 'Sıcaklık Düşecek',
          titleEN: 'Temperature Drop',
          descTR: 'Önümüzdeki saatlerde sıcaklık ${(now - later).round()}° düşecek. Yanına mont al!',
          descEN: 'Temperature will drop ${(now - later).round()}° in coming hours. Bring a jacket!',
          hour: weather.hourlyForecast[5].time.hour,
        ));
      }
    }

    // High wind alert
    if (weather.windSpeed > 40) {
      alerts.add(WeatherAlert(
        type: 'high_wind',
        emoji: '💨',
        titleTR: 'Şiddetli Rüzgar',
        titleEN: 'Strong Wind',
        descTR: 'Rüzgar hızı ${weather.windSpeed.round()} km/s. Dikkatli ol!',
        descEN: 'Wind speed ${weather.windSpeed.round()} km/h. Be careful!',
        hour: DateTime.now().hour,
      ));
    }

    // UV alert
    if (weather.uvIndex > 7) {
      alerts.add(WeatherAlert(
        type: 'high_uv',
        emoji: '☀️',
        titleTR: 'Yüksek UV',
        titleEN: 'High UV',
        descTR: 'UV indeksi ${weather.uvIndex.toStringAsFixed(1)}. Güneş kremi sür!',
        descEN: 'UV index ${weather.uvIndex.toStringAsFixed(1)}. Apply sunscreen!',
        hour: 12,
      ));
    }

    return alerts;
  }
}
