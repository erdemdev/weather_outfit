import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_outfit/l10n/app_localizations.dart';
import 'package:weather_outfit/providers/app_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'theme': 'dark',
      'language': 'en',
      'notifications': true,
      'style': 'male',
      'onboarding_done': true,
      'theme_color': 0x00223344,
    });
  });

  test('loads persisted preferences on initialization', () async {
    final provider = AppProvider();
    await provider.initialization;

    expect(provider.themeMode, ThemeMode.dark);
    expect(provider.language, 'en');
    expect(provider.notificationsEnabled, isTrue);
    expect(provider.stylePreference, 'male');
    expect(provider.onboardingCompleted, isTrue);
    expect(provider.themeColorValue, 0xFF223344);
    expect(AppStrings.lang, 'en');
  });

  test('setLanguage normalizes unsupported locales to tr', () async {
    final provider = AppProvider();
    await provider.initialization;

    await provider.setLanguage('de');

    expect(provider.language, 'tr');
    expect(AppStrings.lang, 'tr');
  });
}
