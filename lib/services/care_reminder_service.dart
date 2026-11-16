import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CareReminder {
  final String itemName;
  final String careType; // wash, dry_clean, iron, repair
  final DateTime dueDate;
  final bool completed;

  CareReminder({
    required this.itemName,
    required this.careType,
    required this.dueDate,
    this.completed = false,
  });

  Map<String, dynamic> toJson() => {
    'itemName': itemName,
    'careType': careType,
    'dueDate': dueDate.toIso8601String(),
    'completed': completed,
  };

  factory CareReminder.fromJson(Map<String, dynamic> j) => CareReminder(
    itemName: j['itemName'] as String,
    careType: j['careType'] as String,
    dueDate: DateTime.parse(j['dueDate'] as String),
    completed: j['completed'] as bool? ?? false,
  );

  CareReminder copyWith({bool? completed}) => CareReminder(
    itemName: itemName,
    careType: careType,
    dueDate: dueDate,
    completed: completed ?? this.completed,
  );

  String get careEmojiTR => switch (careType) {
    'wash' => '🧺',
    'dry_clean' => '🧹',
    'iron' => '♨️',
    'repair' => '🪡',
    _ => '👕',
  };

  String careNameTR() => switch (careType) {
    'wash' => 'Yıkama',
    'dry_clean' => 'Kuru Temizleme',
    'iron' => 'Ütüleme',
    'repair' => 'Tamir',
    _ => careType,
  };

  String careNameEN() => switch (careType) {
    'wash' => 'Wash',
    'dry_clean' => 'Dry Clean',
    'iron' => 'Iron',
    'repair' => 'Repair',
    _ => careType,
  };

  bool get isOverdue => !completed && dueDate.isBefore(DateTime.now());
  bool get isDueToday {
    final now = DateTime.now();
    return !completed && dueDate.year == now.year && dueDate.month == now.month && dueDate.day == now.day;
  }
}

class CareReminderService {
  static const _key = 'care_reminders';

  static Future<List<CareReminder>> getReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data.map((e) => CareReminder.fromJson(jsonDecode(e) as Map<String, dynamic>)).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  static Future<void> addReminder(CareReminder reminder) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    data.add(jsonEncode(reminder.toJson()));
    await prefs.setStringList(_key, data);
  }

  static Future<void> toggleComplete(int index) async {
    final reminders = await getReminders();
    if (index >= 0 && index < reminders.length) {
      reminders[index] = reminders[index].copyWith(completed: !reminders[index].completed);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, reminders.map((r) => jsonEncode(r.toJson())).toList());
    }
  }

  static Future<void> removeReminder(int index) async {
    final reminders = await getReminders();
    if (index >= 0 && index < reminders.length) {
      reminders.removeAt(index);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, reminders.map((r) => jsonEncode(r.toJson())).toList());
    }
  }

  static Future<int> getOverdueCount() async {
    final reminders = await getReminders();
    return reminders.where((r) => r.isOverdue).length;
  }

  static Future<List<CareReminder>> getDueToday() async {
    final reminders = await getReminders();
    return reminders.where((r) => r.isDueToday || r.isOverdue).toList();
  }
}
