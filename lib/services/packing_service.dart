import '../models/weather_model.dart';

class PackingItem {
  final String emoji;
  final String nameTR;
  final String nameEN;
  final String category;
  final bool essential;

  const PackingItem({
    required this.emoji,
    required this.nameTR,
    required this.nameEN,
    required this.category,
    this.essential = false,
  });
}

class PackingService {
  static List<PackingItem> generatePackingList(List<WeatherData> weatherList, int days) {
    final items = <PackingItem>[];
    final hasRain = weatherList.any((w) => w.condition == 'rain' || w.condition == 'drizzle');
    final hasSnow = weatherList.any((w) => w.condition == 'snow');
    final hasCold = weatherList.any((w) => w.temperature < 10);
    final hasHot = weatherList.any((w) => w.temperature > 28);
    final hasSunny = weatherList.any((w) => w.condition == 'clear');
    final hasWindy = weatherList.any((w) => w.windSpeed > 25);
    final minTemp = weatherList.map((w) => w.temperature).reduce((a, b) => a < b ? a : b);
    final maxTemp = weatherList.map((w) => w.temperature).reduce((a, b) => a > b ? a : b);

    // Essentials
    items.add(const PackingItem(emoji: '👕', nameTR: 'Tişört', nameEN: 'T-Shirt', category: 'Üst', essential: true));
    items.add(const PackingItem(emoji: '👖', nameTR: 'Pantolon', nameEN: 'Pants', category: 'Alt', essential: true));
    items.add(const PackingItem(emoji: '🩲', nameTR: 'İç Çamaşırı', nameEN: 'Underwear', category: 'İç', essential: true));
    items.add(const PackingItem(emoji: '🧦', nameTR: 'Çorap', nameEN: 'Socks', category: 'Aksesuar', essential: true));
    items.add(const PackingItem(emoji: '👟', nameTR: 'Ayakkabı', nameEN: 'Shoes', category: 'Ayakkabı', essential: true));

    // Weather-based
    if (hasRain) {
      items.add(const PackingItem(emoji: '☂️', nameTR: 'Şemsiye', nameEN: 'Umbrella', category: 'Aksesuar', essential: true));
      items.add(const PackingItem(emoji: '🧥', nameTR: 'Yağmurluk', nameEN: 'Raincoat', category: 'Üst'));
    }
    if (hasSnow) {
      items.add(const PackingItem(emoji: '🧤', nameTR: 'Eldiven', nameEN: 'Gloves', category: 'Aksesuar'));
      items.add(const PackingItem(emoji: '🧣', nameTR: 'Atkı', nameEN: 'Scarf', category: 'Aksesuar'));
      items.add(const PackingItem(emoji: '🥾', nameTR: 'Bot', nameEN: 'Boots', category: 'Ayakkabı'));
    }
    if (hasCold) {
      items.add(const PackingItem(emoji: '🧥', nameTR: 'Kalın Mont', nameEN: 'Heavy Coat', category: 'Üst', essential: true));
      items.add(const PackingItem(emoji: '🧶', nameTR: 'Kazak', nameEN: 'Sweater', category: 'Üst'));
      if (minTemp < 5) {
        items.add(const PackingItem(emoji: '🎿', nameTR: 'Termal İçlik', nameEN: 'Thermal', category: 'İç'));
      }
    }
    if (hasHot) {
      items.add(const PackingItem(emoji: '🩳', nameTR: 'Şort', nameEN: 'Shorts', category: 'Alt'));
      items.add(const PackingItem(emoji: '🩴', nameTR: 'Sandalet', nameEN: 'Sandals', category: 'Ayakkabı'));
    }
    if (hasSunny) {
      items.add(const PackingItem(emoji: '🕶️', nameTR: 'Güneş Gözlüğü', nameEN: 'Sunglasses', category: 'Aksesuar'));
      items.add(const PackingItem(emoji: '🧴', nameTR: 'Güneş Kremi', nameEN: 'Sunscreen', category: 'Kişisel'));
      items.add(const PackingItem(emoji: '🧢', nameTR: 'Şapka', nameEN: 'Hat', category: 'Aksesuar'));
    }
    if (hasWindy) {
      items.add(const PackingItem(emoji: '🧥', nameTR: 'Rüzgarlık', nameEN: 'Windbreaker', category: 'Üst'));
    }

    // Temperature range
    if (maxTemp - minTemp > 10) {
      items.add(const PackingItem(emoji: '🧥', nameTR: 'Katmanlı Giysi', nameEN: 'Layered Clothing', category: 'Üst'));
    }

    // General travel items
    items.add(const PackingItem(emoji: '🪥', nameTR: 'Diş Fırçası', nameEN: 'Toothbrush', category: 'Kişisel', essential: true));
    items.add(const PackingItem(emoji: '🧴', nameTR: 'Şampuan', nameEN: 'Shampoo', category: 'Kişisel'));
    items.add(const PackingItem(emoji: '💊', nameTR: 'İlaçlar', nameEN: 'Medicine', category: 'Sağlık'));
    items.add(const PackingItem(emoji: '🔌', nameTR: 'Şarj Aleti', nameEN: 'Charger', category: 'Elektronik', essential: true));

    return items;
  }
}
