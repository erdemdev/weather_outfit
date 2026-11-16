import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class AqiCard extends StatelessWidget {
  final int aqi;
  final String label;

  const AqiCard({super.key, required this.aqi, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (displayLabel, color, emoji) = _aqiInfo();

    return GestureDetector(
      onTap: () => _showAqiInfo(context, displayLabel, color, emoji),
      child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3345) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.get('air_quality'),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 56, maxWidth: 72),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'AQI\n$aqi',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  void _showAqiInfo(BuildContext context, String label, Color color, String emoji) {
    final tips = _aqiTips();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2B35) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(emoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                '${AppStrings.get('air_quality')}: AQI $aqi',
                style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1A2B35),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14)),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF5F9FC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  AppStrings.lang == 'en'
                    ? 'AQI (Air Quality Index) measures the concentration of '
                      'pollutants (PM2.5, PM10, ozone, CO, SO2, NO2) in the air '
                      'on a scale of 0–500. The lower the value, the cleaner the air.'
                    : 'AQI (Hava Kalitesi İndeksi), havadaki kirletici maddelerin '
                      '(PM2.5, PM10, ozon, karbon monoksit, kükürt dioksit, azot dioksit) '
                      'yoğunluğunu 0-500 arasında tek bir sayıyla ölçer. '
                      'Değer ne kadar düşükse hava o kadar temizdir.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: isDark ? Colors.white60 : Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tip['icon']!, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tip['title']!, style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF1A2B35),
                          )),
                          const SizedBox(height: 2),
                          Text(tip['desc']!, style: TextStyle(
                            fontSize: 13, color: isDark ? Colors.white54 : Colors.grey[600],
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 12),
            ],
          ),
          ),
        );
      },
    );
  }

  List<Map<String, String>> _aqiTips() {
    final isEN = AppStrings.lang == 'en';
    if (aqi <= 50) {
      return [
        {'icon': '🌿', 'title': isEN ? 'Great Air' : 'Mükemmel Hava', 'desc': isEN ? 'Ideal for outdoor sports and activities.' : 'Dışarıda spor yapmak ve vakit geçirmek için ideal.'},
        {'icon': '🏃', 'title': isEN ? 'Activity' : 'Aktivite', 'desc': isEN ? 'All outdoor activities can be done safely.' : 'Tüm dış mekan aktiviteleri güvenle yapılabilir.'},
        {'icon': '🪟', 'title': isEN ? 'Ventilation' : 'Havalandırma', 'desc': isEN ? 'Open windows to ventilate your home.' : 'Pencereleri açarak evinizi havalandırabilirsiniz.'},
      ];
    } else if (aqi <= 100) {
      return [
        {'icon': '⚠️', 'title': isEN ? 'Acceptable' : 'Kabul Edilebilir', 'desc': isEN ? 'Generally safe but sensitive groups should be cautious.' : 'Genel olarak güvenli ama hassas kişiler dikkatli olmalı.'},
        {'icon': '🫁', 'title': isEN ? 'Sensitive Groups' : 'Hassas Gruplar', 'desc': isEN ? 'Asthma patients should avoid prolonged outdoor activity.' : 'Astım hastaları uzun süreli dış aktiviteden kaçınmalı.'},
        {'icon': '🏃', 'title': isEN ? 'Activity' : 'Aktivite', 'desc': isEN ? 'Short outdoor activities are fine.' : 'Kısa süreli dış mekan aktiviteleri uygun.'},
      ];
    } else if (aqi <= 150) {
      return [
        {'icon': '😷', 'title': isEN ? 'Risky for Sensitive Groups' : 'Hassas Gruplar İçin Riskli', 'desc': isEN ? 'Children, elderly, and chronic patients may be affected.' : 'Çocuklar, yaşlılar ve kronik hastalar etkilenebilir.'},
        {'icon': '🏠', 'title': isEN ? 'Stay Indoors' : 'İçeride Kalın', 'desc': isEN ? 'Reduce prolonged outdoor activities.' : 'Uzun süreli dış mekan aktivitesini azaltın.'},
        {'icon': '🪟', 'title': isEN ? 'Windows' : 'Pencereler', 'desc': isEN ? 'Better to keep windows closed.' : 'Pencereleri kapalı tutmak daha iyi.'},
        {'icon': '💊', 'title': isEN ? 'Medication' : 'İlaçlar', 'desc': isEN ? 'Keep your inhaler with you.' : 'Astım ilacını yanında bulundur.'},
      ];
    } else if (aqi <= 200) {
      return [
        {'icon': '🔴', 'title': isEN ? 'Unhealthy' : 'Sağlıksız', 'desc': isEN ? 'Everyone may start to experience health effects.' : 'Herkes sağlık etkileri yaşamaya başlayabilir.'},
        {'icon': '🏠', 'title': isEN ? 'Stay Inside' : 'İçeride Kal', 'desc': isEN ? 'Minimize outdoor activities.' : 'Dış mekan aktivitelerini minimuma indir.'},
        {'icon': '😷', 'title': isEN ? 'Mask' : 'Maske', 'desc': isEN ? 'Wear an N95 mask if you must go out.' : 'Dışarı çıkman gerekirse N95 maske tak.'},
        {'icon': '🚫', 'title': isEN ? 'Exercise' : 'Egzersiz', 'desc': isEN ? 'Do not exercise outdoors.' : 'Açık havada egzersiz yapma.'},
      ];
    } else if (aqi <= 300) {
      return [
        {'icon': '🚨', 'title': isEN ? 'Very Unhealthy' : 'Çok Sağlıksız', 'desc': isEN ? 'Serious health effects for everyone.' : 'Ciddi sağlık etkileri riski herkes için geçerli.'},
        {'icon': '🏠', 'title': isEN ? 'Stay Home' : 'Evde Kal', 'desc': isEN ? 'Avoid going outside unless necessary.' : 'Zorunlu olmadıkça dışarı çıkma.'},
        {'icon': '😷', 'title': isEN ? 'Mask Required' : 'Maske Şart', 'desc': isEN ? 'Do not go outside without an N95 mask.' : 'Dışarıda N95 maske olmadan durma.'},
        {'icon': '🧹', 'title': isEN ? 'Air Purifier' : 'Hava Temizleyici', 'desc': isEN ? 'Run an air purifier if available.' : 'Varsa hava temizleyici çalıştır.'},
      ];
    } else {
      return [
        {'icon': '☠️', 'title': isEN ? 'Hazardous' : 'Tehlikeli', 'desc': isEN ? 'Emergency health warning — everyone is affected.' : 'Acil sağlık uyarısı — herkes etkilenir.'},
        {'icon': '🏠', 'title': isEN ? 'Do Not Go Out' : 'Dışarı Çıkma', 'desc': isEN ? 'Stay indoors at all times.' : 'Kesinlikle dışarı çıkma, evde kal.'},
        {'icon': '🪟', 'title': isEN ? 'Keep Windows Closed' : 'Pencereler Kapalı', 'desc': isEN ? 'Close all windows and doors.' : 'Tüm pencere ve kapıları kapat.'},
        {'icon': '🚑', 'title': isEN ? 'Emergency' : 'Acil Durum', 'desc': isEN ? 'Call emergency services if you have breathing difficulties.' : 'Nefes darlığı olursa hemen 112\'yi ara.'},
      ];
    }
  }

  (String, Color, String) _aqiInfo() {
    final isEN = AppStrings.lang == 'en';
    if (aqi <= 50) return (isEN ? 'Good' : 'İyi', Colors.green, '😊');
    if (aqi <= 100) return (isEN ? 'Moderate' : 'Orta', Colors.amber, '😐');
    if (aqi <= 150) return (isEN ? 'Sensitive Groups' : 'Hassas Gruplar', Colors.orange, '😷');
    if (aqi <= 200) return (isEN ? 'Unhealthy' : 'Sağlıksız', Colors.red, '🤢');
    if (aqi <= 300) return (isEN ? 'Very Unhealthy' : 'Çok Sağlıksız', Colors.purple, '☠️');
    return (isEN ? 'Hazardous' : 'Tehlikeli', const Color(0xFF7E0023), '⚠️');
  }
}
