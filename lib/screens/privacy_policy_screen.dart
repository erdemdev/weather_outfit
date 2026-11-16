import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppProvider>().isDark;
    final isEN = AppStrings.lang == 'en';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEN ? 'Privacy Policy' : 'Gizlilik Politikası'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Text(
          isEN ? _policyEN : _policyTR,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: isDark ? Colors.white70 : const Color(0xFF1A2B35),
          ),
        ),
      ),
    );
  }
}

const _policyTR = '''
Gizlilik Politikası
Son güncelleme: 6 Nisan 2026

Hava & Kombin ("Uygulama") kullanıcılarının gizliliğine önem verir. Bu politika, hangi verilerin toplandığını ve nasıl kullanıldığını açıklar.

1. Toplanan Veriler

• Konum Bilgisi: Hava durumu verilerini almak için cihazınızın GPS konumu kullanılır. Konum bilgisi yalnızca OpenWeatherMap API'sine anlık olarak gönderilir ve sunucularımızda saklanmaz.

• Kamera / Fotoğraflar: Gardırobunuza kıyafet fotoğrafı eklemek için kamera veya galeriye erişim istenir. Fotoğraflar yalnızca cihazınızda yerel olarak saklanır ve hiçbir sunucuya yüklenmez.

• Kullanıcı Tercihleri: Tema, dil, stil tercihi ve bildirim ayarları gibi veriler yalnızca cihazınızda (SharedPreferences) saklanır.

2. Veri Paylaşımı

• Konum koordinatlarınız (enlem/boylam) yalnızca hava durumu verisi almak amacıyla OpenWeatherMap API'sine iletilir.
• Bunun dışında hiçbir kişisel veri üçüncü taraflarla paylaşılmaz.
• Uygulama herhangi bir kullanıcı hesabı, bulut senkronizasyonu veya analitik hizmeti kullanmaz.

3. Veri Saklama

Tüm veriler (tercihler, kombin geçmişi, gardırop fotoğrafları) yalnızca cihazınızda yerel olarak saklanır. Uygulamayı sildiğinizde tüm veriler kalıcı olarak silinir.

4. Çocukların Gizliliği

Uygulama 13 yaşın altındaki çocuklardan bilerek kişisel bilgi toplamaz.

5. Değişiklikler

Bu politika zaman zaman güncellenebilir. Güncellemeler uygulama içinden erişilebilir olacaktır.

''';

const _policyEN = '''
Privacy Policy
Last updated: April 6, 2026

Hava & Kombin ("App") values the privacy of its users. This policy explains what data is collected and how it is used.

1. Data Collected

• Location: Your device's GPS location is used to retrieve weather data. Location is sent only to the OpenWeatherMap API in real time and is not stored on our servers.

• Camera / Photos: Camera or gallery access is requested to add clothing photos to your wardrobe. Photos are stored only locally on your device and are never uploaded to any server.

• User Preferences: Data such as theme, language, style preference, and notification settings are stored only on your device (SharedPreferences).

2. Data Sharing

• Your location coordinates (latitude/longitude) are transmitted only to the OpenWeatherMap API for weather data retrieval.
• No other personal data is shared with third parties.
• The app does not use any user accounts, cloud sync, or analytics services.

3. Data Retention

All data (preferences, outfit history, wardrobe photos) is stored only locally on your device. When you uninstall the app, all data is permanently deleted.

4. Children's Privacy

The app does not knowingly collect personal information from children under 13.

5. Changes

This policy may be updated from time to time. Updates will be accessible from within the app.

''';
