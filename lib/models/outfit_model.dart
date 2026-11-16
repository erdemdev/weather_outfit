import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class OutfitItem {
  final String emoji;
  final String name;
  final String category; // üst, alt, ayakkabı, aksesuar, dış giyim
  final Color color;

  const OutfitItem({
    required this.emoji,
    required this.name,
    required this.category,
    required this.color,
  });
}

class OutfitRecommendation {
  final String title;
  final String subtitle;
  final String tip;
  final List<OutfitItem> items;
  final List<String> alerts;
  final Color primaryColor;
  final Color secondaryColor;
  final String weatherMood; // stormy, rainy, cloudy, sunny, cold, hot

  const OutfitRecommendation({
    required this.title,
    required this.subtitle,
    required this.tip,
    required this.items,
    required this.alerts,
    required this.primaryColor,
    required this.secondaryColor,
    required this.weatherMood,
  });
}

class OutfitEngine {
  static OutfitRecommendation getRecommendation(WeatherData weather, {String style = 'unisex'}) {
    if (weather.isSnowy) return _snowyOutfit(weather, style);
    if (weather.condition == 'thunderstorm') return _stormyOutfit(weather, style);
    if (weather.isRainy && weather.isCold) return _coldRainyOutfit(weather, style);
    if (weather.isRainy) return _rainyOutfit(weather, style);
    if (weather.isCold) return _coldOutfit(weather, style);
    if (weather.isHot) return _hotOutfit(weather, style);
    if (weather.isWarm && weather.isSunny) return _sunnySummerOutfit(weather, style);
    if (weather.isWarm) return _warmOutfit(weather, style);
    if (weather.isMild) return _mildOutfit(weather, style);
    return _mildOutfit(weather, style);
  }

  // ─── KAR ────────────────────────────────────────────────────────────────────
  static OutfitRecommendation _snowyOutfit(WeatherData w, String style) {
    switch (style) {
      case 'female':
        return const OutfitRecommendation(
          title: 'Kar Şıklığı ❄️',
          subtitle: 'Sıcak tut, şık görün!',
          tip: 'Kısa şişme mont ve uzun kar botu kombinasyonu hem sıcak tutar hem de kar estetiğini tamamlar. Ponpon bereni unutma!',
          weatherMood: 'stormy',
          primaryColor: Color(0xFF5B8DD9),
          secondaryColor: Color(0xFFD6E8FF),
          items: [
            OutfitItem(emoji: '🧥', name: 'Kısa şişme mont (pastel)', category: 'dış giyim', color: Color(0xFFB0C4DE)),
            OutfitItem(emoji: '👕', name: 'Balıkçı yaka kazak', category: 'üst', color: Color(0xFFD4B8A8)),
            OutfitItem(emoji: '👖', name: 'Yüksek bel termal pantolon', category: 'alt', color: Color(0xFF3D3D5C)),
            OutfitItem(emoji: '👢', name: 'Uzun kar botu (topuklu)', category: 'ayakkabı', color: Color(0xFF2C3E50)),
            OutfitItem(emoji: '🧣', name: 'Ponpon atkı', category: 'aksesuar', color: Color(0xFFE8A0A0)),
            OutfitItem(emoji: '🧤', name: 'Deri eldiven', category: 'aksesuar', color: Color(0xFF555555)),
            OutfitItem(emoji: '🧢', name: 'Ponpon bere', category: 'aksesuar', color: Color(0xFF7F5A3C)),
            OutfitItem(emoji: '🧦', name: 'Termal çorap', category: 'aksesuar', color: Color(0xFF555555)),
          ],
          alerts: [
            '⚠️ Yollar kaygan olabilir, dikkatli yürü',
            '☃️ Platform kar botu normal ayakkabıdan çok daha güvenli',
            '🧴 Dudak kremi ve nemlendirici şart',
          ],
        );
      case 'male':
        return const OutfitRecommendation(
          title: 'Kar Kombini ❄️',
          subtitle: 'Pratik ve sıcak!',
          tip: 'Kar yağıyor! Termal iç giyim + uzun kaz tüyü mont kombinasyonu rüzgarı ve soğuğu tamamen keser. Su geçirmez bot zorunlu.',
          weatherMood: 'stormy',
          primaryColor: Color(0xFF3A5FA0),
          secondaryColor: Color(0xFFD6E8FF),
          items: [
            OutfitItem(emoji: '🧥', name: 'Uzun kaz tüyü mont', category: 'dış giyim', color: Color(0xFF2C3E50)),
            OutfitItem(emoji: '👕', name: 'Kalın balıkçı yaka kazak', category: 'üst', color: Color(0xFF7A6A5A)),
            OutfitItem(emoji: '👕', name: 'Termal iç giyim seti', category: 'üst', color: Color(0xFFBCBCBC)),
            OutfitItem(emoji: '👖', name: 'Su itici kargo pantolon', category: 'alt', color: Color(0xFF3D3D5C)),
            OutfitItem(emoji: '👢', name: 'Yüksek bilek kar botu', category: 'ayakkabı', color: Color(0xFF1A1A2E)),
            OutfitItem(emoji: '🧣', name: 'Yünlü atkı', category: 'aksesuar', color: Color(0xFFB5604A)),
            OutfitItem(emoji: '🧤', name: 'Kışlık eldiven', category: 'aksesuar', color: Color(0xFF555555)),
            OutfitItem(emoji: '🧢', name: 'Kışlık bere', category: 'aksesuar', color: Color(0xFF7F5A3C)),
            OutfitItem(emoji: '🧦', name: 'Termal çorap', category: 'aksesuar', color: Color(0xFF555555)),
          ],
          alerts: [
            '⚠️ Yollar kaygan olabilir, dikkatli yürü',
            '☃️ Su geçirmez bot zorunlu, normal ayakkabı kayar',
            '🧴 Dudak kremi ve nemlendirici unutma',
          ],
        );
      default: // unisex
        return const OutfitRecommendation(
          title: 'Kar Kombini ❄️',
          subtitle: 'Sıcak tut kendini!',
          tip: 'Kar yağıyor! Katmanlı giyim şart. Su geçirmez bot ve kalın mont hayat kurtarır. Atkı, bere, eldiven üçlüsünü sakın unutma!',
          weatherMood: 'stormy',
          primaryColor: Color(0xFF5B8DD9),
          secondaryColor: Color(0xFFD6E8FF),
          items: [
            OutfitItem(emoji: '🧥', name: 'Kaz tüyü mont', category: 'dış giyim', color: Color(0xFF3A5FA0)),
            OutfitItem(emoji: '👕', name: 'Balıkçı yaka kazak', category: 'üst', color: Color(0xFF7A6A5A)),
            OutfitItem(emoji: '👖', name: 'Kalın kışlık pantolon', category: 'alt', color: Color(0xFF3D3D5C)),
            OutfitItem(emoji: '🧣', name: 'Yünlü atkı', category: 'aksesuar', color: Color(0xFFB5604A)),
            OutfitItem(emoji: '🧤', name: 'Kışlık eldiven', category: 'aksesuar', color: Color(0xFF555555)),
            OutfitItem(emoji: '👢', name: 'Kar botu', category: 'ayakkabı', color: Color(0xFF2C3E50)),
            OutfitItem(emoji: '🧢', name: 'Kışlık bere', category: 'aksesuar', color: Color(0xFF7F5A3C)),
            OutfitItem(emoji: '🧦', name: 'Termal çorap', category: 'aksesuar', color: Color(0xFF555555)),
          ],
          alerts: [
            '⚠️ Yollar kaygan olabilir, dikkatli yürü',
            '☃️ Kar botu zorunlu, normal ayakkabı kayar',
            '🧴 Dudak kremi ve nemlendirici unutma',
          ],
        );
    }
  }

  // ─── FIRTINA ────────────────────────────────────────────────────────────────
  static OutfitRecommendation _stormyOutfit(WeatherData w, String style) {
    switch (style) {
      case 'female':
        return const OutfitRecommendation(
          title: 'Fırtına Şıklığı ⛈️',
          subtitle: 'Pratik ama şık kal!',
          tip: 'Fırtınada uzun su geçirmez yağmurluk ve platform bot en iyi kombinasyon. Güçlü bir şemsiye elinden düşürme!',
          weatherMood: 'stormy',
          primaryColor: Color(0xFF4A4E69),
          secondaryColor: Color(0xFFD4D8FF),
          items: [
            OutfitItem(emoji: '🧥', name: 'Uzun su geçirmez yağmurluk', category: 'dış giyim', color: Color(0xFF2E4A3E)),
            OutfitItem(emoji: '👕', name: 'Kapüşonlu sweatshirt', category: 'üst', color: Color(0xFF78909C)),
            OutfitItem(emoji: '👖', name: 'Skinny jean', category: 'alt', color: Color(0xFF3D5A80)),
            OutfitItem(emoji: '👢', name: 'Platform su geçirmez bot', category: 'ayakkabı', color: Color(0xFF2C3E50)),
            OutfitItem(emoji: '🌂', name: 'Güçlü saplı şemsiye', category: 'aksesuar', color: Color(0xFF4A3A6A)),
            OutfitItem(emoji: '🎒', name: 'Su geçirmez sırt çantası', category: 'aksesuar', color: Color(0xFF2C3E50)),
          ],
          alerts: [
            '⚡ Açık alanlarda yıldırım tehlikesi!',
            '💨 Şemsiyeni ters çevirebilecek rüzgar var',
            '🚗 Mümkünse araçla git',
            '📱 Hava durumu uyarılarını takip et',
          ],
        );
      case 'male':
        return const OutfitRecommendation(
          title: 'Fırtına Kombini ⛈️',
          subtitle: 'Sert havaya hazır ol!',
          tip: 'Kapüşonlu parka ceket ve bot fırtınada en güvenli seçim. Şemsiyeyi güçlü seç, zayıf şemsiye işe yaramaz.',
          weatherMood: 'stormy',
          primaryColor: Color(0xFF2C3E50),
          secondaryColor: Color(0xFFD4D8FF),
          items: [
            OutfitItem(emoji: '🧥', name: 'Kapüşonlu su geçirmez parka', category: 'dış giyim', color: Color(0xFF1A3A2A)),
            OutfitItem(emoji: '👕', name: 'Kapüşonlu sweatshirt', category: 'üst', color: Color(0xFF555555)),
            OutfitItem(emoji: '👖', name: 'Kargo pantolon', category: 'alt', color: Color(0xFF3D5A80)),
            OutfitItem(emoji: '👢', name: 'Yüksek bilek su geçirmez bot', category: 'ayakkabı', color: Color(0xFF1A1A2E)),
            OutfitItem(emoji: '🌂', name: 'Güçlü şemsiye', category: 'aksesuar', color: Color(0xFF2C2C54)),
            OutfitItem(emoji: '🧦', name: 'Su geçirmez çorap', category: 'aksesuar', color: Color(0xFF333333)),
          ],
          alerts: [
            '⚡ Açık alanlarda yıldırım tehlikesi!',
            '💨 Şemsiyeni ters çevirebilecek rüzgar var',
            '🚗 Araçla gitmeyi tercih et',
            '📱 Hava durumu uyarılarını takip et',
          ],
        );
      default: // unisex
        return const OutfitRecommendation(
          title: 'Fırtına Kombini ⛈️',
          subtitle: 'Mümkünse evde kal!',
          tip: 'Gök gürültülü fırtına var. Zorunlu değilsen dışarı çıkma. Çıkman gerekiyorsa su geçirmez kıyafetler giy ve şemsiyeni al!',
          weatherMood: 'stormy',
          primaryColor: Color(0xFF4A4E69),
          secondaryColor: Color(0xFFD4D8FF),
          items: [
            OutfitItem(emoji: '🧥', name: 'Su geçirmez yağmurluk', category: 'dış giyim', color: Color(0xFF1A6B4A)),
            OutfitItem(emoji: '🧥', name: 'Kapüşonlu sweatshirt', category: 'üst', color: Color(0xFF555555)),
            OutfitItem(emoji: '👖', name: 'Kalın kot pantolon', category: 'alt', color: Color(0xFF3D5A80)),
            OutfitItem(emoji: '👢', name: 'Su geçirmez bot', category: 'ayakkabı', color: Color(0xFF2C3E50)),
            OutfitItem(emoji: '🌂', name: 'Güçlü şemsiye', category: 'aksesuar', color: Color(0xFF2C2C54)),
            OutfitItem(emoji: '🧦', name: 'Su geçirmez çorap', category: 'aksesuar', color: Color(0xFF333333)),
          ],
          alerts: [
            '⚡ Açık alanlarda yıldırım tehlikesi!',
            '💨 Şemsiyeni ters çevirebilecek rüzgar var',
            '🚗 Araçla gitmeyi tercih et',
            '📱 Hava durumu uyarılarını takip et',
          ],
        );
    }
  }

  // ─── SOĞUK + YAĞMUR ─────────────────────────────────────────────────────────
  static OutfitRecommendation _coldRainyOutfit(WeatherData w, String style) {
    switch (style) {
      case 'female':
        return OutfitRecommendation(
          title: 'Soğuk Yağmur Şıklığı 🌧️',
          subtitle: 'Rain chic modu açık!',
          tip: 'Uzun trençkot ve platform bot bu hava için biçilmiş kaftan. Midiniz altında termal tayt giymeyi unutma!',
          weatherMood: 'rainy',
          primaryColor: const Color(0xFF6B5B8A),
          secondaryColor: const Color(0xFFD0EAF8),
          items: const [
            OutfitItem(emoji: '🧥', name: 'Uzun su geçirmez trençkot', category: 'dış giyim', color: Color(0xFFD4C4B0)),
            OutfitItem(emoji: '👕', name: 'İnce balıkçı yaka kazak', category: 'üst', color: Color(0xFF9B8EA0)),
            OutfitItem(emoji: '👖', name: 'Termal tayt / kalın pantolon', category: 'alt', color: Color(0xFF3D3D5C)),
            OutfitItem(emoji: '👢', name: 'Platform Chelsea bot', category: 'ayakkabı', color: Color(0xFF2C2A1E)),
            OutfitItem(emoji: '🌂', name: 'Şemsiye', category: 'aksesuar', color: Color(0xFF6B5B8A)),
            OutfitItem(emoji: '🧣', name: 'İnce atkı', category: 'aksesuar', color: Color(0xFF8B4B6C)),
            OutfitItem(emoji: '🧦', name: 'Kalın çorap', category: 'aksesuar', color: Color(0xFF6B5A4E)),
          ],
          alerts: [
            '☔ Şemsiye zorunlu, yağmur sürüyor',
            '🥶 Hissedilen sıcaklık ${w.feelsLike.round()}°C — termal tayt şart',
            '👟 Spor ayakkabı kesinlikle hayır!',
          ],
        );
      case 'male':
        return OutfitRecommendation(
          title: 'Soğuk Yağmur Kombini 🌧️',
          subtitle: 'Hem ıslak hem soğuk — zor gün!',
          tip: 'Soğuk ve yağmurlu için en iyi kombinasyon: su geçirmez yağmurluk + lastik bot. Termal iç giyim de ekle.',
          weatherMood: 'rainy',
          primaryColor: const Color(0xFF2E6B8A),
          secondaryColor: const Color(0xFFD0EAF8),
          items: const [
            OutfitItem(emoji: '🧥', name: 'Su geçirmez yağmurluk', category: 'dış giyim', color: Color(0xFF2C5F6E)),
            OutfitItem(emoji: '👕', name: 'Termal uzun kollu kazak', category: 'üst', color: Color(0xFF4A7A8A)),
            OutfitItem(emoji: '👖', name: 'Su itici pantolon', category: 'alt', color: Color(0xFF3D5A80)),
            OutfitItem(emoji: '👢', name: 'Lastik bot', category: 'ayakkabı', color: Color(0xFF2C3E50)),
            OutfitItem(emoji: '🧣', name: 'İnce atkı', category: 'aksesuar', color: Color(0xFF8B4B3C)),
            OutfitItem(emoji: '🌂', name: 'Şemsiye', category: 'aksesuar', color: Color(0xFF1A3A4A)),
            OutfitItem(emoji: '🧦', name: 'Kalın çorap', category: 'aksesuar', color: Color(0xFF6B5A4E)),
          ],
          alerts: [
            '☔ Şemsiye zorunlu, yağmur sürüyor',
            '🥶 Hissedilen sıcaklık ${w.feelsLike.round()}°C — ekstra kat giy',
            '👟 Spor ayakkabı — kesinlikle hayır!',
          ],
        );
      default: // unisex
        return OutfitRecommendation(
          title: 'Soğuk Yağmur Kombini 🌧️',
          subtitle: 'Hem ıslak hem soğuk — zor gün!',
          tip: 'Hava hem soğuk hem yağmurlu. Katmanlı giy, su geçirmez dış giyim şart. Islak ve soğuk kombinasyonu hasta edebilir, dikkat!',
          weatherMood: 'rainy',
          primaryColor: const Color(0xFF2E6B8A),
          secondaryColor: const Color(0xFFD0EAF8),
          items: const [
            OutfitItem(emoji: '🧥', name: 'Su geçirmez yağmurluk', category: 'dış giyim', color: Color(0xFF2C5F6E)),
            OutfitItem(emoji: '👕', name: 'Termal uzun kollu kazak', category: 'üst', color: Color(0xFF4A7A8A)),
            OutfitItem(emoji: '👖', name: 'Su itici pantolon', category: 'alt', color: Color(0xFF3D5A80)),
            OutfitItem(emoji: '👢', name: 'Lastik bot', category: 'ayakkabı', color: Color(0xFF2C3E50)),
            OutfitItem(emoji: '🧣', name: 'İnce atkı', category: 'aksesuar', color: Color(0xFF8B4B3C)),
            OutfitItem(emoji: '🌂', name: 'Şemsiye', category: 'aksesuar', color: Color(0xFF1A3A4A)),
            OutfitItem(emoji: '🧦', name: 'Kalın çorap', category: 'aksesuar', color: Color(0xFF6B5A4E)),
          ],
          alerts: [
            '☔ Şemsiye zorunlu, yağmur sürüyor',
            '🥶 Hissedilen sıcaklık ${w.feelsLike.round()}°C — ekstra kat giy',
            '👟 Spor ayakkabı — kesinlikle hayır!',
          ],
        );
    }
  }

  // ─── YAĞMURLU ───────────────────────────────────────────────────────────────
  static OutfitRecommendation _rainyOutfit(WeatherData w, String style) {
    switch (style) {
      case 'female':
        return const OutfitRecommendation(
          title: 'Yağmur Şıklığı 🌦️',
          subtitle: 'Rain chic vibes!',
          tip: 'Yağmurda şık olmanın sırrı: bej trençkot + platform bot + katlanır şemsiye. Çanta seçimini su geçirmez yap!',
          weatherMood: 'rainy',
          primaryColor: Color(0xFF8B7A9A),
          secondaryColor: Color(0xFFD6EBF2),
          items: [
            OutfitItem(emoji: '🧥', name: 'Bej oversize trençkot', category: 'dış giyim', color: Color(0xFFD4C4B0)),
            OutfitItem(emoji: '👚', name: 'İnce bluz / gömlek', category: 'üst', color: Color(0xFFB8C4CC)),
            OutfitItem(emoji: '👗', name: 'Midi etek / slim pantolon', category: 'alt', color: Color(0xFF6B5B8A)),
            OutfitItem(emoji: '👢', name: 'Platform Chelsea bot', category: 'ayakkabı', color: Color(0xFF3C2A1E)),
            OutfitItem(emoji: '🌂', name: 'Katlanır şemsiye', category: 'aksesuar', color: Color(0xFF8B7A9A)),
            OutfitItem(emoji: '👜', name: 'Su geçirmez kol çantası', category: 'aksesuar', color: Color(0xFFC4A882)),
          ],
          alerts: [
            '☔ Çantanda mutlaka şemsiye olsun',
            '👟 Kumaş ayakkabı giyme, ıslanır',
            '💧 Bugün yağış olasılığı yüksek',
          ],
        );
      case 'male':
        return const OutfitRecommendation(
          title: 'Yağmurlu Gün Kombini 🌦️',
          subtitle: 'Klasik erkek stili!',
          tip: 'Yağmurda trençkot ve Chelsea bot klasik erkek kombininin vazgeçilmezi. Katlanır şemsiye çantanda hazır olsun.',
          weatherMood: 'rainy',
          primaryColor: Color(0xFF3A5A7A),
          secondaryColor: Color(0xFFD6EBF2),
          items: [
            OutfitItem(emoji: '🧥', name: 'Lacivert / haki trençkot', category: 'dış giyim', color: Color(0xFF2C4A6A)),
            OutfitItem(emoji: '👔', name: 'Uzun kollu gömlek / polo', category: 'üst', color: Color(0xFFB8C4CC)),
            OutfitItem(emoji: '👖', name: 'Slim fit jean', category: 'alt', color: Color(0xFF3D5A80)),
            OutfitItem(emoji: '👢', name: 'Chelsea bot', category: 'ayakkabı', color: Color(0xFF3C2A1E)),
            OutfitItem(emoji: '🌂', name: 'Katlanır şemsiye', category: 'aksesuar', color: Color(0xFF2C6E8A)),
            OutfitItem(emoji: '🪢', name: 'Deri kemer', category: 'aksesuar', color: Color(0xFF3C2A1E)),
          ],
          alerts: [
            '☔ Çantanda mutlaka şemsiye olsun',
            '👟 Kumaş spor ayakkabı giyme, ıslanır',
            '💧 Bugün yağış olasılığı yüksek',
          ],
        );
      default: // unisex
        return const OutfitRecommendation(
          title: 'Yağmurlu Gün Kombini 🌦️',
          subtitle: 'Şık ama pratik!',
          tip: 'Yağmur var ama çok soğuk değil. Hafif yağmurluk veya trençkot harika gözükür. Şemsiyeni çantana at, ayakkabını dikkatli seç!',
          weatherMood: 'rainy',
          primaryColor: Color(0xFF4A8FA8),
          secondaryColor: Color(0xFFD6EBF2),
          items: [
            OutfitItem(emoji: '🧥', name: 'Trençkot', category: 'dış giyim', color: Color(0xFFC4A882)),
            OutfitItem(emoji: '👔', name: 'Uzun kollu gömlek', category: 'üst', color: Color(0xFFB8C4CC)),
            OutfitItem(emoji: '👖', name: 'Slim fit jean', category: 'alt', color: Color(0xFF3D5A80)),
            OutfitItem(emoji: '👢', name: 'Chelsea bot', category: 'ayakkabı', color: Color(0xFF3C2A1E)),
            OutfitItem(emoji: '🌂', name: 'Katlanır şemsiye', category: 'aksesuar', color: Color(0xFF2C6E8A)),
            OutfitItem(emoji: '🪢', name: 'Deri kemer', category: 'aksesuar', color: Color(0xFF3C2A1E)),
          ],
          alerts: [
            '☔ Çantanda mutlaka şemsiye olsun',
            '👟 Kumaş spor ayakkabı giyme, ıslanır',
            '💧 Bugün yağış olasılığı yüksek',
          ],
        );
    }
  }

  // ─── SOĞUK ──────────────────────────────────────────────────────────────────
  static OutfitRecommendation _coldOutfit(WeatherData w, String style) {
    switch (style) {
      case 'female':
        return OutfitRecommendation(
          title: 'Soğuk Hava Şıklığı 🧥',
          subtitle: 'Zarif ve sıcak!',
          tip: 'Uzun kaşe palto ve uzun bot hem sıcak tutar hem de kış şıklığının zirvesidir. Altına termal tayt giy!',
          weatherMood: 'cold',
          primaryColor: const Color(0xFF8B5E7A),
          secondaryColor: const Color(0xFFE8E4FF),
          items: const [
            OutfitItem(emoji: '🧥', name: 'Uzun kaşe palto', category: 'dış giyim', color: Color(0xFF8B5E7A)),
            OutfitItem(emoji: '👕', name: 'Crop balıkçı yaka kazak', category: 'üst', color: Color(0xFFD4B8C8)),
            OutfitItem(emoji: '👖', name: 'Yüksek bel skinny pantolon', category: 'alt', color: Color(0xFF3D3D5C)),
            OutfitItem(emoji: '👢', name: 'Uzun deri bot (topuklu)', category: 'ayakkabı', color: Color(0xFF3C2A1E)),
            OutfitItem(emoji: '🧣', name: 'Örgü atkı', category: 'aksesuar', color: Color(0xFFB55A7A)),
            OutfitItem(emoji: '🧤', name: 'Deri eldiven', category: 'aksesuar', color: Color(0xFF3C2A1E)),
            OutfitItem(emoji: '👜', name: 'Deri kol çantası', category: 'aksesuar', color: Color(0xFFC4A882)),
            OutfitItem(emoji: '🧦', name: 'Yünlü çorap', category: 'aksesuar', color: Color(0xFF5A4A3E)),
          ],
          alerts: [
            '🥶 Hissedilen sıcaklık ${w.feelsLike.round()}°C',
            if (w.isWindy) '💨 Rüzgarlı! Atkı çok önemli bugün',
            '🧴 Cilt bakımını ihmal etme, soğuk kurutur',
          ],
        );
      case 'male':
        return OutfitRecommendation(
          title: 'Soğuk Hava Kombini 🧥',
          subtitle: 'Şık ve sıcak tut!',
          tip: 'Hava oldukça soğuk, ${w.temperature.round()}°C. Palto + kalın kazak kombinasyonu soğuk havada zarif ve pratik.',
          weatherMood: 'cold',
          primaryColor: const Color(0xFF3A3A6A),
          secondaryColor: const Color(0xFFE8E4FF),
          items: const [
            OutfitItem(emoji: '🧥', name: 'Kaşe palto', category: 'dış giyim', color: Color(0xFF2C2C54)),
            OutfitItem(emoji: '👕', name: 'Balıkçı yaka kazak', category: 'üst', color: Color(0xFF7A7A8A)),
            OutfitItem(emoji: '👖', name: 'Kumaş pantolon', category: 'alt', color: Color(0xFF3D3D5C)),
            OutfitItem(emoji: '👞', name: 'Deri bot', category: 'ayakkabı', color: Color(0xFF4A3728)),
            OutfitItem(emoji: '🧣', name: 'Örgü atkı', category: 'aksesuar', color: Color(0xFFB55A3C)),
            OutfitItem(emoji: '🧤', name: 'Deri eldiven', category: 'aksesuar', color: Color(0xFF3C2A1E)),
            OutfitItem(emoji: '🧦', name: 'Yünlü çorap', category: 'aksesuar', color: Color(0xFF5A4A3E)),
            OutfitItem(emoji: '🪢', name: 'Deri kemer', category: 'aksesuar', color: Color(0xFF3C2A1E)),
          ],
          alerts: [
            '🥶 Hissedilen sıcaklık ${w.feelsLike.round()}°C',
            if (w.isWindy) '💨 Rüzgarlı! Atkı çok önemli bugün',
            '🧴 Cilt bakımını ihmal etme, soğuk kurutur',
          ],
        );
      default: // unisex
        return OutfitRecommendation(
          title: 'Soğuk Hava Kombini 🧥',
          subtitle: 'Şık ve sıcak tut!',
          tip: 'Hava oldukça soğuk, ${w.temperature.round()}°C. Katmanlı giyim en iyi çözüm. İç kısmı sıcak tut, dışarısı zarif gözüksün!',
          weatherMood: 'cold',
          primaryColor: const Color(0xFF5B4FCF),
          secondaryColor: const Color(0xFFE8E4FF),
          items: const [
            OutfitItem(emoji: '🧥', name: 'Kaşe palto', category: 'dış giyim', color: Color(0xFF2C2C54)),
            OutfitItem(emoji: '👕', name: 'Balıkçı yaka kazak', category: 'üst', color: Color(0xFF7A7A8A)),
            OutfitItem(emoji: '👖', name: 'Kumaş pantolon', category: 'alt', color: Color(0xFF3D3D5C)),
            OutfitItem(emoji: '👞', name: 'Deri bot', category: 'ayakkabı', color: Color(0xFF4A3728)),
            OutfitItem(emoji: '🧣', name: 'Örgü atkı', category: 'aksesuar', color: Color(0xFFB55A3C)),
            OutfitItem(emoji: '🧤', name: 'Deri eldiven', category: 'aksesuar', color: Color(0xFF3C2A1E)),
            OutfitItem(emoji: '🧦', name: 'Yünlü çorap', category: 'aksesuar', color: Color(0xFF5A4A3E)),
            OutfitItem(emoji: '🪢', name: 'Deri kemer', category: 'aksesuar', color: Color(0xFF3C2A1E)),
          ],
          alerts: [
            '🥶 Hissedilen sıcaklık ${w.feelsLike.round()}°C',
            if (w.isWindy) '💨 Rüzgarlı! Atkı çok önemli bugün',
            '🧴 Cilt bakımını ihmal etme, soğuk kurutur',
          ],
        );
    }
  }

  // ─── SICAK ──────────────────────────────────────────────────────────────────
  static OutfitRecommendation _hotOutfit(WeatherData w, String style) {
    switch (style) {
      case 'female':
        return OutfitRecommendation(
          title: 'Sıcak Hava Şıklığı ☀️',
          subtitle: 'Serin ve feminen!',
          tip: 'Sıcakta en iyi seçim: açık renkli hafif kumaşlar, yazlık etek veya şort. Güneş kremi ve şapkayı sakın unutma!',
          weatherMood: 'sunny',
          primaryColor: const Color(0xFFE8607A),
          secondaryColor: const Color(0xFFFFF3E0),
          items: const [
            OutfitItem(emoji: '👚', name: 'Kolsuz crop bluz / askılı', category: 'üst', color: Color(0xFFFF8B94)),
            OutfitItem(emoji: '👗', name: 'Yazlık midi etek / mini etek', category: 'alt', color: Color(0xFFE8B4B8)),
            OutfitItem(emoji: '👡', name: 'Sandalet / espadrille', category: 'ayakkabı', color: Color(0xFFC4A882)),
            OutfitItem(emoji: '🕶️', name: 'Güneş gözlüğü', category: 'aksesuar', color: Color(0xFF2C2C2C)),
            OutfitItem(emoji: '👒', name: 'Hasır şapka / güneş şapkası', category: 'aksesuar', color: Color(0xFFC4963A)),
            OutfitItem(emoji: '👜', name: 'Küçük kol çantası / tote', category: 'aksesuar', color: Color(0xFFD4A874)),
            OutfitItem(emoji: '🧴', name: 'Güneş kremi SPF 50+', category: 'aksesuar', color: Color(0xFFFFA726)),
          ],
          alerts: [
            '☀️ SPF 50+ güneş kremi sür!',
            '💧 Bol su iç, dehidrasyon riski var',
            '🌡️ Öğle saatlerinde gölgede kal',
            if (w.isWindy) '💨 Şapkanı uçurmasın rüzgar!',
          ],
        );
      case 'male':
        return OutfitRecommendation(
          title: 'Sıcak Hava Kombini ☀️',
          subtitle: 'Serin ve rahat!',
          tip: 'Sıcakta linen kumaş nefes aldırır. Polo veya keten gömlek + bermuda kombinasyonu hem rahat hem şık.',
          weatherMood: 'sunny',
          primaryColor: const Color(0xFFE8974A),
          secondaryColor: const Color(0xFFFFF3E0),
          items: const [
            OutfitItem(emoji: '👕', name: 'Polo / linen kısa kollu', category: 'üst', color: Color(0xFF5BA4CF)),
            OutfitItem(emoji: '🩳', name: 'Bermuda şort / chino şort', category: 'alt', color: Color(0xFF7BBFB5)),
            OutfitItem(emoji: '👟', name: 'Spor sandalet / espadrille', category: 'ayakkabı', color: Color(0xFFE8A87C)),
            OutfitItem(emoji: '🕶️', name: 'Güneş gözlüğü', category: 'aksesuar', color: Color(0xFF2C2C2C)),
            OutfitItem(emoji: '🧢', name: 'Beyzbol kep / hasır fedora', category: 'aksesuar', color: Color(0xFF2C3E50)),
            OutfitItem(emoji: '🧴', name: 'Güneş kremi SPF 50+', category: 'aksesuar', color: Color(0xFFFFA726)),
          ],
          alerts: [
            '☀️ SPF 50+ güneş kremi sür!',
            '💧 Bol su iç, dehidrasyon riski var',
            '🌡️ Öğle saatlerinde gölgede kal',
            if (w.isWindy) '💨 Şapkanı uçurmasın rüzgar!',
          ],
        );
      default: // unisex
        return OutfitRecommendation(
          title: 'Sıcak Hava Kombini ☀️',
          subtitle: 'Serin ve rahat giy!',
          tip: 'Hava ${w.temperature.round()}°C — oldukça sıcak! Açık renkli, hafif ve nefes alan kumaşları tercih et. Güneş kremi şart!',
          weatherMood: 'sunny',
          primaryColor: const Color(0xFFE8974A),
          secondaryColor: const Color(0xFFFFF3E0),
          items: const [
            OutfitItem(emoji: '👕', name: 'İnce kısa kollu tişört', category: 'üst', color: Color(0xFF5BA4CF)),
            OutfitItem(emoji: '🩳', name: 'Şort', category: 'alt', color: Color(0xFF7BBFB5)),
            OutfitItem(emoji: '👟', name: 'Spor sandalet', category: 'ayakkabı', color: Color(0xFFE8A87C)),
            OutfitItem(emoji: '🕶️', name: 'Güneş gözlüğü', category: 'aksesuar', color: Color(0xFF2C2C2C)),
            OutfitItem(emoji: '🧢', name: 'Şapka / kep', category: 'aksesuar', color: Color(0xFFD4A847)),
            OutfitItem(emoji: '🧴', name: 'Güneş kremi', category: 'aksesuar', color: Color(0xFFFFA726)),
          ],
          alerts: [
            '☀️ SPF 50+ güneş kremi sür!',
            '💧 Bol su iç, dehidrasyon riski var',
            '🌡️ Öğle saatlerinde gölgede kal',
            if (w.isWindy) '💨 Şapkanı uçurmasın rüzgar!',
          ],
        );
    }
  }

  // ─── GÜNEŞLI YAZ ────────────────────────────────────────────────────────────
  static OutfitRecommendation _sunnySummerOutfit(WeatherData w, String style) {
    switch (style) {
      case 'female':
        return const OutfitRecommendation(
          title: 'Güneşli Yaz Şıklığı 🌞',
          subtitle: 'Yaz modası açık!',
          tip: 'Yazlık elbise veya crop-etek kombinasyonu, sandalet ve güneş şapkasıyla mükemmel bir yaz görünümü! Akşam için ince bir hırka çantanda olsun.',
          weatherMood: 'sunny',
          primaryColor: Color(0xFFE8607A),
          secondaryColor: Color(0xFFFFFDE7),
          items: [
            OutfitItem(emoji: '👗', name: 'Yazlık elbise / crop + etek', category: 'üst', color: Color(0xFFFF8B94)),
            OutfitItem(emoji: '👡', name: 'Sandalet / espadrille', category: 'ayakkabı', color: Color(0xFFC4A882)),
            OutfitItem(emoji: '🕶️', name: 'Güneş gözlüğü', category: 'aksesuar', color: Color(0xFF2C2C2C)),
            OutfitItem(emoji: '👒', name: 'Hasır şapka', category: 'aksesuar', color: Color(0xFFC4963A)),
            OutfitItem(emoji: '👜', name: 'Hasır çanta / tote bag', category: 'aksesuar', color: Color(0xFFD4A874)),
            OutfitItem(emoji: '💍', name: 'İnce bileklik / halhal', category: 'aksesuar', color: Color(0xFFFFD700)),
            OutfitItem(emoji: '🧴', name: 'Güneş kremi SPF 50+', category: 'aksesuar', color: Color(0xFFFFA726)),
          ],
          alerts: [
            '🌅 Akşam serin olabilir, ince hırka al',
            '☀️ Güneş kremi sürmeyi unutma',
          ],
        );
      case 'male':
        return const OutfitRecommendation(
          title: 'Güneşli Yaz Kombini 🌞',
          subtitle: 'Bugün harika bir gün!',
          tip: 'Güneşli yazda açık renkli linen gömlek ve bermuda mükemmel duruş sağlar. Espadrille veya sandalet konforu tamamlar.',
          weatherMood: 'sunny',
          primaryColor: Color(0xFF3A7A9A),
          secondaryColor: Color(0xFFFFFDE7),
          items: [
            OutfitItem(emoji: '👔', name: 'Linen kısa kollu gömlek (açık renk)', category: 'üst', color: Color(0xFF87CEEB)),
            OutfitItem(emoji: '🩳', name: 'Bermuda / chino şort', category: 'alt', color: Color(0xFF7BBFB5)),
            OutfitItem(emoji: '👟', name: 'Beyaz sneaker / espadrille', category: 'ayakkabı', color: Color(0xFFE8E8E8)),
            OutfitItem(emoji: '🕶️', name: 'Güneş gözlüğü', category: 'aksesuar', color: Color(0xFF2C2C2C)),
            OutfitItem(emoji: '🧢', name: 'Hasır fedora / beyzbol kep', category: 'aksesuar', color: Color(0xFFC4963A)),
            OutfitItem(emoji: '🎒', name: 'Sırt çantası / bez çanta', category: 'aksesuar', color: Color(0xFF7A6652)),
            OutfitItem(emoji: '🧴', name: 'Güneş kremi SPF 50+', category: 'aksesuar', color: Color(0xFFFFA726)),
          ],
          alerts: [
            '🌅 Akşam serin olabilir, ince bir üst al',
            '☀️ Güneş kremi sürmeyi unutma',
          ],
        );
      default: // unisex
        return const OutfitRecommendation(
          title: 'Güneşli Yaz Kombini 🌞',
          subtitle: 'Bugün harika bir gün!',
          tip: 'Güzel ve ılık bir gün seni bekliyor. Hafif kıyafetler giy, ama akşam için ince bir hırka çantanda olsun!',
          weatherMood: 'sunny',
          primaryColor: Color(0xFFE8C547),
          secondaryColor: Color(0xFFFFFDE7),
          items: [
            OutfitItem(emoji: '👕', name: 'Askılı kolsuz bluz', category: 'üst', color: Color(0xFFFF8B94)),
            OutfitItem(emoji: '🩳', name: 'Yazlık kısa şort', category: 'alt', color: Color(0xFFAEC6CF)),
            OutfitItem(emoji: '👟', name: 'Beyaz sneaker', category: 'ayakkabı', color: Color(0xFFE8E8E8)),
            OutfitItem(emoji: '🕶️', name: 'Güneş gözlüğü', category: 'aksesuar', color: Color(0xFF2C2C2C)),
            OutfitItem(emoji: '👒', name: 'Hasır şapka', category: 'aksesuar', color: Color(0xFFC4963A)),
            OutfitItem(emoji: '🛍️', name: 'Hasır çanta', category: 'aksesuar', color: Color(0xFFD4A874)),
            OutfitItem(emoji: '🧴', name: 'Güneş kremi', category: 'aksesuar', color: Color(0xFFFFA726)),
          ],
          alerts: [
            '🌅 Akşam serin olabilir, ince hırka al',
            '☀️ Güneş kremi sürmeyi unutma',
          ],
        );
    }
  }

  // ─── ILIK ───────────────────────────────────────────────────────────────────
  static OutfitRecommendation _warmOutfit(WeatherData w, String style) {
    switch (style) {
      case 'female':
        return OutfitRecommendation(
          title: 'Ilık Hava Şıklığı 🌤️',
          subtitle: 'Rahat ve feminen!',
          tip: 'Ilık havada kısa hırka veya hafif blazer her ortama uyar. Yüksek bel jean ve loafer şık bir günlük kombinasyon!',
          weatherMood: 'cloudy',
          primaryColor: const Color(0xFF9B7A6A),
          secondaryColor: const Color(0xFFE8F5E9),
          items: const [
            OutfitItem(emoji: '🧥', name: 'Kısa hırka / hafif blazer', category: 'dış giyim', color: Color(0xFF8B7A6A)),
            OutfitItem(emoji: '👚', name: 'İnce bluz / crop top', category: 'üst', color: Color(0xFFFFB5C2)),
            OutfitItem(emoji: '👖', name: 'Yüksek bel mom jean / palazzo', category: 'alt', color: Color(0xFF3D5A80)),
            OutfitItem(emoji: '👟', name: 'Platform sneaker / loafer', category: 'ayakkabı', color: Color(0xFFE8E8E8)),
            OutfitItem(emoji: '👜', name: 'Kol çantası', category: 'aksesuar', color: Color(0xFFC4A882)),
            OutfitItem(emoji: '💍', name: 'İnce bileklik / küpe', category: 'aksesuar', color: Color(0xFFFFD700)),
          ],
          alerts: [
            if (w.isWindy) '💨 Rüzgarlı — hırka iyi fikir!',
            '🌤️ Güzel bir gün, dışarı çık!',
          ],
        );
      case 'male':
        return OutfitRecommendation(
          title: 'Ilık Hava Kombini 🌤️',
          subtitle: 'Rahat ve keyifli!',
          tip: 'Ilık havada rüzgarlık yelek veya ince hırka yeterli. Polo + chino kombinasyonu her yere yakışır.',
          weatherMood: 'cloudy',
          primaryColor: const Color(0xFF4A7A5A),
          secondaryColor: const Color(0xFFE8F5E9),
          items: const [
            OutfitItem(emoji: '🧥', name: 'Rüzgarlık yelek / ince ceket', category: 'dış giyim', color: Color(0xFF3D5A80)),
            OutfitItem(emoji: '👕', name: 'Polo tişört', category: 'üst', color: Color(0xFF5BA4CF)),
            OutfitItem(emoji: '👖', name: 'Slim jean / chino pantolon', category: 'alt', color: Color(0xFF3D5A80)),
            OutfitItem(emoji: '👟', name: 'Beyaz sneaker / loafer', category: 'ayakkabı', color: Color(0xFFE8E8E8)),
            OutfitItem(emoji: '🎒', name: 'Bez çanta / deri bileklik', category: 'aksesuar', color: Color(0xFF7A6652)),
          ],
          alerts: [
            if (w.isWindy) '💨 Rüzgarlı — ceket iyi fikir!',
            '🌤️ Güzel bir gün, dışarı çık!',
          ],
        );
      default: // unisex
        return OutfitRecommendation(
          title: 'Ilık Hava Kombini 🌤️',
          subtitle: 'Rahat ve keyifli!',
          tip: 'Ne çok sıcak ne çok soğuk — ideal hava! İnce bir ceket ya da hırka ile mükemmel bir gün geçirebilirsin.',
          weatherMood: 'cloudy',
          primaryColor: const Color(0xFF6B9E78),
          secondaryColor: const Color(0xFFE8F5E9),
          items: const [
            OutfitItem(emoji: '🧥', name: 'İnce hırka', category: 'dış giyim', color: Color(0xFF5C7A67)),
            OutfitItem(emoji: '👕', name: 'Basic kısa kollu tişört', category: 'üst', color: Color(0xFFB0BEC5)),
            OutfitItem(emoji: '👖', name: 'Slim jean', category: 'alt', color: Color(0xFF3D5A80)),
            OutfitItem(emoji: '👟', name: 'Sneaker', category: 'ayakkabı', color: Color(0xFFE8E8E8)),
            OutfitItem(emoji: '🎒', name: 'Sırt çantası', category: 'aksesuar', color: Color(0xFF7A6652)),
            OutfitItem(emoji: '🪢', name: 'Kumaş kemer', category: 'aksesuar', color: Color(0xFF5C7A67)),
          ],
          alerts: [
            if (w.isWindy) '💨 Rüzgarlı — ceket iyi fikir!',
            '🌤️ Güzel bir gün, dışarı çık!',
          ],
        );
    }
  }

  // ─── ILIMAN (BAHAR/SONBAHAR) ─────────────────────────────────────────────────
  static OutfitRecommendation _mildOutfit(WeatherData w, String style) {
    switch (style) {
      case 'female':
        return const OutfitRecommendation(
          title: 'Bahar/Sonbahar Şıklığı 🍂',
          subtitle: 'Katmanlı ve zarif!',
          tip: 'Mevsim geçişinde trençkot veya blazer ceket her durumu kurtarır. Chunky sneaker veya bot ile şıklığı tamamla!',
          weatherMood: 'cloudy',
          primaryColor: Color(0xFF9B5A7A),
          secondaryColor: Color(0xFFFFF3E6),
          items: [
            OutfitItem(emoji: '🧥', name: 'Trençkot / blazer ceket', category: 'dış giyim', color: Color(0xFF8B5E7A)),
            OutfitItem(emoji: '👕', name: 'Balıkçı yaka kazak / bluz', category: 'üst', color: Color(0xFFD4B8C8)),
            OutfitItem(emoji: '👖', name: 'Slim pantolon / mom jean', category: 'alt', color: Color(0xFF3D5A80)),
            OutfitItem(emoji: '👟', name: 'Chunky sneaker / kısa bot', category: 'ayakkabı', color: Color(0xFFE8E0D8)),
            OutfitItem(emoji: '🧣', name: 'İnce atkı', category: 'aksesuar', color: Color(0xFFC4783C)),
            OutfitItem(emoji: '👜', name: 'Tote bag / kol çantası', category: 'aksesuar', color: Color(0xFFC4A882)),
          ],
          alerts: [
            '🌡️ Sabah-akşam arası ısı farkı var',
            '🎒 Çantana ince kat koy, işe yarar',
          ],
        );
      case 'male':
        return const OutfitRecommendation(
          title: 'Bahar/Sonbahar Kombini 🍂',
          subtitle: 'Katmanlı giy, hazırlıklı ol!',
          tip: 'Mevsim geçişi döneminde katmanlı giyim en mantıklısı. Kolayca çıkarılabilen kat seç: ceket + sweatshirt ikili si mükemmel.',
          weatherMood: 'cloudy',
          primaryColor: Color(0xFF5A4A3E),
          secondaryColor: Color(0xFFFFF3E6),
          items: [
            OutfitItem(emoji: '🧥', name: 'Orta kalınlıkta mont / ceket', category: 'dış giyim', color: Color(0xFF8B5E3C)),
            OutfitItem(emoji: '👕', name: 'Kapüşonlu sweatshirt', category: 'üst', color: Color(0xFF78909C)),
            OutfitItem(emoji: '👖', name: 'Jean / chino pantolon', category: 'alt', color: Color(0xFF3D5A80)),
            OutfitItem(emoji: '👟', name: 'Spor ayakkabı / loafer', category: 'ayakkabı', color: Color(0xFFE8E0D8)),
            OutfitItem(emoji: '🧣', name: 'İnce atkı', category: 'aksesuar', color: Color(0xFFC4783C)),
            OutfitItem(emoji: '🧦', name: 'Pamuklu çorap', category: 'aksesuar', color: Color(0xFF78909C)),
          ],
          alerts: [
            '🌡️ Sabah-akşam arası ısı farkı var',
            '🎒 Çantana ince kat koy, işe yarar',
          ],
        );
      default: // unisex
        return const OutfitRecommendation(
          title: 'Bahar/Sonbahar Kombini 🍂',
          subtitle: 'Katmanlı giy, hazırlıklı ol!',
          tip: 'Mevsim geçiş dönemi havası. Sabah soğuk, öğlen ılık olabilir. Çıkarması kolay katmanlar seç!',
          weatherMood: 'cloudy',
          primaryColor: Color(0xFFB5744A),
          secondaryColor: Color(0xFFFFF3E6),
          items: [
            OutfitItem(emoji: '🧥', name: 'Orta kalınlıkta mont', category: 'dış giyim', color: Color(0xFF8B5E3C)),
            OutfitItem(emoji: '🧥', name: 'Kapüşonlu sweatshirt', category: 'üst', color: Color(0xFF78909C)),
            OutfitItem(emoji: '👖', name: 'Kot pantolon', category: 'alt', color: Color(0xFF3D5A80)),
            OutfitItem(emoji: '👟', name: 'Spor ayakkabı', category: 'ayakkabı', color: Color(0xFFE8E0D8)),
            OutfitItem(emoji: '🧣', name: 'İnce atkı', category: 'aksesuar', color: Color(0xFFC4783C)),
            OutfitItem(emoji: '🧦', name: 'Pamuklu çorap', category: 'aksesuar', color: Color(0xFF78909C)),
          ],
          alerts: [
            '🌡️ Sabah-akşam arası ısı farkı var',
            '🎒 Çantana ince kat koy, işe yarar',
          ],
        );
    }
  }

  static OutfitRecommendation getRecommendationForForecast(ForecastDay day, {String style = 'unisex'}) {
    final weather = WeatherData(
      city: '',
      country: '',
      temperature: (day.tempMax + day.tempMin) / 2,
      feelsLike: (day.tempMax + day.tempMin) / 2 - 2,
      windSpeed: day.windSpeed,
      humidity: day.humidity,
      precipitationChance: day.precipitationChance,
      condition: day.condition,
      description: day.description.isNotEmpty ? day.description : day.condition,
      tempMin: day.tempMin,
      tempMax: day.tempMax,
      sunrise: DateTime.now(),
      sunset: DateTime.now(),
      forecast: [],
    );
    return getRecommendation(weather, style: style);
  }
}
