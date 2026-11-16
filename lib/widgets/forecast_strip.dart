import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/weather_model.dart';

class ForecastStrip extends StatelessWidget {
  final List<ForecastDay> forecast;
  final int selectedIndex;
  final ValueChanged<int>? onDaySelected;

  const ForecastStrip({
    super.key,
    required this.forecast,
    this.selectedIndex = 0,
    this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (forecast.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF1A2B35);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get('forecast_5day'),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: forecast
              .asMap()
              .entries
              .map((e) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: e.key < forecast.length - 1 ? 8 : 0),
                      child: GestureDetector(
                        onTap: () => onDaySelected?.call(e.key),
                        child: _ForecastDayCard(
                          day: e.value,
                          isToday: e.key == 0,
                          isSelected: e.key == selectedIndex,
                          isDark: isDark,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _ForecastDayCard extends StatelessWidget {
  final ForecastDay day;
  final bool isToday;
  final bool isSelected;
  final bool isDark;

  const _ForecastDayCard({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final highlighted = isSelected;
    final scheme = Theme.of(context).colorScheme;
    final cardColor = highlighted
        ? scheme.primary
        : (isDark ? const Color(0xFF1E3345) : Colors.white);
    final primaryText = highlighted
        ? Colors.white
        : (isDark ? Colors.white : const Color(0xFF1A2B35));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: highlighted
                ? scheme.primary.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: highlighted ? 12 : 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: highlighted
            ? Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5)
            : isDark
                ? Border.all(color: Colors.white.withValues(alpha: 0.08))
                : null,
      ),
      child: Column(
        children: [
          Text(
            isToday ? AppStrings.get('today') : _shortDayName(day.date),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: highlighted
                  ? Colors.white70
                  : (isDark ? Colors.white54 : Colors.grey[500]),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _getConditionEmoji(day.condition),
            style: const TextStyle(fontSize: 22),
          ),
          const SizedBox(height: 6),
          Text(
            '${day.tempMax.round()}°',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: primaryText,
            ),
          ),
          Text(
            '${day.tempMin.round()}°',
            style: TextStyle(
              fontSize: 11,
              color: highlighted
                  ? Colors.white60
                  : (isDark ? Colors.white38 : Colors.grey[400]),
            ),
          ),
          if (day.precipitationChance > 20) ...[
            const SizedBox(height: 4),
            Text(
              '💧${day.precipitationChance}%',
              style: TextStyle(
                fontSize: 10,
                color: highlighted
                    ? Colors.lightBlueAccent
                    : Colors.blue[isDark ? 300 : 400],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _shortDayName(DateTime date) {
    const keys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    return AppStrings.get(keys[date.weekday - 1]);
  }

  String _getConditionEmoji(String condition) {
    switch (condition) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '⛅';
      case 'rain':
        return '🌧️';
      case 'drizzle':
        return '🌦️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '❄️';
      case 'mist':
      case 'fog':
        return '🌫️';
      default:
        return '🌤️';
    }
  }
}
