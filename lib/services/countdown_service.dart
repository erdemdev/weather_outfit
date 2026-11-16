import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CountdownEvent {
  final String title;
  final String emoji;
  final DateTime eventDate;
  final String? outfitNote;

  CountdownEvent({
    required this.title,
    required this.emoji,
    required this.eventDate,
    this.outfitNote,
  });

  int get daysLeft => eventDate.difference(DateTime.now()).inDays;
  bool get isPast => eventDate.isBefore(DateTime.now());

  Map<String, dynamic> toJson() => {
    'title': title,
    'emoji': emoji,
    'eventDate': eventDate.toIso8601String(),
    'outfitNote': outfitNote,
  };

  factory CountdownEvent.fromJson(Map<String, dynamic> json) => CountdownEvent(
    title: json['title'] as String,
    emoji: json['emoji'] as String,
    eventDate: DateTime.parse(json['eventDate'] as String),
    outfitNote: json['outfitNote'] as String?,
  );
}

class CountdownService {
  static const _key = 'countdown_events';

  static Future<List<CountdownEvent>> getEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    final events = data.map((e) => CountdownEvent.fromJson(jsonDecode(e) as Map<String, dynamic>)).toList();
    events.sort((a, b) => a.eventDate.compareTo(b.eventDate));
    return events;
  }

  static Future<void> addEvent(CountdownEvent event) async {
    final events = await getEvents();
    events.add(event);
    await _save(events);
  }

  static Future<void> removeEvent(int index) async {
    final events = await getEvents();
    if (index >= 0 && index < events.length) {
      events.removeAt(index);
      await _save(events);
    }
  }

  static Future<void> updateOutfitNote(int index, String note) async {
    final events = await getEvents();
    if (index >= 0 && index < events.length) {
      final old = events[index];
      events[index] = CountdownEvent(
        title: old.title,
        emoji: old.emoji,
        eventDate: old.eventDate,
        outfitNote: note,
      );
      await _save(events);
    }
  }

  static Future<List<CountdownEvent>> getUpcoming() async {
    final events = await getEvents();
    return events.where((e) => !e.isPast).toList();
  }

  static Future<void> _save(List<CountdownEvent> events) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, events.map((e) => jsonEncode(e.toJson())).toList());
  }
}
