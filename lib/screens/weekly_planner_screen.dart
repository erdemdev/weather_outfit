import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../models/outfit_model.dart';
import '../l10n/app_localizations.dart';

class WeeklyPlannerScreen extends StatefulWidget {
  final List<ForecastDay> forecast;

  const WeeklyPlannerScreen({super.key, required this.forecast});

  @override
  State<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen> {
  final Map<int, String> _customNotes = {};

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('weekly_notes');
    if (raw != null) {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      setState(() {
        for (final e in map.entries) {
          _customNotes[int.parse(e.key)] = e.value as String;
        }
      });
    }
  }

  Future<void> _saveNote(int dayIndex, String note) async {
    setState(() {
      if (note.isEmpty) {
        _customNotes.remove(dayIndex);
      } else {
        _customNotes[dayIndex] = note;
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('weekly_notes',
        jsonEncode(_customNotes.map((k, v) => MapEntry(k.toString(), v))));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('weekly_outfit')),
        backgroundColor:
            isDark ? const Color(0xFF1A2B35) : const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1A2B35), const Color(0xFF0D1B2A)]
                : [const Color(0xFFF5F9FC), Colors.white],
          ),
        ),
        child: widget.forecast.isEmpty
            ? Center(
                child: Text(
                  AppStrings.get('no_forecast'),
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: widget.forecast.length,
                itemBuilder: (ctx, i) => _DayCard(
                  day: widget.forecast[i],
                  dayIndex: i,
                  isToday: i == 0,
                  isDark: isDark,
                  note: _customNotes[i],
                  onSaveNote: (note) => _saveNote(i, note),
                ),
              ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final ForecastDay day;
  final int dayIndex;
  final bool isToday;
  final bool isDark;
  final String? note;
  final ValueChanged<String> onSaveNote;

  const _DayCard({
    required this.day,
    required this.dayIndex,
    required this.isToday,
    required this.isDark,
    required this.note,
    required this.onSaveNote,
  });

  @override
  Widget build(BuildContext context) {
    final outfit = OutfitEngine.getRecommendationForForecast(day);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3345) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: outfit.primaryColor.withOpacity(isDark ? 0.15 : 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: isToday
            ? Border.all(color: outfit.primaryColor, width: 2)
            : Border.all(
                color: isDark ? Colors.white10 : Colors.grey.shade200,
              ),
      ),
      child: Column(
        children: [
          _buildDayHeader(outfit),
          _buildOutfitItems(outfit),
          if (note != null && note!.isNotEmpty) _buildNote(),
          _buildNoteButton(context),
          if (outfit.alerts.isNotEmpty) _buildAlerts(outfit),
        ],
      ),
    );
  }

  Widget _buildDayHeader(OutfitRecommendation outfit) {
    final dayName =
        isToday ? AppStrings.get('today') : AppStrings.fullDayName(day.date.weekday);
    final dateStr =
        '${day.date.day}.${day.date.month.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            outfit.primaryColor.withOpacity(isDark ? 0.3 : 0.15),
            outfit.primaryColor.withOpacity(isDark ? 0.15 : 0.05),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Row(
        children: [
          Text(
            _getConditionEmoji(day.condition),
            style: const TextStyle(fontSize: 36),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$dayName — $dateStr',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A2B35),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  outfit.title,
                  style: TextStyle(
                    fontSize: 13,
                    color: outfit.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '${day.tempMax.round()}°',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1A2B35),
                ),
              ),
              Text(
                '${day.tempMin.round()}°',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitItems(OutfitRecommendation outfit) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: outfit.items.map((item) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: item.color.withOpacity(isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: item.color.withOpacity(isDark ? 0.3 : 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNote() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? Colors.teal.withOpacity(0.1) : const Color(0xFFE0F7FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Text('📝', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              note!,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.teal[200] : Colors.teal[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteButton(BuildContext context) {
    final isEN = AppStrings.lang == 'en';
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: GestureDetector(
        onTap: () {
          final controller = TextEditingController(text: note ?? '');
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E3345) : Colors.white,
              title: Text(
                isEN ? 'Add note' : 'Not ekle',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              content: TextField(
                controller: controller,
                maxLines: 3,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: isEN ? 'e.g. Meeting at 10am...' : 'ör. 10\'da toplantı...',
                  hintStyle: TextStyle(color: isDark ? Colors.white38 : null),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(isEN ? 'Cancel' : 'İptal'),
                ),
                TextButton(
                  onPressed: () {
                    onSaveNote(controller.text.trim());
                    Navigator.pop(ctx);
                  },
                  child: Text(isEN ? 'Save' : 'Kaydet'),
                ),
              ],
            ),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_note_rounded, size: 16,
                color: isDark ? Colors.white38 : Colors.grey[400]),
            const SizedBox(width: 4),
            Text(
              note != null ? (isEN ? 'Edit note' : 'Notu düzenle') : (isEN ? 'Add note' : 'Not ekle'),
              style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlerts(OutfitRecommendation outfit) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.amber.withOpacity(0.1)
            : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: outfit.alerts.take(2).map((alert) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              alert,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.amber[200] : const Color(0xFF5A4200),
              ),
            ),
          );
        }).toList(),
      ),
    );
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
      default:
        return '🌤️';
    }
  }
}
