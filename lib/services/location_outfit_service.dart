import '../models/outfit_model.dart';
import '../models/weather_model.dart';
import 'package:flutter/material.dart';

class LocationType {
  final String id;
  final String emoji;
  final String nameTR;
  final String nameEN;

  const LocationType({
    required this.id,
    required this.emoji,
    required this.nameTR,
    required this.nameEN,
  });
}

class LocationOutfitService {
  static const locations = [
    LocationType(id: 'restaurant', emoji: '🍽️', nameTR: 'Restoran', nameEN: 'Restaurant'),
    LocationType(id: 'mall', emoji: '🛍️', nameTR: 'AVM', nameEN: 'Shopping Mall'),
    LocationType(id: 'nature', emoji: '🌿', nameTR: 'Doğa', nameEN: 'Nature'),
    LocationType(id: 'cinema', emoji: '🎬', nameTR: 'Sinema', nameEN: 'Cinema'),
    LocationType(id: 'gym', emoji: '💪', nameTR: 'Spor Salonu', nameEN: 'Gym'),
    LocationType(id: 'cafe', emoji: '☕', nameTR: 'Kafe', nameEN: 'Cafe'),
    LocationType(id: 'museum', emoji: '🏛️', nameTR: 'Müze', nameEN: 'Museum'),
    LocationType(id: 'beach', emoji: '🏖️', nameTR: 'Plaj', nameEN: 'Beach'),
    LocationType(id: 'concert', emoji: '🎵', nameTR: 'Konser', nameEN: 'Concert'),
    LocationType(id: 'library', emoji: '📚', nameTR: 'Kütüphane', nameEN: 'Library'),
  ];

  static OutfitRecommendation getRecommendation(String locationId, WeatherData weather) {
    return switch (locationId) {
      'restaurant' => _restaurant(weather),
      'mall' => _mall(weather),
      'nature' => _nature(weather),
      'cinema' => _cinema(weather),
      'gym' => _gym(weather),
      'cafe' => _cafe(weather),
      'museum' => _museum(weather),
      'beach' => _beach(weather),
      'concert' => _concert(weather),
      'library' => _library(weather),
      _ => _restaurant(weather),
    };
  }

  static OutfitRecommendation _restaurant(WeatherData weather) {
    final items = <OutfitItem>[
      OutfitItem(emoji: '👔', name: weather.isCold ? 'Şık gömlek + blazer' : 'Keten gömlek', category: 'üst', color: const Color(0xFF1A3A4A)),
      const OutfitItem(emoji: '👖', name: 'Kumaş pantolon', category: 'alt', color: Color(0xFF2C2C2C)),
      const OutfitItem(emoji: '👞', name: 'Klasik ayakkabı', category: 'ayakkabı', color: Color(0xFF5C3317)),
      const OutfitItem(emoji: '⌚', name: 'Şık saat', category: 'aksesuar', color: Color(0xFFD4AF37)),
    ];
    return OutfitRecommendation(title: '🍽️ Restoran Stili', subtitle: 'Şık ama rahat', tip: 'Restoranda göz alıcı ama rahat hissettirecek parçalar seç', items: items, alerts: weather.isRainy ? ['☂️ Yağmur var, şemsiye al'] : [], primaryColor: const Color(0xFF1A3A4A), secondaryColor: const Color(0xFF8B4513), weatherMood: 'elegant');
  }

  static OutfitRecommendation _mall(WeatherData weather) {
    final items = <OutfitItem>[
      const OutfitItem(emoji: '👕', name: 'Rahat t-shirt', category: 'üst', color: Color(0xFF4A90D9)),
      const OutfitItem(emoji: '👖', name: 'Jean pantolon', category: 'alt', color: Color(0xFF36547E)),
      const OutfitItem(emoji: '👟', name: 'Rahat sneaker', category: 'ayakkabı', color: Color(0xFFFFFFFF)),
      const OutfitItem(emoji: '🎒', name: 'Sırt çantası', category: 'aksesuar', color: Color(0xFF2C2C2C)),
    ];
    return OutfitRecommendation(title: '🛍️ AVM Turu', subtitle: 'Rahat ve şık', tip: 'Uzun yürüyüş için rahat ayakkabı şart', items: items, alerts: [], primaryColor: const Color(0xFF4A90D9), secondaryColor: const Color(0xFF7B68EE), weatherMood: 'casual');
  }

  static OutfitRecommendation _nature(WeatherData weather) {
    final items = <OutfitItem>[
      OutfitItem(emoji: '🧥', name: weather.isCold ? 'Outdoor mont' : 'Hafif rüzgarlık', category: 'dış giyim', color: const Color(0xFF556B2F)),
      const OutfitItem(emoji: '👖', name: 'Outdoor pantolon', category: 'alt', color: Color(0xFF696969)),
      const OutfitItem(emoji: '🥾', name: 'Trekking bot', category: 'ayakkabı', color: Color(0xFF8B4513)),
      const OutfitItem(emoji: '🧢', name: 'Şapka', category: 'aksesuar', color: Color(0xFF556B2F)),
    ];
    if (weather.uvIndex > 5) items.add(const OutfitItem(emoji: '🕶️', name: 'Güneş gözlüğü', category: 'aksesuar', color: Color(0xFF1A1A1A)));
    return OutfitRecommendation(title: '🌿 Doğa Macerası', subtitle: 'Dayanıklı ve rahat', tip: 'Katmanlı giyin, doğada hava hızlı değişir', items: items, alerts: weather.uvIndex > 5 ? ['☀️ UV yüksek, güneş kremi sür'] : [], primaryColor: const Color(0xFF556B2F), secondaryColor: const Color(0xFF8B7355), weatherMood: 'outdoor');
  }

  static OutfitRecommendation _cinema(WeatherData weather) {
    final items = <OutfitItem>[
      const OutfitItem(emoji: '🧥', name: 'Hırka / kazak', category: 'üst', color: Color(0xFF4A4A4A)),
      const OutfitItem(emoji: '👖', name: 'Rahat jean', category: 'alt', color: Color(0xFF36547E)),
      const OutfitItem(emoji: '👟', name: 'Slip-on', category: 'ayakkabı', color: Color(0xFF2C2C2C)),
    ];
    return OutfitRecommendation(title: '🎬 Sinema Keyfi', subtitle: 'İçeride serin olabilir', tip: 'Sinema salonları genelde serin, hırka al', items: items, alerts: [], primaryColor: const Color(0xFF4A4A4A), secondaryColor: const Color(0xFF8B4513), weatherMood: 'cozy');
  }

  static OutfitRecommendation _gym(WeatherData weather) {
    final items = <OutfitItem>[
      const OutfitItem(emoji: '🏋️', name: 'Performans tişört', category: 'üst', color: Color(0xFF1A1A1A)),
      OutfitItem(emoji: '🩳', name: weather.isHot ? 'Şort' : 'Eşofman', category: 'alt', color: const Color(0xFF333333)),
      const OutfitItem(emoji: '👟', name: 'Spor ayakkabı', category: 'ayakkabı', color: Color(0xFFFF4500)),
      const OutfitItem(emoji: '💧', name: 'Su matarası', category: 'aksesuar', color: Color(0xFF4A90D9)),
    ];
    return OutfitRecommendation(title: '💪 Spor Stili', subtitle: 'Performans odaklı', tip: 'Ter atıcı kumaş tercih et', items: items, alerts: [], primaryColor: const Color(0xFF1A1A1A), secondaryColor: const Color(0xFFFF4500), weatherMood: 'sporty');
  }

  static OutfitRecommendation _cafe(WeatherData weather) {
    final items = <OutfitItem>[
      OutfitItem(emoji: '👕', name: weather.isCold ? 'Boğazlı kazak' : 'Oversize tişört', category: 'üst', color: const Color(0xFFDEB887)),
      const OutfitItem(emoji: '👖', name: 'Mom jean', category: 'alt', color: Color(0xFF36547E)),
      const OutfitItem(emoji: '👟', name: 'Converse / loafer', category: 'ayakkabı', color: Color(0xFFF5F5DC)),
      const OutfitItem(emoji: '📖', name: 'Kitap / tablet', category: 'aksesuar', color: Color(0xFF8B4513)),
    ];
    return OutfitRecommendation(title: '☕ Kafe Stili', subtitle: 'Rahat ve estetik', tip: 'Kafe ortamına uygun, bohem bir parça ekle', items: items, alerts: [], primaryColor: const Color(0xFFDEB887), secondaryColor: const Color(0xFF8B4513), weatherMood: 'cozy');
  }

  static OutfitRecommendation _museum(WeatherData weather) {
    final items = <OutfitItem>[
      const OutfitItem(emoji: '🧥', name: 'Klasik trençkot', category: 'dış giyim', color: Color(0xFFD2B48C)),
      const OutfitItem(emoji: '👔', name: 'Polo yaka', category: 'üst', color: Color(0xFF1A3A4A)),
      const OutfitItem(emoji: '👖', name: 'Chino pantolon', category: 'alt', color: Color(0xFFA0522D)),
      const OutfitItem(emoji: '👞', name: 'Loafer', category: 'ayakkabı', color: Color(0xFF5C3317)),
    ];
    return OutfitRecommendation(title: '🏛️ Müze Gezisi', subtitle: 'Kültürel ve şık', tip: 'Rahat ama gösterişli parçalar seç', items: items, alerts: [], primaryColor: const Color(0xFF1A3A4A), secondaryColor: const Color(0xFFD2B48C), weatherMood: 'elegant');
  }

  static OutfitRecommendation _beach(WeatherData weather) {
    final items = <OutfitItem>[
      const OutfitItem(emoji: '👙', name: 'Mayo / bikini', category: 'üst', color: Color(0xFF00CED1)),
      const OutfitItem(emoji: '🩳', name: 'Plaj şortu', category: 'alt', color: Color(0xFFFF6347)),
      const OutfitItem(emoji: '🩴', name: 'Parmak arası', category: 'ayakkabı', color: Color(0xFFFFD700)),
      const OutfitItem(emoji: '🕶️', name: 'Güneş gözlüğü', category: 'aksesuar', color: Color(0xFF1A1A1A)),
      const OutfitItem(emoji: '🧴', name: 'Güneş kremi', category: 'aksesuar', color: Color(0xFFFFA500)),
    ];
    return OutfitRecommendation(title: '🏖️ Plaj Keyfi', subtitle: 'Yaz, güneş, deniz!', tip: 'SPF50+ güneş kremi unutma', items: items, alerts: weather.uvIndex > 7 ? ['☀️ UV çok yüksek! Şapka ve koruma şart'] : [], primaryColor: const Color(0xFF00CED1), secondaryColor: const Color(0xFFFF6347), weatherMood: 'sunny');
  }

  static OutfitRecommendation _concert(WeatherData weather) {
    final items = <OutfitItem>[
      const OutfitItem(emoji: '🎸', name: 'Band tişört / siyah üst', category: 'üst', color: Color(0xFF1A1A1A)),
      const OutfitItem(emoji: '👖', name: 'Skinny jean', category: 'alt', color: Color(0xFF2C2C2C)),
      OutfitItem(emoji: '🥾', name: weather.isRainy ? 'Su geçirmez bot' : 'Platform bot', category: 'ayakkabı', color: const Color(0xFF1A1A1A)),
      const OutfitItem(emoji: '🧣', name: 'Bandana / kolye', category: 'aksesuar', color: Color(0xFFFF4500)),
    ];
    return OutfitRecommendation(title: '🎵 Konser Stili', subtitle: 'Rock & Roll', tip: 'Rahat ayakkabı giy, uzun süre ayakta kalacaksın', items: items, alerts: [], primaryColor: const Color(0xFF1A1A1A), secondaryColor: const Color(0xFFFF4500), weatherMood: 'edgy');
  }

  static OutfitRecommendation _library(WeatherData weather) {
    final items = <OutfitItem>[
      const OutfitItem(emoji: '🧥', name: 'Hırka / v-yaka kazak', category: 'üst', color: Color(0xFF8B7355)),
      const OutfitItem(emoji: '👖', name: 'Kumaş pantolon', category: 'alt', color: Color(0xFF4A4A4A)),
      const OutfitItem(emoji: '👟', name: 'Sessiz tabanlı ayakkabı', category: 'ayakkabı', color: Color(0xFF8B4513)),
      const OutfitItem(emoji: '👓', name: 'Gözlük', category: 'aksesuar', color: Color(0xFF2C2C2C)),
    ];
    return OutfitRecommendation(title: '📚 Kütüphane Stili', subtitle: 'Akademik ve rahat', tip: 'Sessiz ve rahat parçalar seç', items: items, alerts: [], primaryColor: const Color(0xFF8B7355), secondaryColor: const Color(0xFF4A4A4A), weatherMood: 'cozy');
  }
}
