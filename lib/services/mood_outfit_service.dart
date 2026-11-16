import 'package:flutter/material.dart';
import '../models/outfit_model.dart';
import '../models/weather_model.dart';

class MoodOutfitService {
  static const moods = [
    {'id': 'happy', 'emoji': '😊', 'tr': 'Mutlu & Enerjik', 'en': 'Happy & Energetic'},
    {'id': 'confident', 'emoji': '💪', 'tr': 'Özgüvenli', 'en': 'Confident'},
    {'id': 'relaxed', 'emoji': '😌', 'tr': 'Rahat & Sakin', 'en': 'Relaxed & Calm'},
    {'id': 'romantic', 'emoji': '🥰', 'tr': 'Romantik', 'en': 'Romantic'},
    {'id': 'creative', 'emoji': '🎨', 'tr': 'Yaratıcı', 'en': 'Creative'},
    {'id': 'mysterious', 'emoji': '🖤', 'tr': 'Gizemli', 'en': 'Mysterious'},
    {'id': 'elegant', 'emoji': '✨', 'tr': 'Zarif', 'en': 'Elegant'},
    {'id': 'rebellious', 'emoji': '🔥', 'tr': 'Asi & Cesur', 'en': 'Rebellious & Bold'},
  ];

  static OutfitRecommendation getRecommendation(String moodId, WeatherData weather) {
    switch (moodId) {
      case 'happy':
        return _happyOutfit(weather);
      case 'confident':
        return _confidentOutfit(weather);
      case 'relaxed':
        return _relaxedOutfit(weather);
      case 'romantic':
        return _romanticOutfit(weather);
      case 'creative':
        return _creativeOutfit(weather);
      case 'mysterious':
        return _mysteriousOutfit(weather);
      case 'elegant':
        return _elegantOutfit(weather);
      case 'rebellious':
        return _rebelliousOutfit(weather);
      default:
        return OutfitEngine.getRecommendation(weather);
    }
  }

  static OutfitRecommendation _happyOutfit(WeatherData w) {
    return const OutfitRecommendation(
      title: '☀️ Mutlu & Enerjik Kombin',
      subtitle: 'Parlak renkler, pozitif enerji!',
      tip: 'Sarı, turuncu ve canlı renkler mutluluk yansıtır.',
      items: [
        OutfitItem(emoji: '👕', name: 'Sarı / Turuncu Tişört', category: 'üst', color: Color(0xFFFFA726)),
        OutfitItem(emoji: '👖', name: 'Açık Renk Jean', category: 'alt', color: Color(0xFF90CAF9)),
        OutfitItem(emoji: '👟', name: 'Renkli Sneaker', category: 'ayakkabı', color: Color(0xFF66BB6A)),
        OutfitItem(emoji: '🕶️', name: 'Güneş Gözlüğü', category: 'aksesuar', color: Color(0xFFFF7043)),
      ],
      alerts: [],
      primaryColor: Color(0xFFFFA726),
      secondaryColor: Color(0xFF66BB6A),
      weatherMood: 'sunny',
    );
  }

  static OutfitRecommendation _confidentOutfit(WeatherData w) {
    return const OutfitRecommendation(
      title: '💪 Özgüvenli Kombin',
      subtitle: 'Güçlü duruş, net çizgiler',
      tip: 'Koyu renkler ve keskin çizgiler güç gösterir.',
      items: [
        OutfitItem(emoji: '🧥', name: 'Yapılandırılmış Blazer', category: 'dış giyim', color: Color(0xFF1A1A2E)),
        OutfitItem(emoji: '👕', name: 'Fit Tişört / Gömlek', category: 'üst', color: Color(0xFFECECEC)),
        OutfitItem(emoji: '👖', name: 'Düz Kesim Pantolon', category: 'alt', color: Color(0xFF2C3E50)),
        OutfitItem(emoji: '👞', name: 'Deri Ayakkabı / Bot', category: 'ayakkabı', color: Color(0xFF1A1A1A)),
        OutfitItem(emoji: '⌚', name: 'Dikkat Çekici Saat', category: 'aksesuar', color: Color(0xFFBDBDBD)),
      ],
      alerts: [],
      primaryColor: Color(0xFF1A1A2E),
      secondaryColor: Color(0xFFBDBDBD),
      weatherMood: 'cloudy',
    );
  }

  static OutfitRecommendation _relaxedOutfit(WeatherData w) {
    return const OutfitRecommendation(
      title: '😌 Rahat & Sakin Kombin',
      subtitle: 'Yumuşak tonlar, bol kesim',
      tip: 'Oversize parçalar ve nötr renkler huzur verir.',
      items: [
        OutfitItem(emoji: '🧶', name: 'Oversize Sweatshirt', category: 'üst', color: Color(0xFFD7CCC8)),
        OutfitItem(emoji: '👖', name: 'Jogger / Bol Jean', category: 'alt', color: Color(0xFFBCAAA4)),
        OutfitItem(emoji: '👟', name: 'Slip-on / Loafer', category: 'ayakkabı', color: Color(0xFFEFEBE9)),
        OutfitItem(emoji: '🧣', name: 'Yumuşak Eşarp', category: 'aksesuar', color: Color(0xFFE0E0E0)),
      ],
      alerts: [],
      primaryColor: Color(0xFFD7CCC8),
      secondaryColor: Color(0xFFBCAAA4),
      weatherMood: 'cloudy',
    );
  }

  static OutfitRecommendation _romanticOutfit(WeatherData w) {
    return const OutfitRecommendation(
      title: '🥰 Romantik Kombin',
      subtitle: 'Yumuşak, feminen tonda',
      tip: 'Pastel tonlar ve akıcı kumaşlar romantik bir hava katar.',
      items: [
        OutfitItem(emoji: '👚', name: 'Pastel Bluz / Keten Gömlek', category: 'üst', color: Color(0xFFF8BBD0)),
        OutfitItem(emoji: '👗', name: 'Flowy Etek / Slim Pantolon', category: 'alt', color: Color(0xFFCE93D8)),
        OutfitItem(emoji: '👠', name: 'Zarif Ayakkabı', category: 'ayakkabı', color: Color(0xFFE1BEE7)),
        OutfitItem(emoji: '💐', name: 'İnce Takı / Çiçek', category: 'aksesuar', color: Color(0xFFFFCDD2)),
      ],
      alerts: [],
      primaryColor: Color(0xFFF8BBD0),
      secondaryColor: Color(0xFFCE93D8),
      weatherMood: 'sunny',
    );
  }

  static OutfitRecommendation _creativeOutfit(WeatherData w) {
    return const OutfitRecommendation(
      title: '🎨 Yaratıcı Kombin',
      subtitle: 'Cesur karışımlar, özgün parçalar',
      tip: 'Kural tanıma! Desen karıştır, renk çarp.',
      items: [
        OutfitItem(emoji: '🎭', name: 'Desenli / Grafik Üst', category: 'üst', color: Color(0xFF7C4DFF)),
        OutfitItem(emoji: '👖', name: 'Renkli Alt / Kargo', category: 'alt', color: Color(0xFF00BFA5)),
        OutfitItem(emoji: '👟', name: 'Platform / Renkli Sneaker', category: 'ayakkabı', color: Color(0xFFFF6E40)),
        OutfitItem(emoji: '🎒', name: 'Vintage Aksesuar', category: 'aksesuar', color: Color(0xFFFFD740)),
      ],
      alerts: [],
      primaryColor: Color(0xFF7C4DFF),
      secondaryColor: Color(0xFF00BFA5),
      weatherMood: 'sunny',
    );
  }

  static OutfitRecommendation _mysteriousOutfit(WeatherData w) {
    return const OutfitRecommendation(
      title: '🖤 Gizemli Kombin',
      subtitle: 'Koyu tonlar, minimalist çizgi',
      tip: 'Siyah ve koyu tonlar gizem yaratır. Az aksesuar, çok etki.',
      items: [
        OutfitItem(emoji: '🖤', name: 'Siyah Balıkçı Yaka / Tişört', category: 'üst', color: Color(0xFF212121)),
        OutfitItem(emoji: '👖', name: 'Siyah Slim Pantolon', category: 'alt', color: Color(0xFF1A1A1A)),
        OutfitItem(emoji: '🥾', name: 'Siyah Bot', category: 'ayakkabı', color: Color(0xFF0D0D0D)),
        OutfitItem(emoji: '🧥', name: 'Uzun Palto / Ceket', category: 'dış giyim', color: Color(0xFF263238)),
      ],
      alerts: [],
      primaryColor: Color(0xFF212121),
      secondaryColor: Color(0xFF263238),
      weatherMood: 'stormy',
    );
  }

  static OutfitRecommendation _elegantOutfit(WeatherData w) {
    return const OutfitRecommendation(
      title: '✨ Zarif Kombin',
      subtitle: 'Sofistike ve dengeli',
      tip: 'Kaliteli malzemeler ve uyumlu renkler zarafet getirir.',
      items: [
        OutfitItem(emoji: '👔', name: 'İpek / Saten Gömlek', category: 'üst', color: Color(0xFFF5E6CA)),
        OutfitItem(emoji: '👖', name: 'Düz Kesim Kumaş Pantolon', category: 'alt', color: Color(0xFF5D4037)),
        OutfitItem(emoji: '👞', name: 'İtalyan Tarz Ayakkabı', category: 'ayakkabı', color: Color(0xFF4E342E)),
        OutfitItem(emoji: '💎', name: 'Minimal Takı', category: 'aksesuar', color: Color(0xFFFFD700)),
      ],
      alerts: [],
      primaryColor: Color(0xFFF5E6CA),
      secondaryColor: Color(0xFF5D4037),
      weatherMood: 'sunny',
    );
  }

  static OutfitRecommendation _rebelliousOutfit(WeatherData w) {
    return const OutfitRecommendation(
      title: '🔥 Asi & Cesur Kombin',
      subtitle: 'Kuralları yık, fark yarat',
      tip: 'Deri, zincir, kontrastlı parçalar asi duruş verir.',
      items: [
        OutfitItem(emoji: '🧥', name: 'Deri Ceket', category: 'dış giyim', color: Color(0xFF1A1A1A)),
        OutfitItem(emoji: '👕', name: 'Band / Grafik Tişört', category: 'üst', color: Color(0xFFB71C1C)),
        OutfitItem(emoji: '👖', name: 'Yırtık Jean', category: 'alt', color: Color(0xFF37474F)),
        OutfitItem(emoji: '🥾', name: 'Ağır Bot', category: 'ayakkabı', color: Color(0xFF212121)),
        OutfitItem(emoji: '⛓️', name: 'Zincir / Bileklik', category: 'aksesuar', color: Color(0xFF9E9E9E)),
      ],
      alerts: [],
      primaryColor: Color(0xFFB71C1C),
      secondaryColor: Color(0xFF1A1A1A),
      weatherMood: 'stormy',
    );
  }
}
