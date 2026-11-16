import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_outfit/services/history_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('addEntry stores and returns history items sorted by date', () async {
    final oldEntry = HistoryEntry(
      city: 'Adana',
      temperature: 24,
      condition: 'clear',
      outfitTitle: 'Casual',
      date: DateTime(2026, 1, 1),
    );
    final newEntry = HistoryEntry(
      city: 'Izmir',
      temperature: 20,
      condition: 'clouds',
      outfitTitle: 'Layered',
      date: DateTime(2026, 2, 1),
    );

    await HistoryService.addEntry(oldEntry);
    await HistoryService.addEntry(newEntry);

    final history = await HistoryService.getHistory();

    expect(history.length, 2);
    expect(history.first.city, 'Izmir');
    expect(history.last.city, 'Adana');
  });

  test('clearHistory removes all entries', () async {
    await HistoryService.addEntry(
      HistoryEntry(
        city: 'Bursa',
        temperature: 16,
        condition: 'rain',
        outfitTitle: 'Rain ready',
        date: DateTime.now(),
      ),
    );

    await HistoryService.clearHistory();
    final history = await HistoryService.getHistory();

    expect(history, isEmpty);
  });
}
