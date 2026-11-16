import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class ColorPaletteWidget extends StatelessWidget {
  final String condition;
  final double temperature;

  const ColorPaletteWidget({
    super.key,
    required this.condition,
    required this.temperature,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = _getPalette();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3345) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎨 ${AppStrings.get('color_palette')}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A2B35),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: palette
                .map((p) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          children: [
                            Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: p.color,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: p.color.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              p.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? Colors.white54 : Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  List<_PaletteColor> _getPalette() {
    if (condition == 'snow') {
      return [
        const _PaletteColor(Color(0xFF2C3E50), 'Koyu Lacivert'),
        const _PaletteColor(Color(0xFF5D8AA8), 'Çelik Mavi'),
        const _PaletteColor(Color(0xFFC4C4C4), 'Gri'),
        const _PaletteColor(Color(0xFFF5F5F5), 'Beyaz'),
        const _PaletteColor(Color(0xFF8B0000), 'Bordo'),
      ];
    }
    if (condition == 'rain' || condition == 'drizzle') {
      return [
        const _PaletteColor(Color(0xFF1B4332), 'Orman Yeşili'),
        const _PaletteColor(Color(0xFF2C6E8A), 'Okyanus'),
        const _PaletteColor(Color(0xFF6B705C), 'Haki'),
        const _PaletteColor(Color(0xFFDDBEA9), 'Bej'),
        const _PaletteColor(Color(0xFF3D405B), 'Lacivert'),
      ];
    }
    if (condition == 'thunderstorm') {
      return [
        const _PaletteColor(Color(0xFF1A1A2E), 'Gece'),
        const _PaletteColor(Color(0xFF16213E), 'Derin Mavi'),
        const _PaletteColor(Color(0xFF533483), 'Mor'),
        const _PaletteColor(Color(0xFFE94560), 'Kırmızı'),
        const _PaletteColor(Color(0xFF0F3460), 'Koyu Mavi'),
      ];
    }
    if (temperature >= 30) {
      return [
        const _PaletteColor(Color(0xFFF5F5DC), 'Krem'),
        const _PaletteColor(Color(0xFFE07A5F), 'Mercan'),
        const _PaletteColor(Color(0xFF81B29A), 'Mint'),
        const _PaletteColor(Color(0xFFF2CC8F), 'Bal'),
        const _PaletteColor(Color(0xFF3D405B), 'Antrasit'),
      ];
    }
    if (temperature >= 20) {
      return [
        const _PaletteColor(Color(0xFF2C6E8A), 'Okyanus'),
        const _PaletteColor(Color(0xFFE07A5F), 'Terrakotta'),
        const _PaletteColor(Color(0xFFF4F1DE), 'Bej'),
        const _PaletteColor(Color(0xFF81B29A), 'Adaçayı'),
        const _PaletteColor(Color(0xFF264653), 'Koyu Teal'),
      ];
    }
    if (temperature >= 10) {
      return [
        const _PaletteColor(Color(0xFF6D4C41), 'Kahve'),
        const _PaletteColor(Color(0xFFBCAAA4), 'Taş'),
        const _PaletteColor(Color(0xFF455A64), 'Füme'),
        const _PaletteColor(Color(0xFFFF8F00), 'Hardal'),
        const _PaletteColor(Color(0xFF5D4037), 'Çikolata'),
      ];
    }
    return [
      const _PaletteColor(Color(0xFF1A237E), 'İndigo'),
      const _PaletteColor(Color(0xFF4A148C), 'Mürdüm'),
      const _PaletteColor(Color(0xFF263238), 'Antrasit'),
      const _PaletteColor(Color(0xFFB71C1C), 'Koyu Kırmızı'),
      const _PaletteColor(Color(0xFF004D40), 'Koyu Yeşil'),
    ];
  }
}

class _PaletteColor {
  final Color color;
  final String name;
  const _PaletteColor(this.color, this.name);
}
