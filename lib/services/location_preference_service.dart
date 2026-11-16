import 'package:shared_preferences/shared_preferences.dart';

/// Son kullanılan konum tercihini saklar (GPS veya şehir araması).
class LocationPreferenceService {
  static const _lastCityKey = 'last_weather_city';
  static const _useGpsKey = 'weather_use_gps';

  static Future<bool> useGps() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_useGpsKey) ?? true;
  }

  static Future<void> setUseGps(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useGpsKey, value);
  }

  static Future<String?> getLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastCityKey);
  }

  static Future<void> saveLastCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCityKey, city.toLowerCase());
    await prefs.setBool(_useGpsKey, false);
  }
}
