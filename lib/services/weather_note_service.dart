import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherNote {
  final String date;
  final String note;
  final String city;
  final double temperature;
  final String condition;

  WeatherNote({
    required this.date,
    required this.note,
    required this.city,
    required this.temperature,
    required this.condition,
  });

  Map<String, dynamic> toJson() => {
    'date': date,
    'note': note,
    'city': city,
    'temperature': temperature,
    'condition': condition,
  };

  factory WeatherNote.fromJson(Map<String, dynamic> json) => WeatherNote(
    date: json['date'] ?? '',
    note: json['note'] ?? '',
    city: json['city'] ?? '',
    temperature: (json['temperature'] as num?)?.toDouble() ?? 0,
    condition: json['condition'] ?? '',
  );
}

class WeatherNoteService {
  static const _key = 'weather_notes';

  static Future<List<WeatherNote>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((e) => WeatherNote.fromJson(jsonDecode(e))).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static Future<void> addNote(WeatherNote note) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.add(jsonEncode(note.toJson()));
    await prefs.setStringList(_key, raw);
  }

  static Future<void> removeNote(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final notes = raw.map((e) => WeatherNote.fromJson(jsonDecode(e))).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    notes.removeAt(index);
    await prefs.setStringList(_key, notes.map((e) => jsonEncode(e.toJson())).toList());
  }
}
