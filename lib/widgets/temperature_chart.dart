import 'dart:math';
import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../l10n/app_localizations.dart';

class TemperatureChart extends StatelessWidget {
  final List<ForecastDay> forecast;

  const TemperatureChart({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (forecast.isEmpty) return const SizedBox.shrink();

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
            '📊 ${AppStrings.get('temp_trend')}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A2B35),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: CustomPaint(
              painter: _TempChartPainter(
                forecast: forecast,
                isDark: isDark,
              ),
              size: Size.infinite,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: forecast.take(5).map((day) {
              final dayName = AppStrings.lang == 'en'
                  ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day.date.weekday - 1]
                  : [AppStrings.get('mon'), AppStrings.get('tue'), AppStrings.get('wed'),
                     AppStrings.get('thu'), AppStrings.get('fri'), AppStrings.get('sat'),
                     AppStrings.get('sun')][day.date.weekday - 1];
              return Text(
                dayName,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white38 : Colors.grey[500],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TempChartPainter extends CustomPainter {
  final List<ForecastDay> forecast;
  final bool isDark;

  _TempChartPainter({required this.forecast, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (forecast.isEmpty) return;

    final days = forecast.take(5).toList();
    final allTemps = days.expand((d) => [d.tempMax, d.tempMin]).toList();
    final maxT = allTemps.reduce(max);
    final minT = allTemps.reduce(min);
    final range = (maxT - minT).clamp(1.0, 100.0);

    const padding = 30.0;
    final chartW = size.width - padding * 2;
    final chartH = size.height - 20;

    double xFor(int i) => padding + (chartW / (days.length - 1)) * i;
    double yFor(double t) => 10 + chartH * (1 - (t - minT) / range);

    // Grid lines
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white12 : Colors.grey[200]!)
      ..strokeWidth = 0.5;
    for (var i = 0; i < 4; i++) {
      final y = 10 + chartH * i / 3;
      canvas.drawLine(Offset(padding, y), Offset(size.width - padding, y), gridPaint);
    }

    // Max temp fill
    final maxPath = Path()..moveTo(xFor(0), yFor(days[0].tempMax));
    for (var i = 1; i < days.length; i++) {
      maxPath.lineTo(xFor(i), yFor(days[i].tempMax));
    }
    final minPath = Path()..moveTo(xFor(0), yFor(days[0].tempMin));
    for (var i = 1; i < days.length; i++) {
      minPath.lineTo(xFor(i), yFor(days[i].tempMin));
    }

    // Fill between max and min
    final fillPath = Path()..moveTo(xFor(0), yFor(days[0].tempMax));
    for (var i = 1; i < days.length; i++) {
      fillPath.lineTo(xFor(i), yFor(days[i].tempMax));
    }
    for (var i = days.length - 1; i >= 0; i--) {
      fillPath.lineTo(xFor(i), yFor(days[i].tempMin));
    }
    fillPath.close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFF6B35).withOpacity(0.15),
            const Color(0xFF5AA9E6).withOpacity(0.15),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Max line
    final maxLinePaint = Paint()
      ..color = const Color(0xFFFF6B35)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final maxLinePath = Path()..moveTo(xFor(0), yFor(days[0].tempMax));
    for (var i = 1; i < days.length; i++) {
      maxLinePath.lineTo(xFor(i), yFor(days[i].tempMax));
    }
    canvas.drawPath(maxLinePath, maxLinePaint);

    // Min line
    final minLinePaint = Paint()
      ..color = const Color(0xFF5AA9E6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final minLinePath = Path()..moveTo(xFor(0), yFor(days[0].tempMin));
    for (var i = 1; i < days.length; i++) {
      minLinePath.lineTo(xFor(i), yFor(days[i].tempMin));
    }
    canvas.drawPath(minLinePath, minLinePaint);

    // Dots and labels
    final textColor = isDark ? Colors.white : const Color(0xFF1A2B35);
    for (var i = 0; i < days.length; i++) {
      final x = xFor(i);
      // Max dot
      canvas.drawCircle(Offset(x, yFor(days[i].tempMax)), 4,
          Paint()..color = const Color(0xFFFF6B35));
      canvas.drawCircle(Offset(x, yFor(days[i].tempMax)), 2,
          Paint()..color = Colors.white);
      // Min dot
      canvas.drawCircle(Offset(x, yFor(days[i].tempMin)), 4,
          Paint()..color = const Color(0xFF5AA9E6));
      canvas.drawCircle(Offset(x, yFor(days[i].tempMin)), 2,
          Paint()..color = Colors.white);

      // Max label
      final maxTp = TextPainter(
        text: TextSpan(
          text: '${days[i].tempMax.round()}°',
          style: TextStyle(fontSize: 10, color: textColor, fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      maxTp.paint(canvas, Offset(x - maxTp.width / 2, yFor(days[i].tempMax) - 16));

      // Min label
      final minTp = TextPainter(
        text: TextSpan(
          text: '${days[i].tempMin.round()}°',
          style: TextStyle(fontSize: 10, color: textColor),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      minTp.paint(canvas, Offset(x - minTp.width / 2, yFor(days[i].tempMin) + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _TempChartPainter old) => old.forecast != forecast;
}
