import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';

class FeedbackService {
  static const _keyInstallDate = 'feedback_install_date';
  static const _keyLaunchCount = 'feedback_launch_count';
  static const _keyRated = 'feedback_rated';
  static const _keyNextPromptDate = 'feedback_next_prompt_date';

  static const _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.weather_outfit';

  // Her uygulama açılışında çağır
  static Future<void> recordLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_keyInstallDate)) {
      await prefs.setString(
          _keyInstallDate, DateTime.now().toIso8601String());
    }
    final count = (prefs.getInt(_keyLaunchCount) ?? 0) + 1;
    await prefs.setInt(_keyLaunchCount, count);
  }

  // Prompt gösterilmeli mi?
  static Future<bool> shouldShowPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_keyRated) == true) return false;

    final nextPromptStr = prefs.getString(_keyNextPromptDate);
    if (nextPromptStr != null) {
      final next = DateTime.tryParse(nextPromptStr);
      if (next != null && DateTime.now().isBefore(next)) return false;
    }

    final installStr = prefs.getString(_keyInstallDate);
    if (installStr == null) return false;
    final install = DateTime.tryParse(installStr);
    if (install == null) return false;

    final daysSinceInstall = DateTime.now().difference(install).inDays;
    final launches = prefs.getInt(_keyLaunchCount) ?? 0;

    // 3 gün geçmiş VE en az 5 açılış
    return daysSinceInstall >= 3 && launches >= 5;
  }

  // Play Store'u aç
  static Future<void> openPlayStore() async {
    final uri = Uri.parse(_playStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // Kullanıcı değerlendirdi
  static Future<void> markRated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRated, true);
  }

  // Kullanıcı "sonra hatırlat" seçti — 7 gün sonra tekrar sor
  static Future<void> snooze() async {
    final prefs = await SharedPreferences.getInstance();
    final next = DateTime.now().add(const Duration(days: 7));
    await prefs.setString(_keyNextPromptDate, next.toIso8601String());
  }

  // Kullanıcı "hayır" dedi — bir daha sorma
  static Future<void> markDeclined() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRated, true); // tekrar gösterme
  }

  // Geri bildirim diyaloğunu göster
  static Future<void> showFeedbackDialog(BuildContext context) async {
    final isEN = AppStrings.lang == 'en';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
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
              ),
            ),
            const SizedBox(height: 24),
            const Text('⭐', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 16),
            Text(
              isEN ? 'Enjoying the app?' : 'Uygulamayı beğendin mi?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A2B35),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isEN
                  ? 'Your rating helps us improve and reach more people.'
                  : 'Değerlendirmen uygulamayı geliştirmemize ve daha fazla kişiye ulaşmamıza yardımcı oluyor.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await markRated();
                  await openPlayStore();
                },
                icon: const Icon(Icons.star_rounded, size: 20),
                label: Text(
                  isEN ? 'Rate on Play Store' : 'Play Store\'da Değerlendir',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C6E8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await snooze();
                    },
                    child: Text(
                      isEN ? 'Remind me later' : 'Sonra hatırlat',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await markDeclined();
                    },
                    child: Text(
                      isEN ? 'No thanks' : 'Hayır, teşekkürler',
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.grey[400],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
