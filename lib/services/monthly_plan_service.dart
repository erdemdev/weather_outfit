import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';

class MonthlyPlanEntry {
  final DateTime date;
  final String outfitTitle;
  final String emoji;
  final String? note;

  MonthlyPlanEntry({
    required this.date,
    required this.outfitTitle,
    required this.emoji,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'outfitTitle': outfitTitle,
    'emoji': emoji,
    'note': note,
  };

  factory MonthlyPlanEntry.fromJson(Map<String, dynamic> json) => MonthlyPlanEntry(
    date: DateTime.parse(json['date'] as String),
    outfitTitle: json['outfitTitle'] as String,
    emoji: json['emoji'] as String,
    note: json['note'] as String?,
  );
}

class MonthlyPlanService {
  static const _key = 'monthly_plan';

  static Future<List<MonthlyPlanEntry>> getPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data
        .map((e) => MonthlyPlanEntry.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> savePlan(List<MonthlyPlanEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, entries.map((e) => jsonEncode(e.toJson())).toList());
  }

  static Future<void> addEntry(MonthlyPlanEntry entry) async {
    final entries = await getPlan();
    // Replace if same date exists
    entries.removeWhere((e) =>
      e.date.year == entry.date.year &&
      e.date.month == entry.date.month &&
      e.date.day == entry.date.day
    );
    entries.add(entry);
    await savePlan(entries);
  }

  static Future<MonthlyPlanEntry?> getEntryForDate(DateTime date) async {
    final entries = await getPlan();
    final match = entries.where((e) =>
      e.date.year == date.year &&
      e.date.month == date.month &&
      e.date.day == date.day
    );
    return match.isNotEmpty ? match.first : null;
  }

  static Future<List<MonthlyPlanEntry>> getEntriesForMonth(int year, int month) async {
    final entries = await getPlan();
    return entries.where((e) => e.date.year == year && e.date.month == month).toList();
  }

  /// Auto-generate a 30-day plan from outfit engine
  static Future<List<MonthlyPlanEntry>> autoGenerate(WeatherData weather) async {
    final entries = <MonthlyPlanEntry>[];
    final now = DateTime.now();

    final outfitStyles = [
      ('☀️', 'Güneşli Stil'), ('🌧️', 'Yağmur Kombini'), ('❄️', 'Kış Stili'),
      ('🌸', 'Bahar Enerjisi'), ('🍂', 'Sonbahar Tonu'), ('👔', 'İş Stili'),
      ('😎', 'Casual Gün'), ('🏃', 'Spor Gün'), ('🎉', 'Parti Stili'),
      ('☕', 'Kafe Günü'), ('🌿', 'Doğa Yürüyüşü'), ('📚', 'Kütüphane'),
      ('🎬', 'Sinema'), ('🛍️', 'Alışveriş'), ('🍽️', 'Akşam Yemeği'),
    ];

    for (int i = 0; i < 30; i++) {
      final date = now.add(Duration(days: i));
      final style = outfitStyles[i % outfitStyles.length];
      entries.add(MonthlyPlanEntry(
        date: date,
        outfitTitle: style.$2,
        emoji: style.$1,
      ));
    }

    await savePlan(entries);
    return entries;
  }
}
