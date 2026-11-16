import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_outfit/services/notification_throttle_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('morning notification is limited to once per day', () async {
    expect(await NotificationThrottleService.shouldSendMorningNotification(),
        isTrue);

    await NotificationThrottleService.markMorningNotificationSent();

    expect(await NotificationThrottleService.shouldSendMorningNotification(),
        isFalse);
  });

  test('umbrella alert is limited to once per day per city', () async {
    expect(
        await NotificationThrottleService.shouldSendUmbrellaAlert('Ankara'),
        isTrue);

    await NotificationThrottleService.markUmbrellaAlertSent('Ankara');

    expect(
        await NotificationThrottleService.shouldSendUmbrellaAlert('Ankara'),
        isFalse);
    expect(
        await NotificationThrottleService.shouldSendUmbrellaAlert('Izmir'),
        isTrue);
  });
}
