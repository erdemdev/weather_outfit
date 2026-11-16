import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/weather_model.dart';
import '../models/outfit_model.dart';
import '../services/location_preference_service.dart';
import '../services/cache_service.dart';
import '../services/weather_service.dart';
import '../services/favorites_service.dart';
import '../services/history_service.dart';
import '../services/favorite_outfit_service.dart';
import '../services/widget_service.dart';
import '../services/smart_outfit_service.dart';
import '../services/color_harmony_service.dart';
import '../services/achievement_service.dart';
import '../services/gallery_service.dart';
import '../services/notification_service.dart';
import '../services/notification_throttle_service.dart';
import '../services/feedback_service.dart';
import '../providers/app_provider.dart';
import '../utils/contrast_utils.dart';
import '../l10n/app_localizations.dart';
import '../widgets/weather_header.dart';
import '../widgets/outfit_card.dart';
import '../widgets/forecast_strip.dart';
import '../widgets/alert_banner.dart';
import '../widgets/weather_stats_row.dart';
import '../widgets/weather_background.dart';
import '../widgets/uv_index_card.dart';
import '../widgets/aqi_card.dart';
import '../widgets/hourly_chart.dart';
import '../widgets/color_palette.dart';
import '../widgets/outfit_rating.dart';
import '../widgets/temperature_chart.dart';
import 'weekly_planner_screen.dart';
import 'settings_sheet.dart';
import 'history_screen.dart';
import 'wardrobe_screen.dart';
import 'travel_screen.dart';
import 'calendar_screen.dart';
import 'gallery_screen.dart';
import 'achievements_screen.dart';
import 'wardrobe_stats_screen.dart';
import 'style_challenge_screen.dart';
import 'seasonal_guide_screen.dart';
import 'budget_screen.dart';
import 'care_reminder_screen.dart';
import 'weekly_report_screen.dart';
import 'fashion_tips_screen.dart';
import 'outfit_search_screen.dart';
import 'weather_compare_screen.dart';
import 'trend_analysis_screen.dart';
import 'backup_screen.dart';
import 'event_outfit_screen.dart';
import 'mood_outfit_screen.dart';
import 'combo_generator_screen.dart';
import 'laundry_screen.dart';
import 'shopping_list_screen.dart';
import 'dashboard_screen.dart';
import 'outfit_remix_screen.dart';
import 'countdown_screen.dart';
import 'tag_filter_screen.dart';
import 'color_trends_screen.dart';

import 'clothing_photo_screen.dart';
import 'ai_assistant_screen.dart';
import 'location_outfit_screen.dart';
import 'friend_outfit_screen.dart';
import 'monthly_plan_screen.dart';
import 'style_score_screen.dart';
import 'comfort_screen.dart';
import 'capsule_wardrobe_screen.dart';
import 'color_analysis_screen.dart';
import 'multi_city_screen.dart';
import 'weather_alert_screen.dart';
import 'weather_note_screen.dart';
import 'weekly_summary_screen.dart';
import 'packing_screen.dart';
import 'streak_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  WeatherData? _weather;
  OutfitRecommendation? _outfit;
  bool _loading = true;
  String? _error;
  int _selectedForecastIndex = 0;
  int? _outfitRating;
  bool _isFavoriteOutfit = false;
  String? _smartSuggestion;
  bool _isOfflineData = false;
  bool _isRefreshing = false;
  bool _useGps = true;
  String? _activeCity;
  DateTime? _lastUpdated;
  String _cachedOutfitStyle = '';
  final Map<int, OutfitRecommendation> _forecastOutfitCache = {};
  final _searchController = TextEditingController();
  final _screenshotController = ScreenshotController();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _bootstrapWeather();
    _initFeedback();
  }

  Future<void> _bootstrapWeather() async {
    final cached = await CacheService.getCachedWeather();
    if (cached != null && mounted) {
      _showCachedWeather(cached);
    }

    final useGps = await LocationPreferenceService.useGps();
    if (!mounted) return;

    if (useGps) {
      await _loadWeatherByGPS(silent: cached != null);
    } else {
      final lastCity = await LocationPreferenceService.getLastCity();
      if (lastCity != null && lastCity.isNotEmpty) {
        await _loadWeather(lastCity, silent: cached != null);
      } else {
        await _loadWeatherByGPS(silent: cached != null);
      }
    }
  }

  void _showCachedWeather(WeatherData cached) {
    final style = context.read<AppProvider>().stylePreference;
    final outfit = OutfitEngine.getRecommendation(cached, style: style);
    setState(() {
      _weather = cached;
      _outfit = outfit;
      _cachedOutfitStyle = style;
      _forecastOutfitCache[0] = outfit;
      _loading = false;
      _isOfflineData = true;
      _activeCity = cached.city;
    });
    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _refreshCurrent() async {
    if (_useGps) {
      await _loadWeatherByGPS(silent: _weather != null);
    } else if (_activeCity != null && _activeCity!.isNotEmpty) {
      await _loadWeather(_activeCity!, silent: _weather != null);
    } else {
      await _loadWeatherByGPS(silent: _weather != null);
    }
  }

  void _beginLoad({bool silent = false}) {
    if (silent && _weather != null) {
      setState(() => _isRefreshing = true);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _isOfflineData = false;
      _selectedForecastIndex = 0;
      _outfitRating = null;
      _forecastOutfitCache.clear();
    });
    _fadeController.reset();
    _slideController.reset();
  }

  Future<void> _applyWeatherSuccess(
    WeatherData weather,
    OutfitRecommendation outfit,
    String style,
  ) async {
    setState(() {
      _weather = weather;
      _outfit = outfit;
      _cachedOutfitStyle = style;
      _forecastOutfitCache[0] = outfit;
      _isOfflineData = WeatherService.lastFetchFromCache;
      _loading = false;
      _isRefreshing = false;
      _lastUpdated = DateTime.now();
      _activeCity = weather.city;
    });
    _fadeController.forward();
    _slideController.forward();
    await _saveToHistory(weather, outfit);
    await _checkFavoriteOutfit(outfit.title);
    WidgetService.updateWidget(
      temperature: weather.temperature,
      feelsLike: weather.feelsLike,
      city: weather.city,
      condition: weather.condition,
      precipitationChance: weather.precipitationChance,
      outfit: outfit,
    );
    _triggerSmartNotifications(weather, outfit);
  }

  void _showRefreshErrorSnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.get('refresh_failed')),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatLastUpdated() {
    if (_lastUpdated == null) return '';
    final diff = DateTime.now().difference(_lastUpdated!);
    if (diff.inMinutes < 1) return AppStrings.get('updated_now');
    return '${diff.inMinutes} ${AppStrings.get('updated_minutes')}';
  }

  Future<void> _initFeedback() async {
    await FeedbackService.recordLaunch();
    // Hava yüklendikten 2 saniye sonra prompt kontrolü yap
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final should = await FeedbackService.shouldShowPrompt();
    if (should && mounted) {
      await FeedbackService.showFeedbackDialog(context);
    }
  }

  Future<void> _loadWeatherByGPS({bool silent = false}) async {
    _beginLoad(silent: silent);

    try {
      final style = context.read<AppProvider>().stylePreference;
      final weather = await WeatherService.getWeatherByGPS();
      if (!mounted) return;
      await LocationPreferenceService.setUseGps(true);
      final outfit = OutfitEngine.getRecommendation(weather, style: style);
      setState(() => _useGps = true);
      await _applyWeatherSuccess(weather, outfit, style);
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      final lower = errorMsg.toLowerCase();
      final isLocationError = lower.contains('izni') ||
          lower.contains('permission') ||
          lower.contains('gps') ||
          lower.contains('konum servisi') ||
          lower.contains('konum alınamadı');

      if (isLocationError) {
        if (silent && _weather != null) {
          if (mounted) setState(() => _isRefreshing = false);
          _showRefreshErrorSnackBar();
          return;
        }
        final cachedCity = await CacheService.getCachedCity();
        final fallbackCity =
            (cachedCity != null && cachedCity.isNotEmpty) ? cachedCity : 'istanbul';
        await _loadWeather(fallbackCity);
        if (mounted && _error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                lower.contains('izni') || lower.contains('permission')
                    ? (AppStrings.lang == 'en'
                        ? 'Location permission needed — showing $fallbackCity'
                        : 'Konum izni gerekli — $fallbackCity gösteriliyor')
                    : lower.contains('gps') || lower.contains('konum servisi')
                        ? (AppStrings.lang == 'en'
                            ? 'GPS is off — showing $fallbackCity'
                            : 'GPS kapalı — $fallbackCity gösteriliyor')
                        : (AppStrings.lang == 'en'
                            ? 'Location unavailable — showing $fallbackCity'
                            : 'Konum alınamadı — $fallbackCity gösteriliyor'),
              ),
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: AppStrings.lang == 'en' ? 'Retry' : 'Tekrar Dene',
                onPressed: _loadWeatherByGPS,
              ),
            ),
          );
        }
        return;
      }

      if (silent && _weather != null) {
        if (mounted) setState(() => _isRefreshing = false);
        _showRefreshErrorSnackBar();
        return;
      }

      if (!mounted) return;
      setState(() {
        _error = _mapWeatherError(e);
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWeather(String city, {bool silent = false}) async {
    _beginLoad(silent: silent);

    try {
      final style = context.read<AppProvider>().stylePreference;
      final weather = await WeatherService.getWeatherByCity(city);
      if (!mounted) return;
      await LocationPreferenceService.saveLastCity(weather.city);
      final outfit = OutfitEngine.getRecommendation(weather, style: style);
      setState(() => _useGps = false);
      await _applyWeatherSuccess(weather, outfit, style);
    } catch (e) {
      if (silent && _weather != null) {
        if (mounted) setState(() => _isRefreshing = false);
        _showRefreshErrorSnackBar();
        return;
      }
      if (!mounted) return;
      setState(() {
        _error = _mapWeatherError(e);
        _loading = false;
        _isRefreshing = false;
      });
    }
  }

  String _mapWeatherError(Object error) {
    if (error is TimeoutException) {
      return AppStrings.lang == 'en'
          ? 'Request timed out. Check your internet and try again.'
          : 'İstek zaman aşımına uğradı. İnternetini kontrol edip tekrar dene.';
    }
    if (error is SocketException) {
      return AppStrings.lang == 'en'
          ? 'No internet connection. Please connect and try again.'
          : 'İnternet bağlantısı yok. Bağlanıp tekrar dene.';
    }

    final raw = error.toString().replaceFirst('Exception: ', '');
    final lower = raw.toLowerCase();
    if (lower.contains('şehir bulunamadı') ||
        lower.contains('city not found')) {
      return AppStrings.lang == 'en'
          ? 'City not found. Please check spelling and try again.'
          : 'Şehir bulunamadı. Yazımı kontrol edip tekrar dene.';
    }
    if (lower.contains('konum')) {
      return raw;
    }
    return raw.isEmpty
        ? (AppStrings.lang == 'en'
            ? 'An unexpected error occurred.'
            : 'Beklenmeyen bir hata oluştu.')
        : raw;
  }

  Future<void> _checkFavoriteOutfit(String title) async {
    final isFav = await FavoriteOutfitService.isFavorite(title);
    if (mounted) setState(() => _isFavoriteOutfit = isFav);
  }

  Future<void> _toggleFavoriteOutfit() async {
    if (_outfit == null) return;
    final o = _outfit!;
    if (_isFavoriteOutfit) {
      await FavoriteOutfitService.removeFavorite(o.title);
    } else {
      await FavoriteOutfitService.addFavorite(FavoriteOutfit(
        title: o.title,
        subtitle: o.subtitle,
        weatherMood: o.weatherMood,
        items: o.items
            .map((i) => FavoriteOutfitItem(
                  emoji: i.emoji,
                  name: i.name,
                  category: i.category,
                  colorValue: i.color.value,
                ))
            .toList(),
        primaryColorValue: o.primaryColor.value,
        savedAt: DateTime.now(),
      ));
    }
    await _checkFavoriteOutfit(o.title);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isFavoriteOutfit
            ? (AppStrings.lang == 'en' ? 'Outfit saved!' : 'Kombin kaydedildi!')
            : (AppStrings.lang == 'en'
                ? 'Removed from favorites'
                : 'Favorilerden çıkarıldı')),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  Future<void> _saveToHistory(
      WeatherData weather, OutfitRecommendation outfit) async {
    await HistoryService.addEntry(HistoryEntry(
      city: weather.city,
      temperature: weather.temperature,
      condition: weather.condition,
      outfitTitle: outfit.title,
      date: DateTime.now(),
    ));
    // Achievement tracking
    AchievementService.checkAndUnlock('first_outfit', 1).then((newlyUnlocked) {
      _showAchievementToast(newlyUnlocked);
    });
    AchievementService.trackCity(weather.city);
    AchievementService.trackWeather(weather.condition);
    AchievementService.trackNightOwl();
    // Smart outfit suggestion
    SmartOutfitService.getBestOutfit(weather.temperature, weather.condition)
        .then((suggestion) {
      if (mounted && suggestion != null) {
        setState(() => _smartSuggestion = suggestion);
      }
    });
    // Gallery auto-save
    GalleryService.addEntry(
      outfitTitle: outfit.title,
      city: weather.city,
      temperature: weather.temperature,
      condition: weather.condition,
      itemNames: outfit.items.map((i) => '${i.emoji} ${i.name}').toList(),
      primaryColor: outfit.primaryColor.value,
    );
  }

  Future<void> _triggerSmartNotifications(
    WeatherData weather,
    OutfitRecommendation outfit,
  ) async {
    final provider = context.read<AppProvider>();
    if (!provider.notificationsEnabled) return;

    final now = DateTime.now();
    if (now.hour >= 6 && now.hour <= 9) {
      if (await NotificationThrottleService.shouldSendMorningNotification()) {
        await NotificationService.showMorningOutfitNotification(
          city: weather.city,
          temperature: weather.temperature,
          feelsLike: weather.feelsLike,
          condition: weather.condition,
          precipitationChance: weather.precipitationChance,
          outfitTitle: outfit.title,
          outfitItems:
              outfit.items.take(4).map((i) => '${i.emoji} ${i.name}').toList(),
        );
        await NotificationThrottleService.markMorningNotificationSent();
      }
    }

    if (weather.precipitationChance > 50 || weather.isRainy) {
      if (await NotificationThrottleService.shouldSendUmbrellaAlert(
          weather.city)) {
        await NotificationService.showUmbrellaAlert(
          city: weather.city,
          precipitationChance: weather.precipitationChance,
        );
        await NotificationThrottleService.markUmbrellaAlertSent(weather.city);
      }
    }
  }

  void _showAchievementToast(List<String> newlyUnlocked) {
    if (!mounted || newlyUnlocked.isEmpty) return;
    for (final id in newlyUnlocked) {
      final a = kAchievements.where((a) => a.id == id).firstOrNull;
      if (a == null) continue;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            '${a.emoji} ${AppStrings.lang == 'en' ? a.titleEN : a.titleTR} — ${AppStrings.lang == 'en' ? 'Unlocked!' : 'Açıldı!'}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 3),
      ));
    }
  }

  void _shareOutfit() {
    if (_weather == null || _outfit == null) return;
    _showShareOptions();
  }

  void _showShareOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2B35) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                )),
            const SizedBox(height: 20),
            Text(
              AppStrings.lang == 'en' ? 'Share Outfit' : 'Kombini Paylaş',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A2B35),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _shareOption(Icons.text_fields_rounded,
                    AppStrings.lang == 'en' ? 'Text' : 'Metin', () {
                  Navigator.pop(ctx);
                  _shareAsText();
                }, isDark),
                _shareOption(Icons.image_rounded,
                    AppStrings.lang == 'en' ? 'Image' : 'Görsel', () {
                  Navigator.pop(ctx);
                  _shareAsImage();
                }, isDark),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _shareOption(
      IconData icon, String label, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.grey[700],
              )),
        ],
      ),
    );
  }

  void _shareAsText() {
    final w = _weather!;
    final o = _outfit!;
    final items = o.items.map((i) => '${i.emoji} ${i.name}').join('\n');
    final text = '${w.city} - ${w.temperature.round()}°C ${w.description}\n\n'
        '${o.title}\n$items\n\n💡 ${o.tip}\n\n'
        '— Hava & Kombin uygulamasından';
    Share.share(text);
    AchievementService.checkAndUnlock('share_1', 1).then(_showAchievementToast);
  }

  Future<void> _shareAsImage() async {
    try {
      final image = await _screenshotController.captureFromLongWidget(
        _buildShareCard(),
        delay: const Duration(milliseconds: 200),
        pixelRatio: 3.0,
      );
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/outfit_share.png');
      await file.writeAsBytes(image);
      await Share.shareXFiles([XFile(file.path)],
          text: AppStrings.lang == 'en'
              ? 'My outfit from Weather & Outfit'
              : 'Hava & Kombin\'den kombinim');
    } catch (_) {
      _shareAsText();
    }
  }

  Widget _buildShareCard() {
    final w = _weather!;
    final o = _outfit!;
    return Container(
      width: 380,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [o.primaryColor, o.secondaryColor],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${w.city} ${w.temperature.round()}°C',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(w.description,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(o.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: o.items
                      .map((i) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('${i.emoji} ${i.name}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text('💡 ${o.tip}',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 12),
          const Text('— Hava & Kombin',
              style: TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }

  void _showSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchSheet(
        controller: _searchController,
        onSearch: (city) {
          Navigator.pop(context);
          _loadWeather(city);
        },
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const SettingsSheet(),
    );
  }

  void _openWeeklyPlanner() {
    if (_weather != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WeeklyPlannerScreen(forecast: _weather!.forecast),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final weather = _weather;
    final outfit = _outfit;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: WeatherBackground(
        condition: weather?.condition ?? 'clear',
        child: _loading
            ? _buildLoading()
            : _error != null
                ? _buildError()
                : weather != null && outfit != null
                    ? _buildContent(weather, outfit)
                    : const SizedBox.shrink(),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_weather != null && _outfit != null)
            FloatingActionButton.small(
              heroTag: 'share',
              onPressed: _shareOutfit,
              tooltip:
                  AppStrings.lang == 'en' ? 'Share outfit' : 'Kombini paylaş',
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.share_rounded, size: 20),
            ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'search',
            onPressed: _showSearch,
            tooltip: AppStrings.lang == 'en' ? 'Search city' : 'Şehir ara',
            backgroundColor: Colors.white,
            foregroundColor: Theme.of(context).colorScheme.primary,
            elevation: 4,
            child: const Icon(Icons.search_rounded),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 12,
      title: Text(
        AppStrings.get('app_title'),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.my_location_rounded,
              color: Colors.white, size: 22),
          onPressed: _loadWeatherByGPS,
          tooltip: AppStrings.get('gps_location'),
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded,
              color: Colors.white, size: 22),
          onPressed: _isRefreshing ? null : _refreshCurrent,
          tooltip: AppStrings.get('refresh'),
        ),
        if (_weather != null)
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded,
                color: Colors.white, size: 22),
            onPressed: _openWeeklyPlanner,
            tooltip: AppStrings.get('weekly_planner'),
          ),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded,
              color: Colors.white, size: 22),
          onPressed: _showQuickActionsSheet,
          tooltip: AppStrings.lang == 'en' ? 'More actions' : 'Diğer işlemler',
        ),
      ],
    );
  }

  void _showQuickActionsSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = _menuCategories();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        height: MediaQuery.of(sheetContext).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2B35) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              AppStrings.lang == 'en' ? 'Quick Actions' : 'Hızlı İşlemler',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A2B35),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildMenuSection(
                    AppStrings.lang == 'en' ? 'Quick' : 'Hızlı',
                    [
                      _MenuAction('gps', Icons.my_location_rounded,
                          AppStrings.get('gps_location')),
                      _MenuAction('ai_assistant', Icons.psychology_rounded,
                          AppStrings.get('ai_assistant')),
                      _MenuAction('history', Icons.history_rounded,
                          AppStrings.get('history')),
                      _MenuAction('settings', Icons.settings_rounded,
                          AppStrings.get('settings')),
                      _MenuAction('feedback', Icons.feedback_rounded,
                          AppStrings.get('feedback')),
                      _MenuAction('recommend_app', Icons.share_rounded,
                          AppStrings.get('recommend_app')),
                      _MenuAction('rate_app', Icons.star_rate_rounded,
                          AppStrings.get('rate_app')),
                    ],
                    isDark,
                    sheetContext,
                  ),
                  for (final category in categories)
                    _buildMenuSection(
                        category.title, category.actions, isDark, sheetContext),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(
    String title,
    List<_MenuAction> actions,
    bool isDark,
    BuildContext sheetContext,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isDark ? Colors.white.withOpacity(0.04) : const Color(0xFFF4F8FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white10
              : Theme.of(context).colorScheme.primary.withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          ...actions.map(
              (action) => _buildMenuActionTile(action, isDark, sheetContext)),
        ],
      ),
    );
  }

  Widget _buildMenuActionTile(
      _MenuAction action, bool isDark, BuildContext sheetContext) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(action.icon, size: 20, color: Theme.of(context).colorScheme.primary),
      title: Text(
        action.label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : const Color(0xFF1A2B35),
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded,
          color: isDark ? Colors.white38 : Colors.black26),
      onTap: () {
        Navigator.pop(sheetContext);
        _handleMenuAction(action.value);
      },
    );
  }

  List<_MenuCategory> _menuCategories() {
    final isEN = AppStrings.lang == 'en';
    return [
      _MenuCategory(
        isEN ? 'Weather' : 'Hava',
        [
          _MenuAction('multi_city', Icons.location_city_rounded,
              AppStrings.get('multi_city')),
          _MenuAction('weather_alert', Icons.notifications_active_rounded,
              AppStrings.get('weather_alert')),
          _MenuAction('weather_note', Icons.note_add_rounded,
              AppStrings.get('weather_note')),
          _MenuAction('weather_compare', Icons.compare_arrows_rounded,
              AppStrings.get('weather_compare')),
          _MenuAction('weekly_summary', Icons.bar_chart_rounded,
              AppStrings.get('weekly_summary')),
        ],
      ),
      _MenuCategory(
        isEN ? 'Wardrobe' : 'Dolap',
        [
          _MenuAction(
              'wardrobe', Icons.checkroom_rounded, AppStrings.get('wardrobe')),
          _MenuAction('wardrobe_stats', Icons.bar_chart_rounded,
              AppStrings.get('wardrobe_stats')),
          _MenuAction('outfit_scorer', Icons.auto_awesome_rounded,
              AppStrings.get('outfit_scorer')),
          _MenuAction('capsule_wardrobe', Icons.checkroom_rounded,
              AppStrings.get('capsule_wardrobe')),
          _MenuAction('clothing_tags', Icons.label_rounded,
              AppStrings.get('clothing_tags')),
          _MenuAction('care_reminder', Icons.notifications_active_rounded,
              AppStrings.get('care_reminders')),
          _MenuAction('laundry', Icons.local_laundry_service_rounded,
              AppStrings.get('laundry')),
        ],
      ),
      _MenuCategory(
        isEN ? 'Outfit' : 'Kombin',
        [
          _MenuAction('outfit_search', Icons.search_rounded,
              AppStrings.get('outfit_search')),
          _MenuAction('combo_generator', Icons.auto_awesome_rounded,
              AppStrings.get('combo_generator')),
          _MenuAction('outfit_remix', Icons.refresh_rounded,
              AppStrings.get('outfit_remix')),
          _MenuAction('event_outfit', Icons.event_rounded,
              AppStrings.get('event_outfit')),
          _MenuAction(
              'mood_outfit', Icons.mood_rounded, AppStrings.get('mood_outfit')),
          _MenuAction('location_outfit', Icons.place_rounded,
              AppStrings.get('location_outfit')),
          _MenuAction('friend_outfit', Icons.group_rounded,
              AppStrings.get('friend_outfit')),
        ],
      ),
      _MenuCategory(
        isEN ? 'Insights' : 'Analiz',
        [
          _MenuAction('trend_analysis', Icons.trending_up_rounded,
              AppStrings.get('trend_analysis')),
          _MenuAction('style_score', Icons.emoji_events_rounded,
              AppStrings.get('style_score')),
          _MenuAction('color_analysis', Icons.color_lens_rounded,
              AppStrings.get('color_analysis')),
          _MenuAction('color_trends', Icons.palette_rounded,
              AppStrings.get('color_trends')),
          _MenuAction('dashboard', Icons.dashboard_rounded,
              AppStrings.get('dashboard')),
          _MenuAction('weekly_report', Icons.summarize_rounded,
              AppStrings.get('weekly_report')),
        ],
      ),
      _MenuCategory(
        isEN ? 'Tools' : 'Araçlar',
        [
          _MenuAction('travel', Icons.flight_takeoff_rounded,
              AppStrings.get('travel_mode')),
          _MenuAction(
              'packing', Icons.luggage_rounded, AppStrings.get('packing')),
          _MenuAction('budget', Icons.account_balance_wallet_rounded,
              AppStrings.get('budget')),
          _MenuAction('shopping_list', Icons.shopping_cart_rounded,
              AppStrings.get('shopping_list')),
          _MenuAction(
              'countdown', Icons.timer_rounded, AppStrings.get('countdown')),
          _MenuAction('backup', Icons.backup_rounded, AppStrings.get('backup')),
        ],
      ),
      _MenuCategory(
        isEN ? 'Social' : 'Sosyal',
        [
          _MenuAction('gallery', Icons.photo_library_rounded,
              AppStrings.get('gallery')),
          _MenuAction('fashion_tips', Icons.lightbulb_rounded,
              AppStrings.get('fashion_tips')),
          _MenuAction('style_challenge', Icons.emoji_objects_rounded,
              AppStrings.get('style_challenge')),
        ],
      ),
      _MenuCategory(
        isEN ? 'Personal' : 'Kişisel',
        [
          _MenuAction('streak', Icons.local_fire_department_rounded,
              AppStrings.get('streak')),
          _MenuAction('achievements', Icons.emoji_events_rounded,
              AppStrings.get('achievements')),
          _MenuAction(
              'calendar', Icons.event_rounded, AppStrings.get('calendar')),
          _MenuAction('monthly_plan', Icons.calendar_month_rounded,
              AppStrings.get('monthly_plan')),
          _MenuAction(
              'comfort', Icons.thermostat_rounded, AppStrings.get('comfort')),
          _MenuAction('seasonal_guide', Icons.park_rounded,
              AppStrings.get('seasonal_guide')),
        ],
      ),
    ];
  }

  Future<void> _handleMenuAction(String value) async {
    switch (value) {
      case 'gps':
        _loadWeatherByGPS();
        return;
      case 'history':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
        return;
      case 'wardrobe':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const WardrobeScreen()));
        return;
      case 'travel':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const TravelScreen()));
        return;
      case 'calendar':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const CalendarScreen()));
        return;
      case 'gallery':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const GalleryScreen()));
        return;
      case 'achievements':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AchievementsScreen()));
        return;
      case 'wardrobe_stats':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const WardrobeStatsScreen()));
        return;
      case 'style_challenge':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const StyleChallengeScreen()));
        return;
      case 'seasonal_guide':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SeasonalGuideScreen()));
        return;
      case 'budget':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const BudgetScreen()));
        return;
      case 'care_reminder':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CareReminderScreen()));
        return;
      case 'weekly_report':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const WeeklyReportScreen()));
        return;
      case 'fashion_tips':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const FashionTipsScreen()));
        return;
      case 'outfit_search':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const OutfitSearchScreen()));
        return;
      case 'weather_compare':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const WeatherCompareScreen()));
        return;
      case 'trend_analysis':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const TrendAnalysisScreen()));
        return;
      case 'backup':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const BackupScreen()));
        return;
      case 'event_outfit':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const EventOutfitScreen()));
        return;
      case 'mood_outfit':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MoodOutfitScreen()));
        return;
      case 'combo_generator':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ComboGeneratorScreen()));
        return;
      case 'laundry':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const LaundryScreen()));
        return;
      case 'shopping_list':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ShoppingListScreen()));
        return;
      case 'dashboard':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()));
        return;
      case 'outfit_remix':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const OutfitRemixScreen()));
        return;
      case 'countdown':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CountdownScreen()));
        return;
      case 'clothing_tags':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const TagFilterScreen()));
        return;
      case 'color_trends':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ColorTrendsScreen()));
        return;
      case 'ai_assistant':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AiAssistantScreen()));
        return;
      case 'location_outfit':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const LocationOutfitScreen()));
        return;
      case 'friend_outfit':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const FriendOutfitScreen()));
        return;
      case 'monthly_plan':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MonthlyPlanScreen()));
        return;
      case 'style_score':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const StyleScoreScreen()));
        return;
      case 'comfort':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ComfortScreen()));
        return;
      case 'capsule_wardrobe':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CapsuleWardrobeScreen()));
        return;
      case 'outfit_scorer':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ClothingPhotoScreen()));
        return;
      case 'color_analysis':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ColorAnalysisScreen()));
        return;
      case 'multi_city':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MultiCityScreen()));
        return;
      case 'weather_alert':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => WeatherAlertScreen(weather: _weather)));
        return;
      case 'weather_note':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WeatherNoteScreen(
              city: _weather?.city,
              temperature: _weather?.temperature,
              condition: _weather?.condition,
            ),
          ),
        );
        return;
      case 'weekly_summary':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const WeeklySummaryScreen()));
        return;
      case 'packing':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const PackingScreen()));
        return;
      case 'streak':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const StreakScreen()));
        return;
      case 'rate_app':
        await FeedbackService.markRated();
        await FeedbackService.openPlayStore();
        return;
      case 'recommend_app':
        Share.share(
          AppStrings.lang == 'en'
              ? 'Check out this great weather & outfit app! https://play.google.com/store/apps/details?id=com.weather_outfit'
              : 'Harika bir hava durumu & kombin uygulaması! https://play.google.com/store/apps/details?id=com.weather_outfit',
        );
        return;
      case 'feedback':
        FeedbackService.showFeedbackDialog(context);
        return;
      case 'settings':
        _showSettings();
        return;
    }
  }

  Widget _buildLoading() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1A3A4A), Theme.of(context).colorScheme.primary, const Color(0xFF3A8FA8)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.get('loading'),
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.get('wardrobe_prep'),
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3A1A1A), Color(0xFF6E2C2C)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('😕', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              Text(
                _error ?? AppStrings.get('error_occurred'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _showSearch,
                icon: const Icon(Icons.search),
                label: Text(AppStrings.get('search_btn')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6E2C2C),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _loadWeatherByGPS,
                icon: const Icon(Icons.my_location_rounded),
                label: Text(AppStrings.get('gps_location')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final style = context.read<AppProvider>().stylePreference;
    if (_cachedOutfitStyle.isNotEmpty && _cachedOutfitStyle != style) {
      setState(() {
        _cachedOutfitStyle = style;
        _forecastOutfitCache.clear();
        if (_outfit != null) _forecastOutfitCache[0] = _outfit!;
        _outfitRating = null;
      });
    }
  }

  Widget _buildContent(WeatherData weather, OutfitRecommendation outfit) {
    final style = context.watch<AppProvider>().stylePreference;
    final displayOutfit = _getForecastOutfit(weather, outfit, style);
    final selectedDay = weather.forecast.isNotEmpty &&
            _selectedForecastIndex < weather.forecast.length
        ? weather.forecast[_selectedForecastIndex]
        : null;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: RefreshIndicator(
          onRefresh: _refreshCurrent,
          color: Theme.of(context).colorScheme.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
            SliverToBoxAdapter(
                child: WeatherHeader(weather: weather, outfit: outfit)),
            if (_isRefreshing)
              const SliverToBoxAdapter(
                child: LinearProgressIndicator(minHeight: 2),
              ),
            if (_lastUpdated != null && !_isOfflineData)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Text(
                    _formatLastUpdated(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            if (_isOfflineData)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: _buildOfflineBanner(),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    WeatherStatsRow(weather: weather),
                    const SizedBox(height: 16),
                    // UV & AQI row
                    if (weather.uvIndex > 0 || weather.aqi > 0)
                      Builder(builder: (context) {
                        final isNight = DateTime.now().isAfter(weather.sunset) || DateTime.now().isBefore(weather.sunrise);
                        final showUv = weather.uvIndex > 0 && !isNight;
                        final showAqi = weather.aqi > 0;
                        if (!showUv && !showAqi) return const SizedBox.shrink();
                        return Row(
                          children: [
                            if (showUv)
                              Expanded(
                                  child: UvIndexCard(uvIndex: weather.uvIndex)),
                            if (showUv && showAqi)
                              const SizedBox(width: 12),
                            if (showAqi)
                              Expanded(
                                  child: AqiCard(
                                      aqi: weather.aqi, label: weather.aqiLabel)),
                          ],
                        );
                      }),
                    if (weather.uvIndex > 0 || weather.aqi > 0)
                      const SizedBox(height: 16),
                    // Hourly forecast chart
                    if (weather.hourlyForecast.isNotEmpty) ...[
                      RepaintBoundary(
                        child: HourlyChart(hourlyData: weather.hourlyForecast),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (weather.forecast.length >= 2) ...[
                      RepaintBoundary(
                        child: TemperatureChart(forecast: weather.forecast),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Color palette
                    ColorPaletteWidget(
                      condition: weather.condition,
                      temperature: weather.temperature,
                    ),
                    const SizedBox(height: 20),
                    ForecastStrip(
                      forecast: weather.forecast,
                      selectedIndex: _selectedForecastIndex,
                      onDaySelected: (index) {
                        setState(() {
                          _selectedForecastIndex = index;
                          _outfitRating = null;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    if (_selectedForecastIndex > 0 && selectedDay != null)
                      _buildSelectedDayBanner(selectedDay),
                    if (displayOutfit.alerts.isNotEmpty) ...[
                      AlertBanner(alerts: displayOutfit.alerts),
                      const SizedBox(height: 20),
                    ],
                    _buildOutfitSection(displayOutfit),
                    const SizedBox(height: 16),
                    // Outfit rating
                    OutfitRating(
                      currentRating: _outfitRating,
                      onRate: (rating) {
                        setState(() => _outfitRating = rating);
                        SmartOutfitService.recordRating(
                          displayOutfit.title,
                          rating,
                          temperature: weather.temperature,
                          condition: weather.condition,
                        );
                        SmartOutfitService.getAllRatings().then((all) {
                          final totalRated = all.length;
                          AchievementService.checkAndUnlock(
                                  'rate_5', totalRated)
                              .then(_showAchievementToast);
                          AchievementService.checkAndUnlock(
                                  'rate_20', totalRated)
                              .then(_showAchievementToast);
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    // Color harmony indicator
                    _buildColorHarmony(displayOutfit),
                    // Smart outfit suggestion
                    if (_smartSuggestion != null &&
                        _smartSuggestion != displayOutfit.title) ...[
                      const SizedBox(height: 12),
                      _buildSmartSuggestion(),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  OutfitRecommendation _getForecastOutfit(
    WeatherData weather,
    OutfitRecommendation todayOutfit,
    String style,
  ) {
    if (_selectedForecastIndex == 0) {
      return todayOutfit;
    }
    if (_selectedForecastIndex < 0 ||
        _selectedForecastIndex >= weather.forecast.length) {
      return todayOutfit;
    }
    if (_forecastOutfitCache.containsKey(_selectedForecastIndex)) {
      return _forecastOutfitCache[_selectedForecastIndex]!;
    }

    final forecastOutfit = OutfitEngine.getRecommendationForForecast(
      weather.forecast[_selectedForecastIndex],
      style: style,
    );
    _forecastOutfitCache[_selectedForecastIndex] = forecastOutfit;
    return forecastOutfit;
  }

  Widget _buildOfflineBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F5FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded,
              size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppStrings.lang == 'en'
                  ? 'Showing cached weather data (offline mode).'
                  : 'Önbellekteki hava durumu gösteriliyor (çevrimdışı mod).',
              style: const TextStyle(
                color: Color(0xFF1F4F66),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayBanner(ForecastDay day) {
    final dayName = AppStrings.fullDayName(day.date.weekday);
    final dateStr =
        '${day.date.day}.${day.date.month.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded,
              color: Colors.white70, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$dayName — $dateStr',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${day.tempMin.round()}° / ${day.tempMax.round()}°',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _selectedForecastIndex = 0),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.15),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(AppStrings.get('today')),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitSection(OutfitRecommendation outfit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = ContrastUtils.sectionTitle(isDark: isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                color: outfit.primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                outfit.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(
            outfit.subtitle,
            style: TextStyle(
              fontSize: 14,
              color: ContrastUtils.subtitleText(isDark: isDark),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: OutfitCard(
            key: ValueKey(outfit.title),
            outfit: outfit,
            onShare: _shareOutfit,
            onFavorite: _toggleFavoriteOutfit,
            isFavorite: _isFavoriteOutfit,
          ),
        ),
        const SizedBox(height: 16),
        _buildTipCard(outfit),
      ],
    );
  }

  Widget _buildColorHarmony(OutfitRecommendation outfit) {
    final colors = outfit.items.map((i) => i.color).toList();
    final harmonyScore = ColorHarmony.outfitScore(colors);
    final label =
        ColorHarmony.label(harmonyScore, isEN: AppStrings.lang == 'en');
    final indicator = ColorHarmony.indicator(harmonyScore);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: indicator.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: indicator.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Text('🎨', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: indicator,
                )),
          ),
          Container(
            width: 60,
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: indicator.withOpacity(0.2),
            ),
            child: FractionallySizedBox(
              widthFactor: harmonyScore,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: indicator,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartSuggestion() {
    final isEN = AppStrings.lang == 'en';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.08),
            Theme.of(context).colorScheme.primary.withOpacity(0.04)
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Text('🧠', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEN ? 'Smart Suggestion' : 'Akıllı Öneri',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary),
                ),
                Text(
                  '${isEN ? 'Based on your ratings:' : 'Puanlarına göre:'} $_smartSuggestion',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: ContrastUtils.bodyText(isDark: isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(OutfitRecommendation outfit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = ContrastUtils.accentText(outfit.primaryColor, isDark: isDark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            outfit.primaryColor.withValues(alpha: isDark ? 0.22 : 0.12),
            outfit.primaryColor.withValues(alpha: isDark ? 0.1 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: outfit.primaryColor.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡',
            style: TextStyle(fontSize: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.get('style_tip'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: accent,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  outfit.tip,
                  style: TextStyle(
                    fontSize: 14,
                    color: ContrastUtils.bodyText(isDark: isDark),
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCategory {
  final String title;
  final List<_MenuAction> actions;

  const _MenuCategory(this.title, this.actions);
}

class _MenuAction {
  final String value;
  final IconData icon;
  final String label;

  const _MenuAction(this.value, this.icon, this.label);
}

class _SearchSheet extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String) onSearch;

  const _SearchSheet({required this.controller, required this.onSearch});

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  final List<String> _suggestions = [
    'İstanbul',
    'Ankara',
    'İzmir',
    'Antalya',
    'Bursa',
    'Adana',
    'Gaziantep',
    'Konya',
    'Mersin',
    'Trabzon',
    'Eskişehir',
    'Kayseri',
    'Samsun',
    'Diyarbakır',
    'Osmaniye',
  ];
  List<String> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favs = await FavoritesService.getFavorites();
    setState(() => _favorites = favs);
  }

  Future<void> _toggleFavorite(String city) async {
    if (_favorites.contains(city)) {
      await FavoritesService.removeFavorite(city);
    } else {
      await FavoritesService.addFavorite(city);
    }
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2B35) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: widget.controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: AppStrings.get('search_city'),
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : null,
                ),
                prefixIcon:
                    Icon(Icons.search_rounded, color: Theme.of(context).colorScheme.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : const Color(0xFFE0E0E0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : const Color(0xFFE0E0E0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                ),
                suffixIcon: IconButton(
                  icon:
                      Icon(Icons.send_rounded, color: Theme.of(context).colorScheme.primary),
                  onPressed: () {
                    final city = widget.controller.text.trim();
                    if (city.isNotEmpty) widget.onSearch(city);
                  },
                ),
              ),
              onSubmitted: (city) {
                if (city.trim().isNotEmpty) widget.onSearch(city.trim());
              },
            ),
          ),
          const SizedBox(height: 20),
          // Favorites section
          if (_favorites.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Colors.amber, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      AppStrings.get('favorites'),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _favorites.length,
                itemBuilder: (ctx, i) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      avatar: const Icon(Icons.star_rounded,
                          color: Colors.amber, size: 16),
                      label: Text(_favorites[i]),
                      onPressed: () => widget.onSearch(_favorites[i]),
                      backgroundColor: isDark
                          ? const Color(0xFF1E3345)
                          : const Color(0xFFF5F9FC),
                      labelStyle: TextStyle(
                        color:
                            isDark ? Colors.white70 : Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      side: BorderSide(
                        color: isDark
                            ? Colors.white10
                            : Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppStrings.get('popular_cities'),
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white54 : Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _suggestions.length,
              itemBuilder: (ctx, i) {
                final city = _suggestions[i];
                final isFav = _favorites.contains(city);
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  leading: Icon(Icons.location_on_rounded,
                      color: Theme.of(context).colorScheme.primary, size: 20),
                  title: Text(
                    city,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          isFav
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: isFav
                              ? Colors.amber
                              : (isDark ? Colors.white38 : Colors.grey),
                          size: 22,
                        ),
                        onPressed: () => _toggleFavorite(city),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: isDark ? Colors.white38 : Colors.grey,
                      ),
                    ],
                  ),
                  onTap: () => widget.onSearch(city),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
