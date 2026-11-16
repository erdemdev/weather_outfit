import 'package:flutter/material.dart';
import '../services/weekly_summary_service.dart';
import '../l10n/app_localizations.dart';

class WeeklySummaryScreen extends StatefulWidget {
  const WeeklySummaryScreen({super.key});

  @override
  State<WeeklySummaryScreen> createState() => _WeeklySummaryScreenState();
}

class _WeeklySummaryScreenState extends State<WeeklySummaryScreen> {
  WeeklySummaryData? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await WeeklySummaryService.getSummary();
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Weekly Summary' : 'Haftalık Özet'),
        backgroundColor: isDark ? const Color(0xFF1A2B35) : const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2C6E8A)))
          : _data == null || _data!.totalEntries == 0
              ? Center(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('📊', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    Text(isEN ? 'No data this week' : 'Bu hafta veri yok', style: TextStyle(fontSize: 16, color: isDark ? Colors.white54 : Colors.grey)),
                  ],
                ))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Stats cards
                      Row(
                        children: [
                          Expanded(child: _statCard('🌡️', isEN ? 'Avg Temp' : 'Ort. Sıcaklık', '${_data!.avgTemp.toStringAsFixed(1)}°C', isDark)),
                          const SizedBox(width: 10),
                          Expanded(child: _statCard('📈', isEN ? 'Max' : 'Maks', '${_data!.maxTemp.round()}°C', isDark)),
                          const SizedBox(width: 10),
                          Expanded(child: _statCard('📉', isEN ? 'Min' : 'Min', '${_data!.minTemp.round()}°C', isDark)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _statCard('👔', isEN ? 'Top Outfit' : 'En Çok Giyilen', _data!.topOutfit, isDark)),
                          const SizedBox(width: 10),
                          Expanded(child: _statCard(_condEmoji(_data!.topCondition), isEN ? 'Top Weather' : 'En Çok Hava', _condLabel(_data!.topCondition), isDark)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _statCard('⭐', isEN ? 'Avg Rating' : 'Ort. Puan', _data!.avgRating > 0 ? _data!.avgRating.toStringAsFixed(1) : '-', isDark)),
                          const SizedBox(width: 10),
                          Expanded(child: _statCard('📅', isEN ? 'Entries' : 'Kayıt', '${_data!.totalEntries}', isDark)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Temperature chart
                      if (_data!.days.isNotEmpty) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(isEN ? 'Temperature Chart' : 'Sıcaklık Grafiği',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A2B35))),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 180,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E3345) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: CustomPaint(
                            size: const Size(double.infinity, 148),
                            painter: _TempChartPainter(_data!.days, isDark),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      // Daily entries
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(isEN ? 'Daily Details' : 'Günlük Detaylar',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A2B35))),
                      ),
                      const SizedBox(height: 12),
                      ..._data!.days.map((d) => _buildDayTile(d, isDark)),
                    ],
                  ),
                ),
    );
  }

  Widget _statCard(String emoji, String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3345) : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A2B35)),
            textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildDayTile(DaySummary d, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3345) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(_condEmoji(d.condition), style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.outfitTitle, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1A2B35))),
                Text('${d.date.day}/${d.date.month} — ${d.temperature.round()}°C', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey)),
              ],
            ),
          ),
          if (d.rating != null)
            Row(children: List.generate(5, (i) => Icon(
              i < d.rating! ? Icons.star_rounded : Icons.star_border_rounded,
              size: 14, color: i < d.rating! ? Colors.amber : (isDark ? Colors.white24 : Colors.grey[300]),
            ))),
        ],
      ),
    );
  }

  String _condEmoji(String c) {
    switch (c) {
      case 'clear': return '☀️';
      case 'clouds': return '⛅';
      case 'rain': return '🌧️';
      case 'snow': return '❄️';
      default: return '🌤️';
    }
  }

  String _condLabel(String c) {
    switch (c) {
      case 'clear': return 'Açık';
      case 'clouds': return 'Bulutlu';
      case 'rain': return 'Yağmurlu';
      case 'snow': return 'Karlı';
      default: return c;
    }
  }
}

class _TempChartPainter extends CustomPainter {
  final List<DaySummary> days;
  final bool isDark;
  _TempChartPainter(this.days, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    if (days.isEmpty) return;
    final temps = days.map((d) => d.temperature).toList();
    final maxT = temps.reduce((a, b) => a > b ? a : b);
    final minT = temps.reduce((a, b) => a < b ? a : b);
    final range = (maxT - minT).clamp(1.0, 100.0);

    final paint = Paint()
      ..color = const Color(0xFF2C6E8A)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()..color = const Color(0xFF2C6E8A);
    final textStyle = TextStyle(fontSize: 10, color: isDark ? Colors.white54 : Colors.grey);

    final path = Path();
    for (int i = 0; i < days.length; i++) {
      final x = i * size.width / (days.length - 1).clamp(1, 100);
      final y = size.height - 20 - ((temps[i] - minT) / range) * (size.height - 40);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 4, dotPaint);

      final tp = TextPainter(
        text: TextSpan(text: '${temps[i].round()}°', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - 18));
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
