import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/weather_model.dart';

class HourlyChart extends StatelessWidget {
  final List<HourlyForecast> hourlyData;

  const HourlyChart({super.key, required this.hourlyData});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (hourlyData.isEmpty) return const SizedBox.shrink();

    final maxTemp = hourlyData.map((h) => h.temperature).reduce((a, b) => a > b ? a : b);
    final minTemp = hourlyData.map((h) => h.temperature).reduce((a, b) => a < b ? a : b);
    final range = (maxTemp - minTemp).clamp(1.0, 100.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3345) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⏰ ${AppStrings.get('hourly_forecast')}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A2B35),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hourlyData.length > 24 ? 24 : hourlyData.length,
              itemBuilder: (ctx, i) => _buildHourItem(hourlyData[i], minTemp, range, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourItem(HourlyForecast hour, double minTemp, double range, bool isDark) {
    final barHeight = ((hour.temperature - minTemp) / range * 50).clamp(8.0, 50.0);
    final emoji = _conditionEmoji(hour.condition);
    final timeStr = '${hour.time.hour.toString().padLeft(2, '0')}:00';
    final needsUmbrella = hour.precipitationChance > 40 ||
        hour.condition == 'rain' || hour.condition == 'drizzle' || hour.condition == 'thunderstorm';

    return SizedBox(
      width: 56,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '${hour.temperature.round()}°',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A2B35),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 20,
            height: barHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _barColors(hour.temperature),
              ),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 6),
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          if (hour.precipitationChance > 0)
            Text(
              needsUmbrella ? '☔${hour.precipitationChance}%' : '💧${hour.precipitationChance}%',
              style: TextStyle(
                fontSize: 9,
                color: needsUmbrella ? Colors.orange[400] : Colors.blue[300],
                fontWeight: needsUmbrella ? FontWeight.w700 : FontWeight.normal,
              ),
            )
          else
            const SizedBox(height: 12),
          const SizedBox(height: 2),
          Text(
            timeStr,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white38 : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _barColors(double temp) {
    if (temp >= 30) return [const Color(0xFFFF6B35), const Color(0xFFFF9F1C)];
    if (temp >= 20) return [const Color(0xFFF4B062), const Color(0xFFFFD166)];
    if (temp >= 10) return [const Color(0xFF2C6E8A), const Color(0xFF3A8FA8)];
    if (temp >= 0) return [const Color(0xFF5AA9E6), const Color(0xFFA0D2F0)];
    return [const Color(0xFF7FC8F8), const Color(0xFFD0EFFF)];
  }

  String _conditionEmoji(String condition) {
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
