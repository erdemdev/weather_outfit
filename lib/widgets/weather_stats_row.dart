import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/weather_model.dart';

class WeatherStatsRow extends StatelessWidget {
  final WeatherData weather;

  const WeatherStatsRow({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _StatCard(
          icon: '🌡️',
          label: AppStrings.get('feels_like'),
          value: '${weather.feelsLike.round()}°C',
          color: const Color(0xFFD97706),
          warning: (weather.feelsLike - weather.temperature).abs() > 5,
        )),
        const SizedBox(width: 10),
        Expanded(
            child: _StatCard(
          icon: '💨',
          label: AppStrings.get('wind'),
          value: '${weather.windSpeed.round()} km/s',
          color: const Color(0xFF4A8FA8),
          warning: weather.isWindy,
        )),
        const SizedBox(width: 10),
        Expanded(
            child: _StatCard(
          icon: '💧',
          label: AppStrings.get('humidity'),
          value: '%${weather.humidity}',
          color: const Color(0xFF5B8DD9),
          warning: weather.humidity > 85,
        )),
        const SizedBox(width: 10),
        Expanded(
            child: _StatCard(
          icon: weather.isRainy ? '☔' : '🌈',
          label: AppStrings.get('rain'),
          value: '%${weather.precipitationChance}',
          color: weather.isRainy
              ? const Color(0xFF2C6E8A)
              : const Color(0xFF6B9E78),
          warning: weather.precipitationChance > 50,
        )),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;
  final bool warning;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3345) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.15 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: warning
            ? Border.all(color: color.withValues(alpha: 0.3), width: 1)
            : isDark
                ? Border.all(color: Colors.white.withValues(alpha: 0.06))
                : null,
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white54 : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
