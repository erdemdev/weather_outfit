import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'sync_service.dart';

class HistoryEntry {
  final String city;
  final double temperature;
  final String condition;
  final String outfitTitle;
  final int? rating;
  final DateTime date;

  HistoryEntry({
    required this.city,
    required this.temperature,
    required this.condition,
    required this.outfitTitle,
    this.rating,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'city': city,
        'temperature': temperature,
        'condition': condition,
        'outfitTitle': outfitTitle,
        'rating': rating,
        'date': date.toIso8601String(),
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        city: json['city'] as String,
        temperature: (json['temperature'] as num).toDouble(),
        condition: json['condition'] as String,
        outfitTitle: json['outfitTitle'] as String,
        rating: json['rating'] as int?,
        date: DateTime.parse(json['date'] as String),
      );

  HistoryEntry copyWith({int? rating}) => HistoryEntry(
        city: city,
        temperature: temperature,
        condition: condition,
        outfitTitle: outfitTitle,
        rating: rating ?? this.rating,
        date: date,
      );
}

class HistoryService {
  static const _key = 'outfit_history';

  static Future<List<HistoryEntry>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data
        .map(
            (e) => HistoryEntry.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static Future<void> addEntry(HistoryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    data.add(jsonEncode(entry.toJson()));
    // Son 50 kayıt
    if (data.length > 50) data.removeAt(0);
    await prefs.setStringList(_key, data);
    await SyncService.enqueue(
      event: 'history.entry.added',
      payload: entry.toJson(),
    );
  }

  static Future<void> updateRating(int index, int rating) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    final entries = data
        .map(
            (e) => HistoryEntry.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    if (index >= 0 && index < entries.length) {
      entries[index] = entries[index].copyWith(rating: rating);
      await prefs.setStringList(
        _key,
        entries.map((e) => jsonEncode(e.toJson())).toList(),
      );
      await SyncService.enqueue(
        event: 'history.entry.rated',
        payload: {
          'index': index,
          'rating': rating,
          'entry': entries[index].toJson(),
        },
      );
    }
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
