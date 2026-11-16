import '../models/outfit_model.dart';
import '../models/weather_model.dart';
import 'package:flutter/material.dart';

class FriendOutfitService {
  static const styles = [
    {'id': 'couple', 'emoji': '❤️', 'tr': 'Çift Kombini', 'en': 'Couple Outfit'},
    {'id': 'bff', 'emoji': '👯', 'tr': 'BFF Kombini', 'en': 'BFF Outfit'},
    {'id': 'family', 'emoji': '👨‍👩‍👧', 'tr': 'Aile Kombini', 'en': 'Family Outfit'},
    {'id': 'squad', 'emoji': '🤝', 'tr': 'Ekip Kombini', 'en': 'Squad Outfit'},
  ];

  static (OutfitRecommendation, OutfitRecommendation) getMatchingOutfits(String styleId, WeatherData weather) {
    return switch (styleId) {
      'couple' => _couple(weather),
      'bff' => _bff(weather),
      'family' => _family(weather),
      'squad' => _squad(weather),
      _ => _couple(weather),
    };
  }

  static (OutfitRecommendation, OutfitRecommendation) _couple(WeatherData weather) {
    final person1 = OutfitRecommendation(
      title: '❤️ Kişi 1',
      subtitle: 'Uyumlu çift stili',
      tip: 'Aynı renk tonlarında uyumlu parçalar seçildi',
      items: [
        OutfitItem(emoji: '👔', name: weather.isCold ? 'Lacivert kazak' : 'Beyaz gömlek', category: 'üst', color: weather.isCold ? const Color(0xFF1A3A4A) : const Color(0xFFFFFFFF)),
        const OutfitItem(emoji: '👖', name: 'Klasik jean', category: 'alt', color: Color(0xFF36547E)),
        const OutfitItem(emoji: '👟', name: 'Beyaz sneaker', category: 'ayakkabı', color: Color(0xFFF5F5F5)),
      ],
      alerts: [],
      primaryColor: const Color(0xFF1A3A4A),
      secondaryColor: const Color(0xFFDEB887),
      weatherMood: 'romantic',
    );
    final person2 = OutfitRecommendation(
      title: '❤️ Kişi 2',
      subtitle: 'Uyumlu çift stili',
      tip: 'Tamamlayıcı renkler ile uyum sağlandı',
      items: [
        OutfitItem(emoji: '👗', name: weather.isCold ? 'Bej triko elbise' : 'Beyaz midi etek + üst', category: 'üst', color: const Color(0xFFDEB887)),
        OutfitItem(emoji: '👢', name: weather.isCold ? 'Uzun çizme' : 'Sandalet', category: 'ayakkabı', color: const Color(0xFF8B4513)),
        const OutfitItem(emoji: '👜', name: 'Çapraz çanta', category: 'aksesuar', color: Color(0xFF1A3A4A)),
      ],
      alerts: [],
      primaryColor: const Color(0xFFDEB887),
      secondaryColor: const Color(0xFF1A3A4A),
      weatherMood: 'romantic',
    );
    return (person1, person2);
  }

  static (OutfitRecommendation, OutfitRecommendation) _bff(WeatherData weather) {
    const person1 = OutfitRecommendation(
      title: '👯 BFF 1',
      subtitle: 'Tarz ikizi',
      tip: 'Aynı stilde farklı renkler',
      items: [
        OutfitItem(emoji: '👕', name: 'Oversize tişört', category: 'üst', color: Color(0xFFFF69B4)),
        OutfitItem(emoji: '👖', name: 'Mom jean', category: 'alt', color: Color(0xFF36547E)),
        OutfitItem(emoji: '👟', name: 'Platform sneaker', category: 'ayakkabı', color: Color(0xFFFFFFFF)),
        OutfitItem(emoji: '🧢', name: 'Beyzbol şapka', category: 'aksesuar', color: Color(0xFFFF69B4)),
      ],
      alerts: [],
      primaryColor: Color(0xFFFF69B4),
      secondaryColor: Color(0xFF9370DB),
      weatherMood: 'fun',
    );
    const person2 = OutfitRecommendation(
      title: '👯 BFF 2',
      subtitle: 'Tarz ikizi',
      tip: 'Aynı model, farklı renk paleti',
      items: [
        OutfitItem(emoji: '👕', name: 'Oversize tişört', category: 'üst', color: Color(0xFF9370DB)),
        OutfitItem(emoji: '👖', name: 'Mom jean', category: 'alt', color: Color(0xFF36547E)),
        OutfitItem(emoji: '👟', name: 'Platform sneaker', category: 'ayakkabı', color: Color(0xFFFFFFFF)),
        OutfitItem(emoji: '🧢', name: 'Beyzbol şapka', category: 'aksesuar', color: Color(0xFF9370DB)),
      ],
      alerts: [],
      primaryColor: Color(0xFF9370DB),
      secondaryColor: Color(0xFFFF69B4),
      weatherMood: 'fun',
    );
    return (person1, person2);
  }

  static (OutfitRecommendation, OutfitRecommendation) _family(WeatherData weather) {
    const parent = OutfitRecommendation(
      title: '👨‍👩‍👧 Ebeveyn',
      subtitle: 'Aile uyumu',
      tip: 'Toprak tonlarında aile uyumu',
      items: [
        OutfitItem(emoji: '🧥', name: 'Haki ceket', category: 'dış giyim', color: Color(0xFF556B2F)),
        OutfitItem(emoji: '👕', name: 'Beyaz basic', category: 'üst', color: Color(0xFFFFFAFA)),
        OutfitItem(emoji: '👖', name: 'Chino pantolon', category: 'alt', color: Color(0xFFDEB887)),
        OutfitItem(emoji: '👟', name: 'Spor ayakkabı', category: 'ayakkabı', color: Color(0xFFFFFFFF)),
      ],
      alerts: [],
      primaryColor: Color(0xFF556B2F),
      secondaryColor: Color(0xFFDEB887),
      weatherMood: 'family',
    );
    const child = OutfitRecommendation(
      title: '👨‍👩‍👧 Çocuk',
      subtitle: 'Mini versiyon',
      tip: 'Rahat ve eğlenceli versiyonu',
      items: [
        OutfitItem(emoji: '🧥', name: 'Mini haki yelek', category: 'dış giyim', color: Color(0xFF556B2F)),
        OutfitItem(emoji: '👕', name: 'Baskılı tişört', category: 'üst', color: Color(0xFFFFFAFA)),
        OutfitItem(emoji: '👖', name: 'Rahat pantolon', category: 'alt', color: Color(0xFFDEB887)),
        OutfitItem(emoji: '👟', name: 'Velcro sneaker', category: 'ayakkabı', color: Color(0xFFFF6347)),
      ],
      alerts: [],
      primaryColor: Color(0xFFDEB887),
      secondaryColor: Color(0xFF556B2F),
      weatherMood: 'family',
    );
    return (parent, child);
  }

  static (OutfitRecommendation, OutfitRecommendation) _squad(WeatherData weather) {
    const person1 = OutfitRecommendation(
      title: '🤝 Ekip Üyesi 1',
      subtitle: 'Ekip ruhu',
      tip: 'Aynı renk temasında kişisel dokunuşlar',
      items: [
        OutfitItem(emoji: '👕', name: 'Siyah basic tee', category: 'üst', color: Color(0xFF1A1A1A)),
        OutfitItem(emoji: '👖', name: 'Siyah pantolon', category: 'alt', color: Color(0xFF2C2C2C)),
        OutfitItem(emoji: '👟', name: 'Siyah sneaker', category: 'ayakkabı', color: Color(0xFF1A1A1A)),
        OutfitItem(emoji: '🧣', name: 'Kırmızı aksesuar', category: 'aksesuar', color: Color(0xFFDC143C)),
      ],
      alerts: [],
      primaryColor: Color(0xFF1A1A1A),
      secondaryColor: Color(0xFFDC143C),
      weatherMood: 'edgy',
    );
    const person2 = OutfitRecommendation(
      title: '🤝 Ekip Üyesi 2',
      subtitle: 'Ekip ruhu',
      tip: 'Aynı tema, farklı yorum',
      items: [
        OutfitItem(emoji: '👕', name: 'Siyah bomber ceket', category: 'dış giyim', color: Color(0xFF1A1A1A)),
        OutfitItem(emoji: '👖', name: 'Koyu jean', category: 'alt', color: Color(0xFF2C2C2C)),
        OutfitItem(emoji: '👟', name: 'Combat bot', category: 'ayakkabı', color: Color(0xFF1A1A1A)),
        OutfitItem(emoji: '🧢', name: 'Kırmızı şapka', category: 'aksesuar', color: Color(0xFFDC143C)),
      ],
      alerts: [],
      primaryColor: Color(0xFF2C2C2C),
      secondaryColor: Color(0xFFDC143C),
      weatherMood: 'edgy',
    );
    return (person1, person2);
  }
}
