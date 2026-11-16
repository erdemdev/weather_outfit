class FashionTip {
  final String emoji;
  final String titleTR;
  final String titleEN;
  final String tipTR;
  final String tipEN;
  final String category; // body, color, weather, general

  const FashionTip({
    required this.emoji,
    required this.titleTR,
    required this.titleEN,
    required this.tipTR,
    required this.tipEN,
    required this.category,
  });
}

class FashionTipsService {
  static const _tips = [
    // Weather tips
    FashionTip(emoji: '☀️', titleTR: 'Sıcak Hava Stili', titleEN: 'Hot Weather Style', tipTR: 'Sıcak havalarda açık renkler, pamuklu ve keten kumaşlar tercih edin. Vücudunuza yapışmayan bol kesimler rahat hissettirin.', tipEN: 'In hot weather, prefer light colors, cotton and linen fabrics. Loose fits that don\'t cling to your body feel comfortable.', category: 'weather'),
    FashionTip(emoji: '🌧️', titleTR: 'Yağmurlu Gün Taktiği', titleEN: 'Rainy Day Tactic', tipTR: 'Yağmurda koyu renkler ve su itici kumaşlar tercih edin. Kısa bot veya su geçirmez ayakkabı şart.', tipEN: 'In rain, prefer dark colors and water-repellent fabrics. Short boots or waterproof shoes are essential.', category: 'weather'),
    FashionTip(emoji: '❄️', titleTR: 'Kış Stili', titleEN: 'Winter Style', tipTR: 'Katmanlı giyinin: termal iç, yün orta kat, su geçirmez dış kat. Atkı ve bere hem sıcak tutar hem şık durur.', tipEN: 'Layer up: thermal base, wool mid-layer, waterproof outer. Scarf and beanie keep you warm and stylish.', category: 'weather'),
    FashionTip(emoji: '🍂', titleTR: 'Sonbahar Paleti', titleEN: 'Autumn Palette', tipTR: 'Toprak tonları, hardal, bordo ve orman yeşili sonbaharın renkleridir. Karışık desenlerle zenginleştirin.', tipEN: 'Earth tones, mustard, burgundy and forest green are autumn colors. Enrich with mixed patterns.', category: 'weather'),

    // Color tips
    FashionTip(emoji: '🎨', titleTR: 'Renk 60-30-10 Kuralı', titleEN: 'Color 60-30-10 Rule', tipTR: '%60 ana renk, %30 ikincil renk, %10 aksesuar rengi kullanın. Dengeli ve şık görünürsünüz.', tipEN: 'Use 60% main color, 30% secondary, 10% accent. You\'ll look balanced and stylish.', category: 'color'),
    FashionTip(emoji: '🖤', titleTR: 'Siyah & Beyaz', titleEN: 'Black & White', tipTR: 'Siyah-beyaz her zaman şıktır. Tek bir renkli aksesuar ekleyerek tarzınıza karakter katın.', tipEN: 'Black & white is always elegant. Add a single colored accessory for character.', category: 'color'),
    FashionTip(emoji: '🩵', titleTR: 'Pastel Kullanımı', titleEN: 'Using Pastels', tipTR: 'Pastel renkler yumuşak ve feminen bir hava verir. Birbirine yakın tonlarda kullanmak en güvenli yol.', tipEN: 'Pastel colors give a soft, feminine vibe. Using similar tones is the safest approach.', category: 'color'),
    FashionTip(emoji: '🔴', titleTR: 'Cesur Renk Kombinleri', titleEN: 'Bold Color Combos', tipTR: 'Kontrast renkler cesur bir görünüm verir. Mavi-turuncu, mor-sarı gibi tamamlayıcı renklerle deneyin.', tipEN: 'Contrasting colors give a bold look. Try complementary colors like blue-orange, purple-yellow.', category: 'color'),

    // Body tips
    FashionTip(emoji: '📐', titleTR: 'Beden Oranları', titleEN: 'Body Proportions', tipTR: 'Üst bedeniniz genişse V yaka, dar bedeniniz genişse yüksek bel tercih edin. Doğru oranlar dengeyi sağlar.', tipEN: 'If upper body is broad, try V-neck; if lower is wide, try high waist. Correct proportions create balance.', category: 'body'),
    FashionTip(emoji: '👔', titleTR: 'Dikkat Çekici Parça', titleEN: 'Statement Piece', tipTR: 'Her kombinde tek bir dikkat çekici parça olsun. Çok fazla statement piece kaotik görünür.', tipEN: 'Have one statement piece per outfit. Too many look chaotic.', category: 'body'),
    FashionTip(emoji: '👟', titleTR: 'Ayakkabı Seçimi', titleEN: 'Shoe Selection', tipTR: 'Ayakkabı kombinin temelini oluşturur. Spor kombine topuklu, şık kombine spor ayakkabı karıştırmayın.', tipEN: 'Shoes form the foundation. Don\'t mix heels with sporty outfits or sneakers with elegant ones.', category: 'body'),

    // General tips
    FashionTip(emoji: '🧹', titleTR: 'Dolap Düzeni', titleEN: 'Wardrobe Order', tipTR: '1 yıldır giymediklerinizi eleyip bağışlayın. Az ama kaliteli parçalar her zaman daha iyidir.', tipEN: 'Donate items unworn for 1 year. Fewer quality pieces are always better.', category: 'general'),
    FashionTip(emoji: '🔄', titleTR: 'Kapsül Dolap', titleEN: 'Capsule Wardrobe', tipTR: '30-40 parça ile sonsuz kombin yapabilirsiniz. Temel parçaları nötr renklerde seçin.', tipEN: 'You can create endless outfits with 30-40 pieces. Choose basics in neutral colors.', category: 'general'),
    FashionTip(emoji: '♻️', titleTR: 'Sürdürülebilir Moda', titleEN: 'Sustainable Fashion', tipTR: 'Kaliteli parçalar uzun ömürlüdür. Hızlı moda yerine uzun ömürlü parçalara yatırım yapın.', tipEN: 'Quality pieces last longer. Invest in durable pieces instead of fast fashion.', category: 'general'),
    FashionTip(emoji: '📱', titleTR: 'Kombin Fotoğrafı', titleEN: 'Outfit Photo', tipTR: 'Her gün kombininizi fotoğraflayın. Hangi kombinlerin işe yaradığını görmek çok değerli.', tipEN: 'Photograph your outfit daily. Seeing which outfits work is invaluable.', category: 'general'),
  ];

  /// Hava durumuna göre ipuçları
  static List<FashionTip> getWeatherTips(String condition) {
    return _tips.where((t) => t.category == 'weather').toList();
  }

  /// Kategoriye göre ipuçları
  static List<FashionTip> getByCategory(String category) {
    return _tips.where((t) => t.category == category).toList();
  }

  /// Tüm ipuçları
  static List<FashionTip> getAllTips() => _tips;

  /// Günün ipucu
  static FashionTip getTipOfTheDay() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _tips[dayOfYear % _tips.length];
  }
}
