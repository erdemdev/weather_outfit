import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'log_service.dart';

class SyncQueueItem {
  final String event;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  const SyncQueueItem({
    required this.event,
    required this.payload,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'event': event,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) => SyncQueueItem(
        event: json['event']?.toString() ?? 'unknown',
        payload: (json['payload'] as Map<String, dynamic>?) ?? {},
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
      );
}

class SyncService {
  static const String _queueKey = 'sync_queue_v1';
  static const String _lastSyncKey = 'last_sync_at_v1';
  static const int _maxQueueSize = 500;

  static const String _baseUrl = String.fromEnvironment(
    'SYNC_BASE_URL',
    defaultValue: '',
  );

  static bool get isConfigured => _baseUrl.isNotEmpty;

  static Future<void> enqueue({
    required String event,
    required Map<String, dynamic> payload,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList(_queueKey) ?? [];
    final item = SyncQueueItem(
      event: event,
      payload: payload,
      createdAt: DateTime.now(),
    );

    queue.add(jsonEncode(item.toJson()));
    if (queue.length > _maxQueueSize) {
      queue.removeRange(0, queue.length - _maxQueueSize);
    }

    await prefs.setStringList(_queueKey, queue);
  }

  static Future<int> pendingCount() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_queueKey) ?? []).length;
  }

  static Future<DateTime?> lastSyncAt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastSyncKey);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  static Future<void> syncPending() async {
    if (!isConfigured) {
      await LogService.info(
        source: 'SyncService.syncPending',
        message: 'SYNC_BASE_URL is empty, skipping sync',
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final queueRaw = prefs.getStringList(_queueKey) ?? [];
    if (queueRaw.isEmpty) {
      return;
    }

    final queue = queueRaw
        .map((e) =>
            SyncQueueItem.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();

    final remaining = <SyncQueueItem>[];
    for (final item in queue) {
      final ok = await _sendItem(item);
      if (!ok) {
        remaining.add(item);
      }
    }

    await prefs.setStringList(
      _queueKey,
      remaining.map((e) => jsonEncode(e.toJson())).toList(),
    );

    await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }

  static Future<bool> _sendItem(SyncQueueItem item) async {
    final uri = Uri.parse('$_baseUrl/sync/events');
    try {
      final response = await http
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(item.toJson()),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }

      await LogService.info(
        source: 'SyncService._sendItem',
        message: 'Sync failed with status ${response.statusCode}',
      );
      return false;
    } catch (e, st) {
      await LogService.captureException(
        source: 'SyncService._sendItem',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }
}
