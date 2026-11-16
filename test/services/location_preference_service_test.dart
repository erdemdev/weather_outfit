import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_outfit/services/location_preference_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults to GPS mode', () async {
    expect(await LocationPreferenceService.useGps(), isTrue);
    expect(await LocationPreferenceService.getLastCity(), isNull);
  });

  test('saveLastCity switches off GPS mode', () async {
    await LocationPreferenceService.saveLastCity('Ankara');

    expect(await LocationPreferenceService.getLastCity(), 'ankara');
    expect(await LocationPreferenceService.useGps(), isFalse);
  });

  test('setUseGps restores GPS mode', () async {
    await LocationPreferenceService.saveLastCity('Izmir');
    await LocationPreferenceService.setUseGps(true);

    expect(await LocationPreferenceService.useGps(), isTrue);
    expect(await LocationPreferenceService.getLastCity(), 'izmir');
  });
}
