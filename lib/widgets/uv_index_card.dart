import 'package:flutter/material.dart';

class UvIndexCard extends StatelessWidget {
  final double uvIndex;

  const UvIndexCard({super.key, required this.uvIndex});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (label, color, icon) = _uvInfo();

    return GestureDetector(
      onTap: () => _showUvInfo(context, label, color),
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
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UV İndeksi',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${uvIndex.toStringAsFixed(1)} - $label',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          _buildGauge(color, isDark),
        ],
      ),
      ),
    );
  }

  void _showUvInfo(BuildContext context, String label, Color color) {
    final tips = _uvTips();
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
              Icon(Icons.wb_sunny_rounded, color: color, size: 48),
              const SizedBox(height: 12),
              Text(
                'UV İndeksi: ${uvIndex.toStringAsFixed(1)}',
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
                  'UV İndeksi, güneşin ultraviyole ışınlarının yeryüzündeki '
                  'şiddetini 0-11+ arasında ölçer. Değer arttıkça cilt ve göz '
                  'hasarı riski yükselir. SPF koruma, şapka ve güneş gözlüğü '
                  'gibi önlemler UV seviyesine göre belirlenir.',
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

  List<Map<String, String>> _uvTips() {
    if (uvIndex <= 2) {
      return [
        {'icon': '😎', 'title': 'Güvenli Seviye', 'desc': 'UV riski düşük, rahatça dışarı çıkabilirsin.'},
        {'icon': '🧴', 'title': 'Güneş Kremi', 'desc': 'Hassas ciltler yine de SPF 15+ kullanabilir.'},
        {'icon': '👕', 'title': 'Kıyafet', 'desc': 'Ekstra korumaya gerek yok.'},
      ];
    } else if (uvIndex <= 5) {
      return [
        {'icon': '⚠️', 'title': 'Orta Seviye', 'desc': 'Öğle saatlerinde gölgede kalmaya çalış.'},
        {'icon': '🧴', 'title': 'Güneş Kremi', 'desc': 'SPF 30+ güneş kremi kullan.'},
        {'icon': '🕶️', 'title': 'Aksesuar', 'desc': 'Güneş gözlüğü ve şapka önerilir.'},
        {'icon': '⏰', 'title': 'Zamanlama', 'desc': '10:00-16:00 arası dikkatli ol.'},
      ];
    } else if (uvIndex <= 7) {
      return [
        {'icon': '🔴', 'title': 'Yüksek Risk', 'desc': 'Korunmasız dışarıda kalma 15-20 dk\'da yanmaya yol açar.'},
        {'icon': '🧴', 'title': 'Güneş Kremi', 'desc': 'SPF 50+ güneş kremini her 2 saatte tazele.'},
        {'icon': '👒', 'title': 'Korunma', 'desc': 'Geniş kenarlı şapka, güneş gözlüğü şart.'},
        {'icon': '🏠', 'title': 'Gölge', 'desc': 'Öğlen saatlerinde dışarı çıkmaktan kaçın.'},
      ];
    } else if (uvIndex <= 10) {
      return [
        {'icon': '🚨', 'title': 'Çok Yüksek Risk', 'desc': '10 dakikada bile cilt yanabilir.'},
        {'icon': '🧴', 'title': 'Güneş Kremi', 'desc': 'SPF 50+ zorunlu, sık sık yeniden sür.'},
        {'icon': '👕', 'title': 'Uzun Kıyafet', 'desc': 'Uzun kollu açık renkli kıyafetler giy.'},
        {'icon': '🚫', 'title': 'Dışarı Çıkma', 'desc': '10:00-16:00 arası mümkünse dışarı çıkma.'},
      ];
    } else {
      return [
        {'icon': '☠️', 'title': 'Aşırı Tehlike', 'desc': 'Birkaç dakikada ciddi yanık oluşabilir.'},
        {'icon': '🏠', 'title': 'İçeride Kal', 'desc': 'Mümkünse dışarı çıkmaktan kaçın.'},
        {'icon': '🧴', 'title': 'Tam Koruma', 'desc': 'SPF 50+, şapka, gözlük, uzun kıyafet zorunlu.'},
        {'icon': '👶', 'title': 'Hassas Gruplar', 'desc': 'Çocuklar ve yaşlılar kesinlikle dışarı çıkmamalı.'},
      ];
    }
  }

  Widget _buildGauge(Color color, bool isDark) {
    final fraction = (uvIndex / 11).clamp(0.0, 1.0);
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: fraction,
            strokeWidth: 5,
            backgroundColor: isDark ? Colors.white12 : Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(color),
          ),
          Text(
            uvIndex.round().toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A2B35),
            ),
          ),
        ],
      ),
    );
  }

  (String, Color, IconData) _uvInfo() {
    if (uvIndex <= 2) return ('Düşük', Colors.green, Icons.wb_sunny_outlined);
    if (uvIndex <= 5) return ('Orta', Colors.amber, Icons.wb_sunny);
    if (uvIndex <= 7) return ('Yüksek', Colors.orange, Icons.wb_sunny);
    if (uvIndex <= 10) return ('Çok Yüksek', Colors.redAccent, Icons.warning_amber_rounded);
    return ('Aşırı', Colors.purple, Icons.dangerous_rounded);
  }
}
