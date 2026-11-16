import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../l10n/app_localizations.dart';
import '../models/weather_model.dart';
import 'cache_service.dart';

class WeatherService {
  static String get _apiKey {

    return const String.fromEnvironment('WEATHER_API_KEY');
  }

  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static bool _lastFetchFromCache = false;

  static bool get lastFetchFromCache => _lastFetchFromCache;

  static String get _langParam => AppStrings.lang == 'en' ? 'en' : 'tr';

  static Future<WeatherData> getWeatherByCity(String city) async {
    if (_apiKey.isEmpty) {
      _lastFetchFromCache = false;
      await Future.delayed(const Duration(seconds: 1));
      return WeatherData.demo(city: city);
    }
    final weatherUrl =
        '$_baseUrl/weather?q=${Uri.encodeComponent(city)}&appid=$_apiKey&units=metric&lang=$_langParam';
    final forecastUrl =
        '$_baseUrl/forecast?q=${Uri.encodeComponent(city)}&appid=$_apiKey&units=metric&lang=$_langParam&cnt=40';
    try {
      final responses = await Future.wait([
        http.get(Uri.parse(weatherUrl)).timeout(const Duration(seconds: 10)),
        http.get(Uri.parse(forecastUrl)).timeout(const Duration(seconds: 10)),
      ]);
      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        final weatherJson =
            jsonDecode(responses[0].body) as Map<String, dynamic>;
        final forecastJson =
            jsonDecode(responses[1].body) as Map<String, dynamic>;
        // AQI verisi için koordinatları kullan
        final coord = weatherJson['coord'] as Map<String, dynamic>?;
        Map<String, dynamic>? aqiJson;
        if (coord != null) {
          final aqiUrl =
              'https://api.openweathermap.org/data/2.5/air_pollution?lat=${coord['lat']}&lon=${coord['lon']}&appid=$_apiKey';
          try {
            final aqiResp = await http.get(Uri.parse(aqiUrl)).timeout(const Duration(seconds: 8));
            if (aqiResp.statusCode == 200) {
              aqiJson = jsonDecode(aqiResp.body) as Map<String, dynamic>;
            }
          } catch (_) {}
        }
        // Cache'e kaydet
        await CacheService.cacheWeather(
          city,
          weatherJson,
          forecastJson,
          lat: (coord?['lat'] as num?)?.toDouble(),
          lon: (coord?['lon'] as num?)?.toDouble(),
        );
        _lastFetchFromCache = false;
        return WeatherData.fromJson(weatherJson, forecastJson, aqiJson: aqiJson);
      } else if (responses[0].statusCode == 404) {
        throw Exception('Şehir bulunamadı: $city');
      } else {
        throw Exception('Hava durumu alınamadı. Lütfen tekrar dene.');
      }
    } catch (e) {
      // Çevrimdışı — aynı şehir cache'i dene
      if (await CacheService.hasValidCache(city)) {
        final cached = await CacheService.getCachedWeather();
        if (cached != null) {
          _lastFetchFromCache = true;
          return cached;
        }
      }
      // Herhangi bir cache dene (offline fallback)
      if (await CacheService.hasAnyValidCache()) {
        final cached = await CacheService.getCachedWeather();
        if (cached != null) {
          _lastFetchFromCache = true;
          return cached;
        }
      }
      rethrow;
    }
  }

  static Future<WeatherData> getWeatherByCoords(double lat, double lon) async {
    if (_apiKey.isEmpty) {
      _lastFetchFromCache = false;
      await Future.delayed(const Duration(seconds: 1));
      return WeatherData.demo();
    }
    final weatherUrl =
        '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=$_langParam';
    final forecastUrl =
        '$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=$_langParam&cnt=40';
    final aqiUrl =
        'https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$_apiKey';
    try {
      final responses = await Future.wait([
        http.get(Uri.parse(weatherUrl)).timeout(const Duration(seconds: 10)),
        http.get(Uri.parse(forecastUrl)).timeout(const Duration(seconds: 10)),
      ]);
      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        final weatherJson =
            jsonDecode(responses[0].body) as Map<String, dynamic>;
        final forecastJson =
            jsonDecode(responses[1].body) as Map<String, dynamic>;
        final city = (weatherJson['name'] ?? 'unknown').toString();
        Map<String, dynamic>? aqiJson;
        try {
          final aqiResp = await http.get(Uri.parse(aqiUrl)).timeout(const Duration(seconds: 8));
          if (aqiResp.statusCode == 200) {
            aqiJson = jsonDecode(aqiResp.body) as Map<String, dynamic>;
          }
        } catch (_) {}
        await CacheService.cacheWeather(
          city,
          weatherJson,
          forecastJson,
          lat: lat,
          lon: lon,
        );
        _lastFetchFromCache = false;
        return WeatherData.fromJson(weatherJson, forecastJson, aqiJson: aqiJson);
      } else {
        throw Exception('Konum için hava durumu alınamadı.');
      }
    } catch (e) {
      // Çevrimdışı — yalnızca yakın konumdaki cache'i kullan
      if (await CacheService.hasValidCacheForCoords(lat, lon)) {
        final cached = await CacheService.getCachedWeather();
        if (cached != null) {
          _lastFetchFromCache = true;
          return cached;
        }
      }
      rethrow;
    }
  }

  // Konum iznini kontrol et ve iste
  static Future<LocationPermission> ensureLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Konum izni reddedildi.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      throw Exception(
          'Konum izni kalıcı olarak reddedildi. Ayarlardan izin ver.');
    }
    return permission;
  }

  // GPS konumunu al
  static Future<Position> getCurrentPosition() async {
    // Önce izni kontrol et/iste — GPS kapalı olsa bile izin diyaloğu çıksın
    await ensureLocationPermission();

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Kullanıcıya konum ayarlarını açma şansı ver
      await Geolocator.openLocationSettings();
      // Ayarlardan dönünce tekrar kontrol et
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Konum servisi kapalı. Lütfen GPS\'i aç.');
      }
    }

    // Orta doğruluk — hava durumu için yeterli, düşük doğruluktan daha güvenilir
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 30),
        ),
      );
    } catch (_) {
      // Google Play Services sorunu olabilir — LocationManager ile tekrar dene
      return await Geolocator.getCurrentPosition(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 30),
          forceLocationManager: true,
        ),
      );
    }
  }

  static bool _isPositionFresh(Position position) {
    final age = DateTime.now().difference(position.timestamp);
    return age.inMinutes <= 15;
  }

  // GPS'ten hava durumu al
  static Future<WeatherData> getWeatherByGPS() async {
    await ensureLocationPermission();

    Position? position;
    Object? positionError;

    // Önce güncel GPS konumunu al — eski lastKnown konum yanlış şehir gösterebilir
    try {
      position = await getCurrentPosition();
    } catch (e) {
      positionError = e;
    }

    // Canlı GPS başarısızsa, yalnızca taze lastKnown konumu kullan
    if (position == null) {
      final lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null && _isPositionFresh(lastPosition)) {
        position = lastPosition;
      }
    }

    if (position == null) {
      if (positionError != null) throw positionError;
      throw Exception('Konum alınamadı. Lütfen GPS\'i açıp tekrar dene.');
    }

    return getWeatherByCoords(position.latitude, position.longitude);
  }
}
