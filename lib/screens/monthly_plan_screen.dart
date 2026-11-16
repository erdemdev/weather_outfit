import 'package:flutter/material.dart';
import '../services/monthly_plan_service.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import '../l10n/app_localizations.dart';

class MonthlyPlanScreen extends StatefulWidget {
  const MonthlyPlanScreen({super.key});

  @override
  State<MonthlyPlanScreen> createState() => _MonthlyPlanScreenState();
}

class _MonthlyPlanScreenState extends State<MonthlyPlanScreen> {
  List<MonthlyPlanEntry> _entries = [];
  bool _loading = true;
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    setState(() => _loading = true);
    final entries = await MonthlyPlanService.getEntriesForMonth(_year, _month);
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _autoGenerate() async {
    setState(() => _loading = true);
    try {
      final weather = await WeatherService.getWeatherByGPS();
      await MonthlyPlanService.autoGenerate(weather);
    } catch (_) {
      await MonthlyPlanService.autoGenerate(WeatherData.demo());
    }
    await _loadPlan();
  }

  MonthlyPlanEntry? _getEntry(int day) {
    return _entries.where((e) => e.date.day == day).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';
    final daysInMonth = DateTime(_year, _month + 1, 0).day;
    final firstWeekday = DateTime(_year, _month, 1).weekday;
    final monthNames = isEN
        ? ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
        : ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Monthly Plan' : 'Aylık Plan'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: isEN ? 'Auto Generate' : 'Otomatik Oluştur',
            onPressed: _autoGenerate,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Month nav
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (_month == 1) { _month = 12; _year--; } else { _month--; }
                        });
                        _loadPlan();
                      },
                      icon: Icon(Icons.chevron_left, color: isDark ? Colors.white : Colors.black87),
                    ),
                    Text('${monthNames[_month - 1]} $_year', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (_month == 12) { _month = 1; _year++; } else { _month++; }
                        });
                        _loadPlan();
                      },
                      icon: Icon(Icons.chevron_right, color: isDark ? Colors.white : Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Day headers
                Row(
                  children: (isEN ? ['M', 'T', 'W', 'T', 'F', 'S', 'S'] : ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz']).map((d) =>
                    Expanded(child: Center(child: Text(d, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white54 : Colors.black45)))),
                  ).toList(),
                ),
                const SizedBox(height: 8),
                // Calendar grid
                ...List.generate(((daysInMonth + firstWeekday - 1) / 7).ceil(), (week) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: List.generate(7, (weekday) {
                        final dayIndex = week * 7 + weekday - firstWeekday + 2;
                        if (dayIndex < 1 || dayIndex > daysInMonth) return const Expanded(child: SizedBox(height: 56));

                        final entry = _getEntry(dayIndex);
                        final isToday = dayIndex == DateTime.now().day && _month == DateTime.now().month && _year == DateTime.now().year;

                        return Expanded(
                          child: Container(
                            height: 56,
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: isToday
                                  ? const Color(0xFF2C6E8A).withValues(alpha: 0.2)
                                  : entry != null
                                      ? (isDark ? const Color(0xFF1B2A3D) : Colors.white)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: isToday ? Border.all(color: const Color(0xFF2C6E8A), width: 2) : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('$dayIndex', style: TextStyle(fontSize: 11, fontWeight: isToday ? FontWeight.bold : FontWeight.normal, color: isDark ? Colors.white70 : Colors.black54)),
                                if (entry != null) Text(entry.emoji, style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                }),
                const SizedBox(height: 24),
                // Today's plan detail
                if (_entries.isNotEmpty) ...[
                  Text(isEN ? 'Planned Outfits' : 'Planlanan Kombinler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 12),
                  ..._entries.take(7).map((entry) => Card(
                    color: isDark ? const Color(0xFF1B2A3D) : Colors.white,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Text(entry.emoji, style: const TextStyle(fontSize: 24)),
                      title: Text(entry.outfitTitle, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                      subtitle: Text('${entry.date.day}/${entry.date.month}', style: TextStyle(color: isDark ? Colors.white54 : Colors.black45)),
                    ),
                  )),
                ] else
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.calendar_month, size: 48, color: isDark ? Colors.white30 : Colors.black26),
                        const SizedBox(height: 12),
                        Text(isEN ? 'No plan for this month' : 'Bu ay için plan yok', style: TextStyle(color: isDark ? Colors.white54 : Colors.black45)),
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          onPressed: _autoGenerate,
                          icon: const Icon(Icons.auto_awesome),
                          label: Text(isEN ? 'Auto Generate' : 'Otomatik Oluştur'),
                          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2C6E8A)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
