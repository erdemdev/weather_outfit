class WeatherData {
  final String city;
  final String country;
  final double temperature;
  final double feelsLike;
  final double windSpeed;
  final int humidity;
  final int precipitationChance;
  final String condition;
  final String description;
  final double tempMin;
  final double tempMax;
  final DateTime sunrise;
  final DateTime sunset;
  final List<ForecastDay> forecast;
  final double uvIndex;
  final int aqi;
  final String aqiLabel;
  final List<HourlyForecast> hourlyForecast;

  const WeatherData({
    required this.city,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.windSpeed,
    required this.humidity,
    required this.precipitationChance,
    required this.condition,
    required this.description,
    required this.tempMin,
    required this.tempMax,
    required this.sunrise,
    required this.sunset,
    required this.forecast,
    this.uvIndex = 0,
    this.aqi = 0,
    this.aqiLabel = 'İyi',
    this.hourlyForecast = const [],
  });

  bool get isRainy =>
      condition == 'rain' || condition == 'drizzle' || condition == 'thunderstorm';
  bool get isCold => temperature < 10;
  bool get isMild => temperature >= 10 && temperature < 20;
  bool get isWarm => temperature >= 20 && temperature < 28;
  bool get isHot => temperature >= 28;
  bool get isWindy => windSpeed > 30;
  bool get isSnowy => condition == 'snow';
  bool get isFoggy => condition == 'mist' || condition == 'fog' || condition == 'haze';
  bool get isSunny => condition == 'clear';

  factory WeatherData.fromJson(Map<String, dynamic> json, Map<String, dynamic> forecastJson, {Map<String, dynamic>? aqiJson}) {
    final main = json['main'] as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>;
    final weatherList = json['weather'] as List<dynamic>;
    final sys = json['sys'] as Map<String, dynamic>;
    final weatherInfo = weatherList[0] as Map<String, dynamic>;

    final forecastItems = forecastJson['list'] as List<dynamic>;
    final List<HourlyForecast> hourlyData = [];
    final dailyAggregates = <String, _DailyForecastAggregate>{};
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month}-${now.day}';
    int todayMaxPrecip = 0;

    for (final item in forecastItems) {
      final dt = DateTime.fromMillisecondsSinceEpoch((item['dt'] as int) * 1000);
      final fMain = item['main'] as Map<String, dynamic>;
      final fWeather = (item['weather'] as List<dynamic>)[0] as Map<String, dynamic>;
      final fWind = item['wind'] as Map<String, dynamic>? ?? {};
      final pop = (item['pop'] as num?)?.toDouble() ?? 0.0;
      final precipPercent = (pop * 100).round();
      final temp = (fMain['temp'] as num?)?.toDouble() ?? 0.0;
      final condition = fWeather['main'].toString().toLowerCase();
      final description = fWeather['description'].toString();
      final windSpeed = ((fWind['speed'] as num?)?.toDouble() ?? 0.0) * 3.6;
      final humidity = (fMain['humidity'] as num?)?.toInt() ?? 60;

      // Saatlik tahmin (ilk 24 saat ~ 8 kayıt)
      if (hourlyData.length < 8) {
        hourlyData.add(HourlyForecast(
          time: dt,
          temperature: temp,
          condition: condition,
          precipitationChance: precipPercent,
        ));
      }

      final dateKey = '${dt.year}-${dt.month}-${dt.day}';
      if (dateKey == todayKey && precipPercent > todayMaxPrecip) {
        todayMaxPrecip = precipPercent;
      }

      final aggregate = dailyAggregates.putIfAbsent(
        dateKey,
        () => _DailyForecastAggregate(
          DateTime(dt.year, dt.month, dt.day),
        ),
      );
      aggregate.add(
        temp: temp,
        precipPercent: precipPercent,
        condition: condition,
        description: description,
        windSpeed: windSpeed,
        humidity: humidity,
      );
    }

    final forecastDays = dailyAggregates.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final List<ForecastDay> forecast = forecastDays
        .take(5)
        .map((aggregate) => aggregate.build())
        .toList();

    // UV indeksi: bulut yüzdesinden tahmin (API'de ayrı UV endpoint yok)
    final clouds = (json['clouds'] as Map<String, dynamic>?)?['all'] as num? ?? 50;
    final estimatedUv = ((100 - clouds.toInt()) / 100.0 * 10.0).clamp(0.0, 11.0);

    // AQI: OpenWeatherMap air_pollution endpoint'inden
    int aqiValue = 0;
    String aqiLabelValue = 'İyi';
    if (aqiJson != null) {
      final aqiList = aqiJson['list'] as List<dynamic>?;
      if (aqiList != null && aqiList.isNotEmpty) {
        final aqiMain = (aqiList[0] as Map<String, dynamic>)['main'] as Map<String, dynamic>?;
        final aqiIndex = (aqiMain?['aqi'] as num?)?.toInt() ?? 0;
        // OWM AQI: 1=İyi 2=Orta 3=Hassas 4=Kötü 5=Çok Kötü
        // US AQI yaklaşık eşdeğeri
        aqiValue = const [0, 25, 75, 125, 175, 250][aqiIndex.clamp(0, 5)];
        aqiLabelValue = const ['İyi', 'İyi', 'Orta', 'Hassas', 'Kötü', 'Çok Kötü'][aqiIndex.clamp(0, 5)];
      }
    }

    return WeatherData(
      city: json['name']?.toString() ?? 'Bilinmeyen',
      country: sys['country']?.toString() ?? '',
      temperature: (main['temp'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (main['feels_like'] as num?)?.toDouble() ?? 0.0,
      windSpeed: ((wind['speed'] as num?)?.toDouble() ?? 0.0) * 3.6,
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      precipitationChance: todayMaxPrecip,
      condition: weatherInfo['main'].toString().toLowerCase(),
      description: weatherInfo['description'].toString(),
      tempMin: (main['temp_min'] as num?)?.toDouble() ?? 0.0,
      tempMax: (main['temp_max'] as num?)?.toDouble() ?? 0.0,
      sunrise: DateTime.fromMillisecondsSinceEpoch(((sys['sunrise'] as num?)?.toInt() ?? 0) * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(((sys['sunset'] as num?)?.toInt() ?? 0) * 1000),
      forecast: forecast,
      uvIndex: estimatedUv,
      aqi: aqiValue,
      aqiLabel: aqiLabelValue,
      hourlyForecast: hourlyData,
    );
  }

  // Demo data for testing without API key
  factory WeatherData.demo({String city = 'Osmaniye'}) {
    final now = DateTime.now();
    // Şehre göre farklı hava verisi üret
    final hash = city.codeUnits.fold<int>(0, (sum, c) => sum + c);
    final allConditions = ['clear', 'clouds', 'rain', 'drizzle', 'snow'];
    final allDescriptions = ['açık', 'parçalı bulutlu', 'hafif yağmur', 'çisenti', 'hafif kar'];
    final baseTemp = 5.0 + (hash % 25);
    // Sıcaklığa göre gerçekçi hava koşulları filtrele
    final List<String> availableConditions;
    final List<String> availableDescriptions;
    if (baseTemp <= 3) {
      availableConditions = allConditions;
      availableDescriptions = allDescriptions;
    } else if (baseTemp <= 15) {
      availableConditions = ['clear', 'clouds', 'rain', 'drizzle'];
      availableDescriptions = ['açık', 'parçalı bulutlu', 'hafif yağmur', 'çisenti'];
    } else {
      availableConditions = ['clear', 'clouds', 'rain'];
      availableDescriptions = ['açık', 'parçalı bulutlu', 'hafif yağmur'];
    }
    final condIndex = hash % availableConditions.length;
    final cond = availableConditions[condIndex];
    final desc = availableDescriptions[condIndex];
    final precip = condIndex >= 2 ? 40 + (hash % 40) : (hash % 20);
    return WeatherData(
      city: city,
      country: 'TR',
      temperature: baseTemp,
      feelsLike: baseTemp - 2.8,
      windSpeed: 8.0 + (hash % 30),
      humidity: 40 + (hash % 50),
      precipitationChance: precip,
      condition: cond,
      description: desc,
      tempMin: baseTemp - 3.0,
      tempMax: baseTemp + 4.0,
      uvIndex: 1.0 + (hash % 8),
      aqi: 20 + (hash % 80),
      aqiLabel: (20 + (hash % 80)) < 50 ? 'İyi' : 'Orta',
      sunrise: now.copyWith(hour: 6, minute: 30),
      sunset: now.copyWith(hour: 19, minute: 15),
      hourlyForecast: List.generate(24, (i) {
        final hour = now.add(Duration(hours: i));
        return HourlyForecast(
          time: hour,
          temperature: baseTemp - 2 + (i < 12 ? i * 0.5 : (24 - i) * 0.5),
          condition: availableConditions[(condIndex + (i ~/ 6)) % availableConditions.length],
          precipitationChance: precip > 30 ? (precip - i * 2).clamp(5, 90) : (hash + i * 3) % 25,
        );
      }),
      forecast: List.generate(5, (i) {
        final fc = (condIndex + i) % availableConditions.length;
        return ForecastDay(
          date: now.add(Duration(days: i)),
          tempMax: baseTemp + 3.0 + i,
          tempMin: baseTemp - 2.0 + i,
          condition: availableConditions[fc],
          description: availableDescriptions[fc],
          precipitationChance: fc >= 2 ? 30 + (hash + i * 7) % 50 : (hash + i * 5) % 20,
          windSpeed: 8.0 + (hash % 30).toDouble(),
          humidity: 40 + (hash + i * 3) % 50,
        );
      }),
    );
  }
}

class _DailyForecastAggregate {
  final DateTime date;
  double _tempMax = double.negativeInfinity;
  double _tempMin = double.infinity;
  int _maxPrecip = 0;
  final Map<String, int> _conditionCounts = {};
  String _description = '';
  double _windSpeedSum = 0;
  int _windCount = 0;
  int _humiditySum = 0;
  int _humidityCount = 0;

  _DailyForecastAggregate(this.date);

  void add({
    required double temp,
    required int precipPercent,
    required String condition,
    required String description,
    required double windSpeed,
    required int humidity,
  }) {
    if (temp > _tempMax) _tempMax = temp;
    if (temp < _tempMin) _tempMin = temp;
    if (precipPercent > _maxPrecip) _maxPrecip = precipPercent;
    _conditionCounts[condition] = (_conditionCounts[condition] ?? 0) + 1;
    _description = description;
    _windSpeedSum += windSpeed;
    _windCount++;
    _humiditySum += humidity;
    _humidityCount++;
  }

  ForecastDay build() {
    final dominantCondition = _conditionCounts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;

    return ForecastDay(
      date: date,
      tempMax: _tempMax.isFinite ? _tempMax : 0,
      tempMin: _tempMin.isFinite ? _tempMin : 0,
      condition: dominantCondition,
      description: _description,
      precipitationChance: _maxPrecip,
      windSpeed: _windCount > 0 ? _windSpeedSum / _windCount : 15,
      humidity: _humidityCount > 0 ? _humiditySum ~/ _humidityCount : 60,
    );
  }
}

class ForecastDay {
  final DateTime date;
  final double tempMax;
  final double tempMin;
  final String condition;
  final String description;
  final int precipitationChance;
  final double windSpeed;
  final int humidity;

  const ForecastDay({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.condition,
    this.description = '',
    required this.precipitationChance,
    this.windSpeed = 15,
    this.humidity = 60,
  });
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final String condition;
  final int precipitationChance;

  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.condition,
    required this.precipitationChance,
  });
}
