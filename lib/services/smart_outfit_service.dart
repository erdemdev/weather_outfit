import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SmartOutfitService {
  static const _key = 'outfit_ratings_map';

  /// Puan ekleme/güncelleme — her kombin başlığı için ortalama puan tutar
  static Future<void> recordRating(String outfitTitle, int rating, {
    required double temperature,
    required String condition,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    final map = raw != null
        ? (jsonDecode(raw) as Map<String, dynamic>)
        : <String, dynamic>{};

    final existing = map[outfitTitle] as Map<String, dynamic>? ?? {};
    final count = (existing['count'] as int? ?? 0) + 1;
    final totalScore = (existing['totalScore'] as num? ?? 0).toDouble() + rating;
    final temps = List<double>.from(existing['temps'] as List? ?? []);
    temps.add(temperature);
    if (temps.length > 20) temps.removeAt(0);

    final conditions = List<String>.from(existing['conditions'] as List? ?? []);
    conditions.add(condition);
    if (conditions.length > 20) conditions.removeAt(0);

    map[outfitTitle] = {
      'count': count,
      'totalScore': totalScore,
      'avgScore': totalScore / count,
      'temps': temps,
      'conditions': conditions,
      'lastUsed': DateTime.now().toIso8601String(),
    };

    await prefs.setString(_key, jsonEncode(map));
  }

  /// En iyi kombini öner (sıcaklık + hava durumu + geçmiş uyumu)
  /// Bayesian ortalama ile dengelenir, günlük rotasyon ile çeşitlilik sağlanır.
  static Future<String?> getBestOutfit(double temp, String condition) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;

    final map = jsonDecode(raw) as Map<String, dynamic>;
    final candidates = <MapEntry<String, double>>[];

    for (final entry in map.entries) {
      final data = entry.value as Map<String, dynamic>;
      final count = (data['count'] as int?) ?? 0;
      // En az 2 puan olmalı — tek puanlı ani değişimleri önler
      if (count < 2) continue;

      final totalScore = (data['totalScore'] as num?)?.toDouble() ?? 0;
      // Bayesian ortalama: prior ortalama=3, güç=2 — az veriyle aşırı iyi/kötü görünmesini önler
      final bayesianAvg = (totalScore + 6.0) / (count + 2);
      if (bayesianAvg < 3.2) continue; // Açıkça kötü kombinleri filtrele

      final temps = List<double>.from(data['temps'] as List? ?? []);
      final conditions = List<String>.from(data['conditions'] as List? ?? []);

      // Sıcaklık uyumu — kademeli bonus
      double tempBonus = 0;
      if (temps.isNotEmpty) {
        final avgTemp = temps.reduce((a, b) => a + b) / temps.length;
        final diff = (temp - avgTemp).abs();
        if (diff < 3) {
          tempBonus = 1.0;
        } else if (diff < 7) {
          tempBonus = 0.7;
        } else if (diff < 12) {
          tempBonus = 0.4;
        } else if (diff < 18) {
          tempBonus = 0.1;
        }
      }

      // Hava durumu uyumu
      double condBonus = 0;
      if (conditions.isNotEmpty) {
        final match = conditions.where((c) => c == condition).length;
        condBonus = match / conditions.length;
      }

      // Yakın zamanlarda kullanılma bonusu
      double recencyBonus = 0;
      final lastUsedStr = data['lastUsed'] as String?;
      if (lastUsedStr != null) {
        final lastUsed = DateTime.tryParse(lastUsedStr);
        if (lastUsed != null) {
          final daysSince = DateTime.now().difference(lastUsed).inDays;
          if (daysSince <= 7) {
            recencyBonus = 0.3;
          } else if (daysSince <= 30) {
            recencyBonus = 0.1;
          }
        }
      }

      final score =
          bayesianAvg * 0.50 + tempBonus * 0.25 + condBonus * 0.15 + recencyBonus * 0.10;
      candidates.add(MapEntry(entry.key, score));
    }

    if (candidates.isEmpty) return null;

    // Skora göre sırala
    candidates.sort((a, b) => b.value.compareTo(a.value));

    // En iyi 3 aday arasından günlük rotasyon — her gün farklı, tüm gün aynı
    final poolSize = candidates.length.clamp(1, 3);
    final dayIndex = DateTime.now().day % poolSize;
    return candidates[dayIndex].key;
  }

  /// Tüm puanları getir (istatistik için)
  static Future<Map<String, dynamic>> getAllRatings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return {};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  /// En çok beğenilen N kombin
  static Future<List<MapEntry<String, double>>> getTopRated({int limit = 5}) async {
    final all = await getAllRatings();
    final scored = <MapEntry<String, double>>[];
    for (final e in all.entries) {
      final data = e.value as Map<String, dynamic>;
      final avg = (data['avgScore'] as num?)?.toDouble() ?? 0;
      scored.add(MapEntry(e.key, avg));
    }
    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.take(limit).toList();
  }
}
