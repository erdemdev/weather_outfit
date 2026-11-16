import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum LaundryStatus { clean, dirty, washing }

class LaundryItem {
  final String itemName;
  final String category;
  final int colorValue;
  final LaundryStatus status;
  final DateTime lastChanged;

  LaundryItem({
    required this.itemName,
    required this.category,
    required this.colorValue,
    required this.status,
    required this.lastChanged,
  });

  Map<String, dynamic> toJson() => {
    'itemName': itemName,
    'category': category,
    'colorValue': colorValue,
    'status': status.index,
    'lastChanged': lastChanged.toIso8601String(),
  };

  factory LaundryItem.fromJson(Map<String, dynamic> json) => LaundryItem(
    itemName: json['itemName'] as String,
    category: json['category'] as String,
    colorValue: json['colorValue'] as int,
    status: LaundryStatus.values[json['status'] as int],
    lastChanged: DateTime.parse(json['lastChanged'] as String),
  );

  LaundryItem copyWith({LaundryStatus? status}) => LaundryItem(
    itemName: itemName,
    category: category,
    colorValue: colorValue,
    status: status ?? this.status,
    lastChanged: DateTime.now(),
  );
}

class LaundryService {
  static const _key = 'laundry_tracking';

  static Future<List<LaundryItem>> getItems() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data.map((e) => LaundryItem.fromJson(jsonDecode(e) as Map<String, dynamic>)).toList();
  }

  static Future<void> addItem(LaundryItem item) async {
    final items = await getItems();
    items.add(item);
    await _save(items);
  }

  static Future<void> updateStatus(int index, LaundryStatus status) async {
    final items = await getItems();
    if (index >= 0 && index < items.length) {
      items[index] = items[index].copyWith(status: status);
      await _save(items);
    }
  }

  static Future<void> removeItem(int index) async {
    final items = await getItems();
    if (index >= 0 && index < items.length) {
      items.removeAt(index);
      await _save(items);
    }
  }

  static Future<void> markAllClean() async {
    final items = await getItems();
    final updated = items.map((i) => i.copyWith(status: LaundryStatus.clean)).toList();
    await _save(updated);
  }

  static Future<int> getCleanCount() async {
    final items = await getItems();
    return items.where((i) => i.status == LaundryStatus.clean).length;
  }

  static Future<int> getDirtyCount() async {
    final items = await getItems();
    return items.where((i) => i.status == LaundryStatus.dirty).length;
  }

  static Future<void> _save(List<LaundryItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, items.map((e) => jsonEncode(e.toJson())).toList());
  }
}
