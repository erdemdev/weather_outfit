import 'package:flutter_test/flutter_test.dart';
import 'package:weather_outfit/models/weather_model.dart';

void main() {
  group('WeatherData', () {
    test('demo creates consistent city and forecast size', () {
      final data = WeatherData.demo(city: 'Istanbul');

      expect(data.city, 'Istanbul');
      expect(data.forecast.length, 5);
      expect(data.hourlyForecast.length, 24);
    });

    test('fromJson aggregates daily min and max across 3-hour slots', () {
      final weatherJson = {
        'name': 'Ankara',
        'main': {
          'temp': 18.5,
          'feels_like': 17.2,
          'humidity': 62,
          'temp_min': 14.0,
          'temp_max': 21.0,
        },
        'wind': {'speed': 5.0},
        'weather': [
          {'main': 'Clouds', 'description': 'broken clouds'}
        ],
        'sys': {
          'country': 'TR',
          'sunrise': 1711860000,
          'sunset': 1711906200,
        },
      };

      final day = DateTime(2026, 4, 1);
      final forecastJson = {
        'list': [
          for (var hour in [0, 3, 6, 9, 12, 15, 18, 21])
            {
              'dt': day.add(Duration(hours: hour)).millisecondsSinceEpoch ~/ 1000,
              'main': {
                'temp': 10.0 + hour,
                'temp_max': 10.0 + hour,
                'temp_min': 10.0 + hour,
                'humidity': 50,
              },
              'weather': [
                {'main': hour < 12 ? 'Rain' : 'Clear', 'description': 'test'}
              ],
              'pop': 0.2,
              'wind': {'speed': 2.0},
            },
        ],
      };

      final data = WeatherData.fromJson(weatherJson, forecastJson);

      expect(data.forecast, hasLength(1));
      expect(data.forecast.first.tempMin, 10);
      expect(data.forecast.first.tempMax, 31);
      expect(data.forecast.first.condition, 'rain');
    });

    test('fromJson parses current and forecast payloads', () {
      final weatherJson = {
        'name': 'Ankara',
        'main': {
          'temp': 18.5,
          'feels_like': 17.2,
          'humidity': 62,
          'temp_min': 14.0,
          'temp_max': 21.0,
        },
        'wind': {'speed': 5.0},
        'weather': [
          {'main': 'Clouds', 'description': 'broken clouds'}
        ],
        'sys': {
          'country': 'TR',
          'sunrise': 1711860000,
          'sunset': 1711906200,
        },
      };

      final forecastJson = {
        'list': List.generate(8, (i) {
          final dt = DateTime.utc(2026, 4, 1).add(Duration(hours: i * 6));
          return {
            'dt': dt.millisecondsSinceEpoch ~/ 1000,
            'main': {'temp_max': 20 + i, 'temp_min': 10 + i},
            'weather': [
              {'main': i % 2 == 0 ? 'Rain' : 'Clear'}
            ],
            'pop': 0.3,
          };
        }),
      };

      final data = WeatherData.fromJson(weatherJson, forecastJson);

      expect(data.city, 'Ankara');
      expect(data.country, 'TR');
      expect(data.temperature, 18.5);
      expect(data.condition, 'clouds');
      expect(data.forecast, isNotEmpty);
      expect(data.forecast.length <= 5, isTrue);
    });

    test('condition helpers reflect weather values', () {
      final rainy = WeatherData.demo(city: 'Rainy')
          .copyWithForTest(condition: 'rain', temperature: 6, windSpeed: 40);

      expect(rainy.isRainy, isTrue);
      expect(rainy.isCold, isTrue);
      expect(rainy.isWindy, isTrue);
    });
  });
}

extension on WeatherData {
  WeatherData copyWithForTest({
    String? condition,
    double? temperature,
    double? windSpeed,
  }) {
    return WeatherData(
      city: city,
      country: country,
      temperature: temperature ?? this.temperature,
      feelsLike: feelsLike,
      windSpeed: windSpeed ?? this.windSpeed,
      humidity: humidity,
      precipitationChance: precipitationChance,
      condition: condition ?? this.condition,
      description: description,
      tempMin: tempMin,
      tempMax: tempMax,
      sunrise: sunrise,
      sunset: sunset,
      forecast: forecast,
      uvIndex: uvIndex,
      aqi: aqi,
      aqiLabel: aqiLabel,
      hourlyForecast: hourlyForecast,
    );
  }
}
