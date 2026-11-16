import 'package:shared_preferences/shared_preferences.dart';
import 'sync_service.dart';

class FavoritesService {
  static const _key = 'favorite_cities';

  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> addFavorite(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_key) ?? [];
    if (!favorites.contains(city)) {
      favorites.add(city);
      await prefs.setStringList(_key, favorites);
      await SyncService.enqueue(
        event: 'favorite.city.added',
        payload: {'city': city},
      );
    }
  }

  static Future<void> removeFavorite(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_key) ?? [];
    favorites.remove(city);
    await prefs.setStringList(_key, favorites);
    await SyncService.enqueue(
      event: 'favorite.city.removed',
      payload: {'city': city},
    );
  }

  static Future<bool> isFavorite(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_key) ?? [];
    return favorites.contains(city);
  }
}
