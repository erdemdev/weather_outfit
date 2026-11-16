import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackupService {
  static const _backupKeys = [
    'my_wardrobe',
    'outfit_history',
    'favorite_outfits',
    'favorite_cities',
    'outfit_ratings_map',
    'outfit_gallery',
    'calendar_events',
    'weekly_notes',
    'profiles_list',
    'active_profile',
    'achievement_progress',
    'achievement_unlocked',
    'achievement_cities',
    'achievement_weathers',
    'budget_entries',
    'care_reminders',
  ];

  /// Tüm verileri JSON string olarak dışa aktar
  static Future<String> exportToJson() async {
    final prefs = await SharedPreferences.getInstance();
    final data = <String, dynamic>{};

    for (final key in _backupKeys) {
      final strList = prefs.getStringList(key);
      if (strList != null) {
        data[key] = {'type': 'stringList', 'value': strList};
        continue;
      }
      final str = prefs.getString(key);
      if (str != null) {
        data[key] = {'type': 'string', 'value': str};
        continue;
      }
      final intVal = prefs.getInt(key);
      if (intVal != null) {
        data[key] = {'type': 'int', 'value': intVal};
        continue;
      }
      final boolVal = prefs.getBool(key);
      if (boolVal != null) {
        data[key] = {'type': 'bool', 'value': boolVal};
      }
    }

    data['_backup_date'] = {'type': 'string', 'value': DateTime.now().toIso8601String()};
    data['_app_version'] = {'type': 'string', 'value': '1.0.0'};

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// JSON dosyasına kaydet ve yolu döndür
  static Future<String> exportToFile() async {
    final json = await exportToJson();
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    final file = File('${dir.path}/hava_kombin_yedek_$timestamp.json');
    await file.writeAsString(json);
    return file.path;
  }

  /// JSON stringden verileri geri yükle
  static Future<int> importFromJson(String jsonStr) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    int restored = 0;

    for (final entry in data.entries) {
      if (entry.key.startsWith('_')) continue; // meta fields
      final info = entry.value as Map<String, dynamic>;
      final type = info['type'] as String;
      final value = info['value'];

      switch (type) {
        case 'stringList':
          await prefs.setStringList(entry.key, List<String>.from(value as List));
          restored++;
        case 'string':
          await prefs.setString(entry.key, value as String);
          restored++;
        case 'int':
          await prefs.setInt(entry.key, value as int);
          restored++;
        case 'bool':
          await prefs.setBool(entry.key, value as bool);
          restored++;
      }
    }
    return restored;
  }

  /// Dosyadan geri yükle
  static Future<int> importFromFile(String path) async {
    final file = File(path);
    if (!await file.exists()) throw Exception('Dosya bulunamadı');
    final json = await file.readAsString();
    return importFromJson(json);
  }

  /// Yedek tarihini al
  static String? getBackupDate(String jsonStr) {
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final meta = data['_backup_date'] as Map<String, dynamic>?;
      return meta?['value'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Tüm verilerin boyut bilgisi
  static Future<Map<String, int>> getDataStats() async {
    final prefs = await SharedPreferences.getInstance();
    final stats = <String, int>{};
    for (final key in _backupKeys) {
      final strList = prefs.getStringList(key);
      if (strList != null) {
        stats[key] = strList.length;
      }
    }
    return stats;
  }
}
