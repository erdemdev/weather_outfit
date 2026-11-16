import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetEntry {
  final String itemName;
  final String category;
  final double price;
  final DateTime date;

  BudgetEntry({
    required this.itemName,
    required this.category,
    required this.price,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'itemName': itemName,
    'category': category,
    'price': price,
    'date': date.toIso8601String(),
  };

  factory BudgetEntry.fromJson(Map<String, dynamic> j) => BudgetEntry(
    itemName: j['itemName'] as String,
    category: j['category'] as String,
    price: (j['price'] as num).toDouble(),
    date: DateTime.parse(j['date'] as String),
  );
}

class BudgetService {
  static const _key = 'budget_entries';

  static Future<List<BudgetEntry>> getEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data.map((e) => BudgetEntry.fromJson(jsonDecode(e) as Map<String, dynamic>)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static Future<void> addEntry(BudgetEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    data.add(jsonEncode(entry.toJson()));
    await prefs.setStringList(_key, data);
  }

  static Future<void> removeEntry(int index) async {
    final entries = await getEntries();
    if (index >= 0 && index < entries.length) {
      entries.removeAt(index);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, entries.map((e) => jsonEncode(e.toJson())).toList());
    }
  }

  static Future<double> getMonthlyTotal({DateTime? month}) async {
    final entries = await getEntries();
    final m = month ?? DateTime.now();
    return entries
        .where((e) => e.date.year == m.year && e.date.month == m.month)
        .fold<double>(0.0, (sum, e) => sum + e.price);
  }

  static Future<double> getTotalSpent() async {
    final entries = await getEntries();
    return entries.fold<double>(0.0, (sum, e) => sum + e.price);
  }

  static Future<Map<String, double>> getCategorySpending() async {
    final entries = await getEntries();
    final map = <String, double>{};
    for (final e in entries) {
      map[e.category] = (map[e.category] ?? 0) + e.price;
    }
    return map;
  }
}
