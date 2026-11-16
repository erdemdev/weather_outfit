import 'package:shared_preferences/shared_preferences.dart';
import '../models/outfit_model.dart';

class WidgetService {
  static Future<void> updateWidget({
    required double temperature,
    required double feelsLike,
    required String city,
    required String condition,
    required int precipitationChance,
    required OutfitRecommendation outfit,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final needsUmbrella = precipitationChance > 40 ||
        condition == 'rain' || condition == 'drizzle' || condition == 'thunderstorm';
    await prefs.setString('widget_temp', '${temperature.round()}° (${feelsLike.round()}°)');
    await prefs.setString('widget_city', city);
    await prefs.setString('widget_emoji', _conditionEmoji(condition));
    await prefs.setString('widget_outfit', outfit.title);
    await prefs.setString(
      'widget_items',
      (needsUmbrella ? '☔ ' : '') +
      outfit.items.take(4).map((i) => '${i.emoji} ${i.name}').join(' • '),
    );
  }

  static String _conditionEmoji(String condition) {
    switch (condition) {
      case 'clear': return '☀️';
      case 'clouds': return '⛅';
      case 'rain': return '🌧️';
      case 'drizzle': return '🌦️';
      case 'thunderstorm': return '⛈️';
      case 'snow': return '❄️';
      default: return '🌤️';
    }
  }
}
