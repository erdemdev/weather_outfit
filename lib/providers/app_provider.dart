import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../services/notification_service.dart';
import '../services/profile_service.dart';

class AppProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  String _language = 'tr';
  bool _notificationsEnabled = false;
  String _stylePreference = 'unisex'; // 'male', 'female', 'unisex'
  bool _onboardingCompleted = false;
  String _activeProfileName = 'Ben';
  int _activeProfileIndex = 0;
  int _themeColorValue = 0xFF2C6E8A;
  bool _isInitialized = false;
  late final Future<void> _initialization;

  ThemeMode get themeMode => _themeMode;
  String get language => _language;
  bool get isDark => _themeMode == ThemeMode.dark;
  bool get notificationsEnabled => _notificationsEnabled;
  String get stylePreference => _stylePreference;
  bool get onboardingCompleted => _onboardingCompleted;
  String get activeProfileName => _activeProfileName;
  int get activeProfileIndex => _activeProfileIndex;
  int get themeColorValue => _themeColorValue;
  Color get themeColor => Color(_themeColorValue);
  bool get isInitialized => _isInitialized;
  Future<void> get initialization => _initialization;

  AppProvider() {
    _initialization = _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _themeMode = (prefs.getString('theme') == 'dark')
          ? ThemeMode.dark
          : ThemeMode.light;
      _language = _normalizeLanguage(prefs.getString('language') ?? 'tr');
      _notificationsEnabled = prefs.getBool('notifications') ?? false;
      _stylePreference = prefs.getString('style') ?? 'unisex';
      _onboardingCompleted = prefs.getBool('onboarding_done') ?? false;
      _themeColorValue = prefs.getInt('theme_color') ?? 0xFF2C6E8A;
      _themeColorValue = _sanitizeThemeColor(_themeColorValue);
      AppStrings.setLanguage(_language);
      // Load active profile
      _activeProfileIndex = await ProfileService.getActiveIndex();
      final profile = await ProfileService.getActiveProfile();
      _activeProfileName = profile.name;
      if (profile.style != 'unisex') {
        _stylePreference = profile.style;
      }
      if (_notificationsEnabled) {
        await _rescheduleNotifications();
      }
    } catch (_) {
      // Varsayılan değerlerle devam et
      AppStrings.setLanguage(_language);
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', isDark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = _normalizeLanguage(lang);
    AppStrings.setLanguage(_language);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _language);
    if (_notificationsEnabled) {
      await _rescheduleNotifications();
    }
    notifyListeners();
  }

  Future<void> _rescheduleNotifications() async {
    try {
      await NotificationService.cancelAll();
      await NotificationService.scheduleDailyNotification();
    } catch (_) {
      // Bildirim plugin'i hazır değilse (ör. unit test) sessizce atla
    }
  }

  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', _notificationsEnabled);
    notifyListeners();
  }

  Future<void> setStylePreference(String style) async {
    _stylePreference = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('style', style);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _onboardingCompleted = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    notifyListeners();
  }

  Future<void> setActiveProfile(int index) async {
    await ProfileService.setActiveIndex(index);
    _activeProfileIndex = index;
    final profile = await ProfileService.getActiveProfile();
    _activeProfileName = profile.name;
    _stylePreference = profile.style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('style', profile.style);
    notifyListeners();
  }

  Future<void> setThemeColor(int colorValue) async {
    _themeColorValue = _sanitizeThemeColor(colorValue);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_color', _themeColorValue);
    notifyListeners();
  }

  String _normalizeLanguage(String lang) {
    return (lang == 'tr' || lang == 'en') ? lang : 'tr';
  }

  int _sanitizeThemeColor(int value) {
    if (value < 0 || value > 0xFFFFFFFF) {
      return 0xFF2C6E8A;
    }
    if ((value & 0xFF000000) == 0) {
      return value | 0xFF000000;
    }
    return value;
  }
}
