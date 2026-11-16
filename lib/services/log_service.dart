import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLogEntry {
  final String level;
  final String source;
  final String message;
  final DateTime timestamp;

  const AppLogEntry({
    required this.level,
    required this.source,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'level': level,
        'source': source,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
      };

  factory AppLogEntry.fromJson(Map<String, dynamic> json) => AppLogEntry(
        level: json['level']?.toString() ?? 'info',
        source: json['source']?.toString() ?? 'app',
        message: json['message']?.toString() ?? '',
        timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
            DateTime.now(),
      );
}

class LogService {
  static const String _storageKey = 'app_logs_v1';
  static const int _maxEntries = 200;

  static bool _initialized = false;
  static bool _handlersAttached = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await info(source: 'bootstrap', message: 'LogService initialized');
  }

  static void attachGlobalHandlers() {
    if (_handlersAttached) return;
    _handlersAttached = true;

    final oldHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      oldHandler?.call(details);
      captureException(
        source: 'FlutterError.onError',
        error: details.exception,
        stackTrace: details.stack ?? StackTrace.current,
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      captureException(
        source: 'PlatformDispatcher.onError',
        error: error,
        stackTrace: stack,
      );
      return false;
    };
  }

  static Future<void> info({
    required String source,
    required String message,
  }) async {
    await _write(
      AppLogEntry(
        level: 'info',
        source: source,
        message: message,
        timestamp: DateTime.now(),
      ),
    );
  }

  static Future<void> captureException({
    required String source,
    required Object error,
    required StackTrace stackTrace,
  }) async {
    final payload = '${error.toString()}\n$stackTrace';
    await _write(
      AppLogEntry(
        level: 'error',
        source: source,
        message: payload,
        timestamp: DateTime.now(),
      ),
    );
  }

  static Future<List<AppLogEntry>> recent({int limit = 50}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    final entries = raw
        .map((e) => AppLogEntry.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (entries.length <= limit) {
      return entries;
    }
    return entries.take(limit).toList();
  }

  static Future<void> _write(AppLogEntry entry) async {
    if (kDebugMode) {
      debugPrint(
          '[${entry.level.toUpperCase()}][${entry.source}] ${entry.message}');
    }

    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_storageKey) ?? [];
    data.add(jsonEncode(entry.toJson()));

    if (data.length > _maxEntries) {
      data.removeRange(0, data.length - _maxEntries);
    }

    await prefs.setStringList(_storageKey, data);
  }
}
