import 'package:flutter/material.dart';
import '../models/outfit_model.dart';
import '../models/weather_model.dart';

class EventOutfitService {
  static const events = [
    {'id': 'work', 'emoji': '💼', 'tr': 'İş / Ofis', 'en': 'Work / Office'},
    {'id': 'date', 'emoji': '❤️', 'tr': 'Randevu / Buluşma', 'en': 'Date'},
    {'id': 'wedding', 'emoji': '💒', 'tr': 'Düğün / Nişan', 'en': 'Wedding'},
    {'id': 'party', 'emoji': '🎉', 'tr': 'Parti / Davet', 'en': 'Party / Event'},
    {'id': 'interview', 'emoji': '🤝', 'tr': 'Mülakat', 'en': 'Interview'},
    {'id': 'sport', 'emoji': '🏃', 'tr': 'Spor / Outdoor', 'en': 'Sport / Outdoor'},
    {'id': 'casual', 'emoji': '😎', 'tr': 'Günlük Gezi', 'en': 'Casual Outing'},
    {'id': 'school', 'emoji': '🎓', 'tr': 'Okul / Üniversite', 'en': 'School / University'},
  ];

  static OutfitRecommendation getRecommendation(String eventId, WeatherData weather, {String style = 'unisex'}) {
    switch (eventId) {
      case 'work':
        return _workOutfit(weather, style);
      case 'date':
        return _dateOutfit(weather, style);
      case 'wedding':
        return _weddingOutfit(weather, style);
      case 'party':
        return _partyOutfit(weather, style);
      case 'interview':
        return _interviewOutfit(weather, style);
      case 'sport':
        return _sportOutfit(weather, style);
      case 'school':
        return _schoolOutfit(weather, style);
      default:
        return OutfitEngine.getRecommendation(weather, style: style);
    }
  }

  static OutfitRecommendation _workOutfit(WeatherData w, String style) {
    final isCold = w.temperature < 12;
    final isHot = w.temperature > 28;
    return OutfitRecommendation(
      title: style == 'female' ? 'Ofis Şıklığı' : 'İş Kombinasyonu',
      subtitle: isCold ? 'Soğuk havada profesyonel' : (isHot ? 'Sıcakta rahat ama şık' : 'Profesyonel ve zarif'),
      tip: 'Nötr renkler güven verir. Lacivert ve beyaz her zaman çalışır.',
      items: [
        OutfitItem(emoji: style == 'female' ? '👚' : '👔', name: style == 'female' ? 'Gömlek / Bluz' : 'Gömlek', category: 'üst', color: const Color(0xFF1A3A5C)),
        OutfitItem(emoji: style == 'female' ? '👗' : '👖', name: style == 'female' ? 'Kalem Etek / Pantolon' : 'Kumaş Pantolon', category: 'alt', color: const Color(0xFF2C3E50)),
        if (isCold) const OutfitItem(emoji: '🧥', name: 'Blazer', category: 'dış giyim', color: Color(0xFF34495E)),
        OutfitItem(emoji: style == 'female' ? '👠' : '👞', name: style == 'female' ? 'Topuklu / Düz Ayakkabı' : 'Klasik Ayakkabı', category: 'ayakkabı', color: const Color(0xFF1A1A2E)),
        const OutfitItem(emoji: '⌚', name: 'Kol Saati', category: 'aksesuar', color: Color(0xFFBDBDBD)),
      ],
      alerts: [if (w.isRainy) '☂️ Şemsiye almayı unutma!'],
      primaryColor: const Color(0xFF1A3A5C),
      secondaryColor: const Color(0xFF2C3E50),
      weatherMood: w.isRainy ? 'rainy' : (w.isSunny ? 'sunny' : 'cloudy'),
    );
  }

  static OutfitRecommendation _dateOutfit(WeatherData w, String style) {
    return OutfitRecommendation(
      title: 'Romantik Kombin',
      subtitle: 'Etkileyici ve şık',
      tip: 'Kendin gibi hisset ama bir adım öteye taşı.',
      items: [
        OutfitItem(emoji: style == 'female' ? '👗' : '🧥', name: style == 'female' ? 'Şık Elbise' : 'Şık Ceket + Tişört', category: 'üst', color: const Color(0xFF8B0000)),
        OutfitItem(emoji: style == 'female' ? '👠' : '👞', name: style == 'female' ? 'Topuklu Ayakkabı' : 'Deri Ayakkabı', category: 'ayakkabı', color: const Color(0xFF2C2C2C)),
        OutfitItem(emoji: style == 'female' ? '👜' : '⌚', name: style == 'female' ? 'Clutch Çanta' : 'Şık Saat', category: 'aksesuar', color: const Color(0xFFC0A060)),
        if (style != 'female') const OutfitItem(emoji: '👖', name: 'Slim Fit Pantolon', category: 'alt', color: Color(0xFF1A1A2E)),
        const OutfitItem(emoji: '💐', name: 'Parfüm', category: 'aksesuar', color: Color(0xFFD4A574)),
      ],
      alerts: [],
      primaryColor: const Color(0xFF8B0000),
      secondaryColor: const Color(0xFFC0A060),
      weatherMood: 'sunny',
    );
  }

  static OutfitRecommendation _weddingOutfit(WeatherData w, String style) {
    return OutfitRecommendation(
      title: 'Düğün / Davet',
      subtitle: 'Göz alıcı ve zarif',
      tip: 'Beyaz giyme (gelin rengine saygı), koyu tonlar şık durur.',
      items: [
        OutfitItem(emoji: style == 'female' ? '👗' : '🤵', name: style == 'female' ? 'Abiye Elbise' : 'Takım Elbise', category: 'üst', color: const Color(0xFF191970)),
        OutfitItem(emoji: style == 'female' ? '👠' : '👞', name: style == 'female' ? 'İnce Topuk' : 'Oxford Ayakkabı', category: 'ayakkabı', color: const Color(0xFF1A1A1A)),
        OutfitItem(emoji: style == 'female' ? '💎' : '🎀', name: style == 'female' ? 'Takı Seti' : 'Papyon / Kravat', category: 'aksesuar', color: const Color(0xFFFFD700)),
        OutfitItem(emoji: style == 'female' ? '👜' : '🧥', name: style == 'female' ? 'Abiye Çanta' : 'Blazer', category: style == 'female' ? 'aksesuar' : 'dış giyim', color: const Color(0xFF2C3E50)),
      ],
      alerts: [if (w.isRainy) '☂️ Yağmur bekleniyor, şemsiye al!'],
      primaryColor: const Color(0xFF191970),
      secondaryColor: const Color(0xFFFFD700),
      weatherMood: 'sunny',
    );
  }

  static OutfitRecommendation _partyOutfit(WeatherData w, String style) {
    return OutfitRecommendation(
      title: 'Parti Gecesi',
      subtitle: 'Eğlenceli ve cesur',
      tip: 'Cesur renkler ve ışıltılı parçalar partide fark yaratır.',
      items: [
        OutfitItem(emoji: style == 'female' ? '✨' : '🧥', name: style == 'female' ? 'Payetli Üst' : 'Deri Ceket', category: 'üst', color: const Color(0xFFFF1493)),
        OutfitItem(emoji: style == 'female' ? '👖' : '👖', name: style == 'female' ? 'Skinny Jean' : 'Siyah Slim Jean', category: 'alt', color: const Color(0xFF1A1A1A)),
        OutfitItem(emoji: style == 'female' ? '👢' : '🥾', name: style == 'female' ? 'Bot / Topuklu' : 'Chelsea Bot', category: 'ayakkabı', color: const Color(0xFF2C2C2C)),
        const OutfitItem(emoji: '😎', name: 'İddia Parçası Aksesuar', category: 'aksesuar', color: Color(0xFFFFD700)),
      ],
      alerts: [],
      primaryColor: const Color(0xFFFF1493),
      secondaryColor: const Color(0xFF1A1A1A),
      weatherMood: 'sunny',
    );
  }

  static OutfitRecommendation _interviewOutfit(WeatherData w, String style) {
    return OutfitRecommendation(
      title: 'Mülakat Kombini',
      subtitle: 'Güven veren, profesyonel',
      tip: 'Lacivert ve gri güven verir. Aşırı aksesuar kullanmayın.',
      items: [
        OutfitItem(emoji: style == 'female' ? '👚' : '👔', name: style == 'female' ? 'Düğmeli Gömlek' : 'Beyaz Gömlek', category: 'üst', color: const Color(0xFFF5F5F5)),
        OutfitItem(emoji: style == 'female' ? '👖' : '👖', name: 'Kumaş Pantolon', category: 'alt', color: const Color(0xFF2C3E50)),
        const OutfitItem(emoji: '🧥', name: 'Blazer / Ceket', category: 'dış giyim', color: Color(0xFF1A3A5C)),
        OutfitItem(emoji: style == 'female' ? '👟' : '👞', name: style == 'female' ? 'Düz Ayakkabı' : 'Klasik Ayakkabı', category: 'ayakkabı', color: const Color(0xFF1A1A1A)),
      ],
      alerts: ['⏰ Mülakata erken git, güven hisset!'],
      primaryColor: const Color(0xFF1A3A5C),
      secondaryColor: const Color(0xFFF5F5F5),
      weatherMood: 'cloudy',
    );
  }

  static OutfitRecommendation _sportOutfit(WeatherData w, String style) {
    final isCold = w.temperature < 12;
    return OutfitRecommendation(
      title: 'Spor / Outdoor',
      subtitle: isCold ? 'Soğuğa karşı hareketli' : 'Rahat ve hareketli',
      tip: 'Nefes alan kumaşlar şart. Katmanlı giyinin.',
      items: [
        const OutfitItem(emoji: '🏃', name: 'Spor Tişört', category: 'üst', color: Color(0xFF2ECC71)),
        OutfitItem(emoji: '🩳', name: isCold ? 'Eşofman Altı' : 'Spor Şort', category: 'alt', color: const Color(0xFF2C3E50)),
        const OutfitItem(emoji: '👟', name: 'Spor Ayakkabı', category: 'ayakkabı', color: Color(0xFF3498DB)),
        if (isCold) const OutfitItem(emoji: '🧥', name: 'Rüzgarlık', category: 'dış giyim', color: Color(0xFF34495E)),
        const OutfitItem(emoji: '🧢', name: 'Şapka', category: 'aksesuar', color: Color(0xFF2ECC71)),
      ],
      alerts: [if (w.uvIndex > 6) '☀️ UV yüksek, güneş kremi sür!'],
      primaryColor: const Color(0xFF2ECC71),
      secondaryColor: const Color(0xFF3498DB),
      weatherMood: 'sunny',
    );
  }

  static OutfitRecommendation _schoolOutfit(WeatherData w, String style) {
    final isCold = w.temperature < 12;
    return OutfitRecommendation(
      title: 'Okul / Kampüs',
      subtitle: 'Rahat ama şık',
      tip: 'Rahat ve pratik parçalar seç, gün boyu hareket edeceksin.',
      items: [
        const OutfitItem(emoji: '👕', name: 'Oversize Tişört / Sweatshirt', category: 'üst', color: Color(0xFF5DADE2)),
        const OutfitItem(emoji: '👖', name: 'Jean / Jogger', category: 'alt', color: Color(0xFF2C3E50)),
        const OutfitItem(emoji: '👟', name: 'Sneaker', category: 'ayakkabı', color: Color(0xFFECF0F1)),
        if (isCold) const OutfitItem(emoji: '🧥', name: 'Hoodie / Mont', category: 'dış giyim', color: Color(0xFF34495E)),
        const OutfitItem(emoji: '🎒', name: 'Sırt Çantası', category: 'aksesuar', color: Color(0xFF7F8C8D)),
      ],
      alerts: [if (w.isRainy) '🌧️ Yağmurluk veya şemsiye al!'],
      primaryColor: const Color(0xFF5DADE2),
      secondaryColor: const Color(0xFF2C3E50),
      weatherMood: w.isRainy ? 'rainy' : 'sunny',
    );
  }
}
