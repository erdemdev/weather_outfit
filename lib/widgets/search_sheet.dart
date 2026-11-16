import 'package:flutter/material.dart';
import '../services/favorites_service.dart';
import '../l10n/app_localizations.dart';

class SearchSheet extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String) onSearch;

  const SearchSheet({super.key, required this.controller, required this.onSearch});

  @override
  State<SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<SearchSheet> {
  final List<String> _suggestions = [
    'İstanbul',
    'Ankara',
    'İzmir',
    'Antalya',
    'Bursa',
    'Adana',
    'Gaziantep',
    'Konya',
    'Mersin',
    'Trabzon',
    'Eskişehir',
    'Kayseri',
    'Samsun',
    'Diyarbakır',
    'Osmaniye',
  ];
  List<String> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favs = await FavoritesService.getFavorites();
    setState(() => _favorites = favs);
  }

  Future<void> _toggleFavorite(String city) async {
    if (_favorites.contains(city)) {
      await FavoritesService.removeFavorite(city);
    } else {
      await FavoritesService.addFavorite(city);
    }
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2B35) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Semantics(
              label: AppStrings.get('search_city'),
              textField: true,
              child: TextField(
                controller: widget.controller,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: AppStrings.get('search_city'),
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : null,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: Color(0xFF2C6E8A)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color:
                          isDark ? Colors.white24 : const Color(0xFFE0E0E0),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color:
                          isDark ? Colors.white24 : const Color(0xFFE0E0E0),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: Color(0xFF2C6E8A), width: 1.5),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send_rounded,
                        color: Color(0xFF2C6E8A)),
                    onPressed: () {
                      final city = widget.controller.text.trim();
                      if (city.isNotEmpty) widget.onSearch(city);
                    },
                  ),
                ),
                onSubmitted: (city) {
                  if (city.trim().isNotEmpty) widget.onSearch(city.trim());
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Favorites section
          if (_favorites.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Colors.amber, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      AppStrings.get('favorites'),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _favorites.length,
                itemBuilder: (ctx, i) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Semantics(
                      button: true,
                      label: '${_favorites[i]} şehrini seç',
                      child: ActionChip(
                        avatar: const Icon(Icons.star_rounded,
                            color: Colors.amber, size: 16),
                        label: Text(_favorites[i]),
                        onPressed: () => widget.onSearch(_favorites[i]),
                        backgroundColor: isDark
                            ? const Color(0xFF1E3345)
                            : const Color(0xFFF5F9FC),
                        labelStyle: TextStyle(
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF2C6E8A),
                          fontWeight: FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: isDark
                              ? Colors.white10
                              : const Color(0xFF2C6E8A).withAlpha(51),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppStrings.get('popular_cities'),
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white54 : Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _suggestions.length,
              itemBuilder: (ctx, i) {
                final city = _suggestions[i];
                final isFav = _favorites.contains(city);
                return Semantics(
                  button: true,
                  label: '$city şehri',
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    leading: const Icon(Icons.location_on_rounded,
                        color: Color(0xFF2C6E8A), size: 20),
                    title: Text(
                      city,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isFav
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: isFav
                                ? Colors.amber
                                : (isDark ? Colors.white38 : Colors.grey),
                            size: 22,
                          ),
                          onPressed: () => _toggleFavorite(city),
                          tooltip: isFav ? 'Favorilerden çıkar' : 'Favorilere ekle',
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: isDark ? Colors.white38 : Colors.grey,
                        ),
                      ],
                    ),
                    onTap: () => widget.onSearch(city),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
