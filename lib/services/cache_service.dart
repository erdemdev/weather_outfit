import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';

class CacheService {
  static const _weatherKey = 'cached_weather';
  static const _timestampKey = 'cache_timestamp';
  static const _cityKey = 'cache_city';
  static const _latKey = 'cache_lat';
  static const _lonKey = 'cache_lon';
  static const _maxAge = Duration(hours: 6);
  static const _maxLocationDistanceMeters = 50000; // 50 km

  /// Hava verisini cache'le
  static Future<void> cacheWeather(
    String city,
    Map<String, dynamic> weatherJson,
    Map<String, dynamic> forecastJson, {
    double? lat,
    double? lon,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weatherKey, jsonEncode({
      'weather': weatherJson,
      'forecast': forecastJson,
    }));
    await prefs.setString(_cityKey, city.toLowerCase());
    await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
    if (lat != null && lon != null) {
      await prefs.setDouble(_latKey, lat);
      await prefs.setDouble(_lonKey, lon);
    }
  }

  /// Geçerli cache var mı? (şehirden bağımsız da bakılabilir)
  static Future<bool> hasValidCache(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt(_timestampKey);
    final cachedCity = prefs.getString(_cityKey);
    if (ts == null || cachedCity == null) return false;
    if (cachedCity != city.toLowerCase()) return false;

    final age = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ts));
    return age < _maxAge;
  }

  /// Konuma yakın geçerli cache var mı?
  static Future<bool> hasValidCacheForCoords(double lat, double lon) async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt(_timestampKey);
    final cachedLat = prefs.getDouble(_latKey);
    final cachedLon = prefs.getDouble(_lonKey);
    if (ts == null || cachedLat == null || cachedLon == null) return false;

    final age = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ts));
    if (age >= _maxAge) return false;

    final distance = Geolocator.distanceBetween(lat, lon, cachedLat, cachedLon);
    return distance <= _maxLocationDistanceMeters;
  }

  /// Herhangi bir geçerli cache var mı? (offline fallback — şehir fark etmez ama daha toleranslı yaş sınırı)
  static Future<bool> hasAnyValidCache() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt(_timestampKey);
    if (ts == null) return false;
    final age = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ts));
    return age < const Duration(hours: 1);
  }

  /// Cache'ten hava durumunu oku
  static Future<WeatherData?> getCachedWeather() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_weatherKey);
    if (raw == null) return null;

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return WeatherData.fromJson(
        data['weather'] as Map<String, dynamic>,
        data['forecast'] as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  /// Cache yaşı
  static Future<Duration?> getCacheAge() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt(_timestampKey);
    if (ts == null) return null;
    return DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ts));
  }

  /// Son cache'lenen şehir
  static Future<String?> getCachedCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cityKey);
  }

  /// Cache'i temizle
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_weatherKey);
    await prefs.remove(_timestampKey);
    await prefs.remove(_cityKey);
    await prefs.remove(_latKey);
    await prefs.remove(_lonKey);
  }
}
