import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/weather_model.dart';
import '../models/outfit_model.dart';

class WeatherHeader extends StatelessWidget {
  final WeatherData weather;
  final OutfitRecommendation outfit;

  const WeatherHeader({super.key, required this.weather, required this.outfit});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(
        top: topPadding + 60,
        left: 20,
        right: 20,
        bottom: 28,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getGradientColors(),
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: _getGradientColors()[1].withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${weather.city}, ${weather.country}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getTodayString(),
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
              _buildSunriseSunset(context),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.temperature.round()}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 80,
                      fontWeight: FontWeight.w200,
                      height: 1,
                      letterSpacing: -4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _capitalize(weather.description),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _showFeelsLikeInfo(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${AppStrings.get('feels_like')}: ${weather.feelsLike.round()}°C',
                          style: const TextStyle(color: Colors.white60, fontSize: 13, decoration: TextDecoration.underline, decorationColor: Colors.white30),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.info_outline_rounded, color: Colors.white38, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
              ),
              Column(
                children: [
                  Text(
                    _getWeatherEmoji(),
                    style: const TextStyle(fontSize: 72),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '↓${weather.tempMin.round()}°',
                        style: const TextStyle(color: Colors.white60, fontSize: 13),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '↑${weather.tempMax.round()}°',
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSunriseSunset(BuildContext context) {
    String format(DateTime dt) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }

    return GestureDetector(
      onTap: () => _showSunInfo(context),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            const Icon(Icons.wb_sunny_rounded, color: Colors.orange, size: 14),
            const SizedBox(width: 4),
            Text(
              format(weather.sunrise),
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.nightlight_round, color: Colors.blueGrey, size: 14),
            const SizedBox(width: 4),
            Text(
              format(weather.sunset),
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ],
      ),
    );
  }

  void _showSunInfo(BuildContext context) {
    final duration = weather.sunset.difference(weather.sunrise);
    final dH = duration.inHours;
    final dM = duration.inMinutes % 60;
    final now = DateTime.now();
    String fmt(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    final goldenMorningStart = weather.sunrise;
    final goldenMorningEnd = weather.sunrise.add(const Duration(minutes: 60));
    final goldenEveningStart = weather.sunset.subtract(const Duration(minutes: 60));
    final goldenEveningEnd = weather.sunset;
    final blueStart = weather.sunset;
    final blueEnd = weather.sunset.add(const Duration(minutes: 30));

    final isSunUp = now.isAfter(weather.sunrise) && now.isBefore(weather.sunset);
    final remaining = isSunUp
        ? weather.sunset.difference(now)
        : weather.sunrise.add(const Duration(days: 1)).difference(now);
    final remH = remaining.inHours;
    final remM = remaining.inMinutes % 60;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2B35) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('🌅', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('Güneş Bilgisi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A2B35))),
            const SizedBox(height: 20),
            _sunRow('🌅', 'Gün Doğumu', fmt(weather.sunrise), isDark),
            _sunRow('🌇', 'Gün Batımı', fmt(weather.sunset), isDark),
            _sunRow('☀️', 'Gündüz Süresi', '$dH saat $dM dk', isDark),
            _sunRow(isSunUp ? '⏳' : '🌙', isSunUp ? 'Gün batımına' : 'Gün doğumuna', '$remH sa $remM dk', isDark),
            const Divider(height: 24),
            _sunRow('✨', 'Altın Saat (Sabah)', '${fmt(goldenMorningStart)} - ${fmt(goldenMorningEnd)}', isDark),
            _sunRow('🌄', 'Altın Saat (Akşam)', '${fmt(goldenEveningStart)} - ${fmt(goldenEveningEnd)}', isDark),
            _sunRow('💙', 'Mavi Saat', '${fmt(blueStart)} - ${fmt(blueEnd)}', isDark),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _sunRow(String emoji, String title, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : const Color(0xFF1A2B35)))),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF2C6E8A))),
        ],
      ),
    );
  }

  void _showFeelsLikeInfo(BuildContext context) {
    final diff = weather.temperature - weather.feelsLike;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tips = <Map<String, String>>[];

    if (weather.windSpeed > 15) {
      tips.add({'icon': '💨', 'title': 'Rüzgar Soğutması', 'desc': 'Rüzgar ${weather.windSpeed.round()} km/s hızla esiyor. Bu, vücudun ısı kaybını hızlandırarak sıcaklığı ${diff.abs().toStringAsFixed(1)}° daha soğuk hissettirir.'});
    }
    if (weather.humidity > 70) {
      tips.add({'icon': '💧', 'title': 'Nem Etkisi', 'desc': 'Nem oranı %${weather.humidity}. Yüksek nem terlemeyi zorlaştırır ve havayı daha sıcak/bunaltıcı hissettirir.'});
    }
    if (diff > 0) {
      tips.add({'icon': '🥶', 'title': 'Daha Soğuk Hissediliyor', 'desc': 'Gerçek sıcaklık ${weather.temperature.round()}°C ama ${weather.feelsLike.round()}°C gibi hissediliyor. ${diff.toStringAsFixed(1)}° fark var.'});
    } else if (diff < 0) {
      tips.add({'icon': '🥵', 'title': 'Daha Sıcak Hissediliyor', 'desc': 'Gerçek sıcaklık ${weather.temperature.round()}°C ama ${weather.feelsLike.round()}°C gibi hissediliyor. ${diff.abs().toStringAsFixed(1)}° fark var.'});
    } else {
      tips.add({'icon': '✅', 'title': 'Normal', 'desc': 'Hissedilen sıcaklık gerçek sıcaklıkla aynı.'});
    }
    tips.add({'icon': '🌡️', 'title': 'Hissedilen Sıcaklık Nedir?', 'desc': 'Rüzgar, nem ve güneş ışınlarının birleşik etkisiyle vücudun algıladığı sıcaklık değeridir. Giyinirken bu değere göre hareket edin.'});

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2B35) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                const Text('🌡️', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text('Hissedilen: ${weather.feelsLike.round()}°C', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A2B35))),
                const SizedBox(height: 4),
                Text('Gerçek: ${weather.temperature.round()}°C', style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : Colors.grey[600])),
                const SizedBox(height: 20),
                ...tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tip['icon']!, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tip['title']!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1A2B35))),
                          const SizedBox(height: 2),
                          Text(tip['desc']!, style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.grey[600])),
                        ],
                      )),
                    ],
                  ),
                )),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getWeatherEmoji() {
    final isNight = DateTime.now().isAfter(weather.sunset) || DateTime.now().isBefore(weather.sunrise);
    switch (weather.condition) {
      case 'clear': return isNight ? '🌙' : '☀️';
      case 'clouds': return isNight ? '☁️' : '⛅';
      case 'rain': return '🌧️';
      case 'drizzle': return isNight ? '🌧️' : '🌦️';
      case 'thunderstorm': return '⛈️';
      case 'snow': return '❄️';
      case 'mist':
      case 'fog':
      case 'haze': return '🌫️';
      default: return isNight ? '🌙' : '🌤️';
    }
  }

  List<Color> _getGradientColors() {
    final isNight = DateTime.now().isAfter(weather.sunset) || DateTime.now().isBefore(weather.sunrise);
    if (isNight) {
      switch (weather.condition) {
        case 'clear':
          return [const Color(0xFF0F2027), const Color(0xFF203A43)];
        case 'clouds':
          return [const Color(0xFF1A1A2E), const Color(0xFF16213E)];
        case 'thunderstorm':
          return [const Color(0xFF1A1A2E), const Color(0xFF2C3E6B)];
        default:
          return [const Color(0xFF0D1B2A), const Color(0xFF1B2838)];
      }
    }
    switch (weather.condition) {
      case 'clear':
        if (weather.isHot) {
          return [const Color(0xFFE8783A), const Color(0xFFC8561A)];
        }
        return [const Color(0xFF2980B9), const Color(0xFF1A5A8A)];
      case 'clouds':
        return [const Color(0xFF536976), const Color(0xFF292E49)];
      case 'rain':
        return [const Color(0xFF2C6E8A), const Color(0xFF1A3A4A)];
      case 'drizzle':
        return [const Color(0xFF3A7A9E), const Color(0xFF1E4D62)];
      case 'thunderstorm':
        return [const Color(0xFF373B44), const Color(0xFF4286f4)];
      case 'snow':
        return [const Color(0xFF74B9E0), const Color(0xFF3A85B5)];
      case 'mist':
      case 'fog':
      case 'haze':
        return [const Color(0xFF8BA3AE), const Color(0xFF5A737E)];
      default:
        return [const Color(0xFF2C6E8A), const Color(0xFF1A3A4A)];
    }
  }

  String _getTodayString() {
    final locale = AppStrings.lang == 'en' ? 'en' : 'tr';
    return DateFormat('EEEE, d MMMM yyyy', locale).format(DateTime.now());
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
