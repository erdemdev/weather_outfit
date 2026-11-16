import '../services/history_service.dart';

class DaySummary {
  final DateTime date;
  final double temperature;
  final String condition;
  final String outfitTitle;
  final int? rating;

  const DaySummary({
    required this.date,
    required this.temperature,
    required this.condition,
    required this.outfitTitle,
    this.rating,
  });
}

class WeeklySummaryData {
  final List<DaySummary> days;
  final double avgTemp;
  final double maxTemp;
  final double minTemp;
  final String topOutfit;
  final String topCondition;
  final double avgRating;
  final int totalEntries;

  const WeeklySummaryData({
    required this.days,
    required this.avgTemp,
    required this.maxTemp,
    required this.minTemp,
    required this.topOutfit,
    required this.topCondition,
    required this.avgRating,
    required this.totalEntries,
  });
}

class WeeklySummaryService {
  static Future<WeeklySummaryData> getSummary() async {
    final history = await HistoryService.getHistory();
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final weekEntries = history.where((e) => e.date.isAfter(weekAgo)).toList();

    if (weekEntries.isEmpty) {
      return const WeeklySummaryData(
        days: [],
        avgTemp: 0,
        maxTemp: 0,
        minTemp: 0,
        topOutfit: '-',
        topCondition: '-',
        avgRating: 0,
        totalEntries: 0,
      );
    }

    final days = weekEntries.map((e) => DaySummary(
      date: e.date,
      temperature: e.temperature,
      condition: e.condition,
      outfitTitle: e.outfitTitle,
      rating: e.rating,
    )).toList();

    final temps = weekEntries.map((e) => e.temperature);
    final avgTemp = temps.reduce((a, b) => a + b) / temps.length;
    final maxTemp = temps.reduce((a, b) => a > b ? a : b);
    final minTemp = temps.reduce((a, b) => a < b ? a : b);

    final outfitCounts = <String, int>{};
    final condCounts = <String, int>{};
    for (final e in weekEntries) {
      outfitCounts[e.outfitTitle] = (outfitCounts[e.outfitTitle] ?? 0) + 1;
      condCounts[e.condition] = (condCounts[e.condition] ?? 0) + 1;
    }

    final topOutfit = outfitCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final topCond = condCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    final rated = weekEntries.where((e) => e.rating != null);
    final avgRating = rated.isNotEmpty
        ? rated.map((e) => e.rating!).reduce((a, b) => a + b) / rated.length
        : 0.0;

    return WeeklySummaryData(
      days: days,
      avgTemp: avgTemp,
      maxTemp: maxTemp,
      minTemp: minTemp,
      topOutfit: topOutfit,
      topCondition: topCond,
      avgRating: avgRating,
      totalEntries: weekEntries.length,
    );
  }
}
